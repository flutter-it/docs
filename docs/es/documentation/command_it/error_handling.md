# Manejo de Errores (Error Handling)

Deja de preocuparte por excepciones no capturadas que crashean tu app. `command_it` proporciona manejo automático de excepciones con potentes capacidades de enrutamiento - no más bloques `try-catch` desordenados o tipos `Result<T, Error>` en todas partes.

**Características Clave:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">🛡️ <strong>Nunca te preocupes por excepciones</strong> - Los Commands capturan todos los errores automáticamente</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">🎯 <strong>Potente enrutamiento de errores</strong> - Enruta errores localmente, globalmente, o déjalos lanzar</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">🎁 <strong>Deja de retornar tipos Result</strong> - Las funciones retornan <code>T</code> limpio, no <code>Result&lt;T, Error&gt;</code></li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">📡 <strong>Manejo de errores reactivo</strong> - <code>Stream</code>s y <code>ValueListenable</code> observables para errores</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">🔧 <strong>Filtros flexibles</strong> - Configura estrategias de manejo de errores por command o globalmente</li>
</ul>

Desde escucha básica de errores hasta patrones avanzados de enrutamiento, command_it te da control completo sobre cómo tu app maneja fallos.

::: tip ¡No Te Intimides!
Esta documentación es comprehensiva, pero el manejo de errores en command_it es realmente simple una vez que entiendes el principio central: **los errores son solo datos que fluyen por tu app**. Comienza con [Manejo Básico de Errores](#manejo-basico-de-errores) abajo - puedes escuchar `.errors` igual que cualquier otra propiedad.
:::

## Manejo Básico de Errores

Si la función envuelta dentro de un `Command` lanza una excepción, el command la captura para que tu app no crashee. En su lugar, envuelve el error capturado junto con el valor del parámetro en un objeto `CommandError` y lo asigna a la propiedad `.errors` del command.

### La Propiedad .errors

Los Commands exponen una propiedad `.errors` de tipo `ValueListenable<CommandError?>`:

**Comportamiento:**
- `.errors` se resetea a `null` al inicio de la ejecución (no notifica a listeners)
- `.errors` se establece a `CommandError<TParam>` en fallo (notifica a listeners)
- `CommandError` contiene: `error`, `paramData`, `stackTrace`

#### Patrón 1: Mostrar Estado de Error con watchValue

Observa el valor del error para mostrarlo en tu UI:

```dart
class DataWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final error = watchValue((DataManager m) => m.loadData.errors);

    if (error != null) {
      return Text(
        'Error: ${error.error}',
        style: TextStyle(color: Colors.red),
      );
    }
    return Text('Sin errores');
  }
}
```

#### Patrón 2: Manejar Errores con registerHandler

Usa `registerHandler` para efectos secundarios como mostrar toasts o snackbars:

```dart
class TodoWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Mostrar snackbar con botón de reintentar cuando ocurre error
    registerHandler(
      select: (TodoManager m) => m.loadTodos.errors,
      handler: (context, error, cancel) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error.error}'),
              action: SnackBarAction(
                label: 'Reintentar',
                onPressed: () => di<TodoManager>().loadTodos(error.paramData),
              ),
            ),
          );
        }
      },
    );

    return TodoList();
  }
}
```

#### Patrón 3: Escuchar Directamente en la Definición del Command

Encadena `.listen()` al definir commands para logging o analytics:

```dart
class DataManager {
  late final loadData = Command.createAsyncNoParam<List<Item>>(
    () => api.fetchData(),
    [],
  )..errors.listen((error, _) {
      if (error != null) {
        debugPrint('Carga falló: ${error.error}');
        analytics.logError(error.error, error.stackTrace);
      }
    });
}
```

---

Estos patrones se denominan **manejo local de errores** porque manejan errores para un command específico. Esto te da control granular sobre cómo se manejan los errores de cada command. Para manejar errores de múltiples commands en un solo lugar, ver [Handler de Error Global](#handler-de-error-global) abajo.

::: tip Comportamiento de Limpieza de Errores
La propiedad `.errors` normalmente nunca notifica con un valor `null` a menos que explícitamente llames `clearErrors()`. Normalmente nunca necesitas llamar `clearErrors()` - y si no lo haces, no necesitas agregar verificaciones `if (error != null)` en tus handlers de error. Ver [clearErrors](/es/documentation/command_it/command_properties#clearerrors-limpiar-estado-de-error) para detalles.
:::

::: tip Sin `watch_it`
Para patrones con StatefulWidget usando `.listen()` en `initState`, ver [Sin `watch_it`](/es/documentation/command_it/without_watch_it) para patrones.
:::

### Usando CommandResult

También puedes acceder a errores a través de `.results` que combina todo el estado del command:

```dart
class TodoWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final result = watchValue((TodoManager m) => m.loadTodos.results);

    if (result.hasError) {
      return ErrorWidget(
        error: result.error!,
        query: result.paramData,
        onRetry: () => di<TodoManager>().loadTodos(result.paramData),
      );
    }
    // ... manejar otros estados
  }
}
```

Ver [Command Results](/es/documentation/command_it/command_results) para detalles.

## Handler de Error Global

Establece un handler de error global para capturar todos los errores de commands enrutados por [ErrorFilter](#filtros-de-error):

```dart
static void Function(CommandError<dynamic> error, StackTrace stackTrace)?
  globalExceptionHandler;
```

### Acceso al Contexto del Error

`CommandError<TParam>` proporciona contexto rico:
- `.error` - La excepción real lanzada
- `.commandName` - Nombre/identificador del command (desde `debugName`)
- `.paramData` - Parámetro pasado al command
- `.stackTrace` - Stack trace completo
- `.errorReaction` - Cómo se manejó el error

### Manejando Tipos de Error Específicos

Puedes manejar diferentes tipos de error centralmente en tu handler global. Un patrón común es manejar errores de autenticación haciendo logout y limpiando scopes:

```dart
void setupGlobalExceptionHandler() {
  Command.globalExceptionHandler = (commandError, stackTrace) {
    final error = commandError.error;

    // Manejar errores de auth: logout y limpiar
    if (error is AuthException) {
      // Logout (limpia tokens, estado de usuario, etc.)
      getIt<UserManager>().logout();

      // Pop del scope 'loggedIn' para disponer servicios de sesión
      // Ver: https://flutter-it.dev/documentation/get_it/scopes
      getIt.popScope();

      // Navegación a pantalla de login ocurriría via observer de nivel de app
      // observando userManager.isLoggedIn
      return;
    }

    // Manejar otros errores: log a crash reporter
    crashReporter.logError(error, stackTrace);
  };
}
```

Esto centraliza la limpieza de autenticación - cualquier command que lance `AuthException` automáticamente disparará logout, sin importar dónde se llame.

### Uso con Crash Reporting

<<< @/../code_samples/lib/command_it/global_config_error_handler_example.dart#example

Cuándo se llama al handler global depende de tu configuración de [ErrorFilter](#filtros-de-error). Ver [Filtros Incorporados](#filtros-incorporados) para detalles.

## Filtros de Error

Los filtros de error deciden cómo debe manejarse cada error: por un handler local, el handler global, ambos, o ninguno. En lugar de tratar todos los errores igual, puedes enrutarlos declarativamente basándote en tipo o condiciones.

### ¿Por Qué Usar Filtros de Error?

Diferentes tipos de error necesitan diferente manejo:
- **Errores de validación** → Mostrar al usuario en UI
- **Errores de red** → Lógica de reintento o modo offline
- **Errores de autenticación** → Redirigir a login
- **Errores críticos** → Log a servicio de monitoreo
- Todo sin bloques try/catch dispersos

### Dos Enfoques para Filtrado de Errores

Los Commands soportan dos formas mutuamente exclusivas de especificar lógica de filtrado de errores:

**Enfoque basado en función** (`errorFilterFn`) - Función directa con type-safety en tiempo de compilación:

```dart
typedef ErrorFilterFn = ErrorReaction? Function(
  Object error,
  StackTrace stackTrace,
);

Command.createAsync(
  fetchData,
  [],
  errorFilterFn: (e, s) => e is NetworkException
      ? ErrorReaction.globalHandler
      : null,
  // ¡Firma verificada en tiempo de compilación! ✅
);
```

**Enfoque basado en clase** (`errorFilter`) - Objetos ErrorFilter para lógica compleja:

```dart
Command.createAsync(
  fetchData,
  [],
  errorFilter: PredicatesErrorFilter([
    (e, s) => e is NetworkException ? ErrorReaction.globalHandler : null,
    (e, s) => e is ValidationException ? ErrorReaction.localHandler : null,
  ]),
);
```

command_it proporciona clases de filtro incorporadas (`PredicatesErrorFilter`, `TableErrorFilter`, etc.), pero también puedes [definir las tuyas propias](#errorfilter-personalizado) implementando la interface `ErrorFilter`.

**Diferencias clave:**

| Característica | `errorFilterFn` (Función) | `errorFilter` (Clase) |
|----------------|---------------------------|----------------------|
| Simplicidad | ✅ Función inline directa | Requiere creación de objeto |
| Con parámetros | ❌️ Necesita wrapper lambda | ✅ Puede ser objetos `const` |
| Reutilización | ❌️ Crea nuevo closure cada vez | ✅ Reutiliza misma instancia `const` |
| Mejor para | Filtros simples, únicos | Filtros parametrizados, reutilizables |

::: warning Mutuamente Exclusivos
No puedes usar tanto `errorFilter` como `errorFilterFn` en el mismo command - un assertion lo impide. Elige un enfoque basándote en tus necesidades.
:::

### Enum ErrorReaction

Un ErrorFilter retorna un `ErrorReaction` para especificar el manejo:

| Reacción | Comportamiento |
|----------|----------------|
| **localHandler** | Llama listeners en `.errors`/`.results` |
| **globalHandler** | Llama `Command.globalExceptionHandler` |
| **localAndGlobalHandler** | Llama ambos handlers |
| **firstLocalThenGlobalHandler** | Intenta local, fallback a global (por defecto) |
| **throwException** | Relanza inmediatamente (solo debugging) |
| **throwIfNoLocalHandler** | Lanza si no hay listeners |
| **noHandlersThrowException** | Lanza si no hay handlers presentes |
| **none** | Silencia sin hacer nada |

### Filtros de Error Simples

Filtros `const` incorporados para patrones de enrutamiento comunes:

| Filtro | Comportamiento | Uso |
|--------|----------------|-----|
| **ErrorFilterConstant** | Siempre retorna mismo `ErrorReaction` | `const ErrorFilterConstant(ErrorReaction.none)` |
| **LocalErrorFilter** | Enruta solo a handler local | `const LocalErrorFilter()` |
| **GlobalIfNoLocalErrorFilter** | Intenta local, fallback a global ([por defecto](/es/documentation/command_it/global_configuration#errorfilterdefault)) | `const GlobalIfNoLocalErrorFilter()` |
| **LocalAndGlobalErrorFilter** | Enruta a ambos handlers local y global | `const LocalAndGlobalErrorFilter()` |

**Ejemplo:**
```dart
// Fallo silencioso para sync en background
late final backgroundSync = Command.createAsyncNoParam<void>(
  () => api.syncInBackground(),
  errorFilter: const ErrorFilterConstant(ErrorReaction.none),
);

// Debug: lanzar en error para capturar en debugger
late final debugCommand = Command.createAsync<Data, void>(
  (data) => api.saveCritical(data),
  errorFilter: const ErrorFilterConstant(ErrorReaction.throwException),
);
```

::: tip Entendiendo GlobalIfNoLocalErrorFilter (El Por Defecto)
**Por qué es el por defecto:** El `GlobalIfNoLocalErrorFilter` proporciona enrutamiento inteligente que se adapta a tu código. Retorna `firstLocalThenGlobalHandler`, que funciona así:

**Cómo funciona:**
1. **Verifica si existen listeners locales** - ¿Estás manejando `.errors` o `.results` para este command (listen, watchValue, registerHandler)?
2. **Si SÍ** → Enruta solo a handler local (asume que lo estás manejando)
3. **Si NO** → Fallback a handler global (previene fallos silenciosos)

**Por qué importa:**
```dart
// Ejemplo 1: Tiene handler de error local
class TodoWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Existe listener local
    final error = watchValue((TodoManager m) => m.loadTodos.errors);
    // ✅ Errores enrutan SOLO a handler LOCAL
    if (error != null) return ErrorWidget(error);
    return TodoList();
  }
}

// Ejemplo 2: Sin handler de error local
class DataManager {
  late final loadData = Command.createAsyncNoParam<List<Item>>(
    () => api.fetchData(),
    [],
  );
  // ❌ Sin listeners de .errors/.results
  // ✅ Errores enrutan a handler GLOBAL automáticamente
}
```

Esto previene el error común de olvidar manejar errores - al menos llegarán a tu crash reporter global. Si agregas un handler local después, el handler global automáticamente deja de ser llamado para ese command.

Ver el [diagrama de flujo de manejo de excepciones](#flujo-de-trabajo-de-manejo-de-excepciones) para el flujo de decisión completo.
:::

### ErrorFilter Personalizado

Construye tus propios ErrorFilters para enrutamiento avanzado:

```dart
// Manejar errores de cliente 4xx localmente, dejar 5xx ir a handler global
late final fetchUserCommand = Command.createAsync<String, User>(
  (userId) => api.fetchUser(userId),
  initialValue: User.empty(),
  errorFilter: _ApiErrorFilter([400, 401, 403, 404, 422]),
);

class _ApiErrorFilter implements ErrorFilter {
  final List<int> statusCodes;

  const _ApiErrorFilter(this.statusCodes);

  @override
  ErrorReaction filter(Object error, StackTrace stackTrace) {
    if (error is ApiException && statusCodes.contains(error.statusCode)) {
      return ErrorReaction.localHandler;
    }
    return ErrorReaction.defaulErrorFilter;
  }
}
```

## Más Filtros de Error

:::details PredicatesErrorFilter (Recomendado)

Encadena predicados para coincidir errores por jerarquía de tipos:

<<< @/../code_samples/lib/command_it/error_filter_predicates_example.dart#example

**Cómo funciona:**
1. Los predicados son funciones: `(error, stackTrace) => ErrorReaction?`
2. Retorna la primera reacción no-null
3. Fallback a defecto si ninguno coincide
4. El orden importa - verifica tipos específicos primero

**Patrón:**
```dart
PredicatesErrorFilter([
  (error, stackTrace) => errorFilter<ApiException>(
        error,
        ErrorReaction.localHandler,
      ),
  (error, stackTrace) => errorFilter<ValidationException>(
        error,
        ErrorReaction.localHandler,
      ),
  (error, stackTrace) => ErrorReaction.globalHandler, // Por defecto
])
```

**Prefiere esto** para la mayoría de casos - es más flexible que TableErrorFilter.
:::

:::details TableErrorFilter

Mapea tipos de error a reacciones usando igualdad de tipo exacta:

```dart
errorFilter: TableErrorFilter({
  ApiException: ErrorReaction.localHandler,
  ValidationException: ErrorReaction.localHandler,
  NetworkException: ErrorReaction.globalHandler,
  Exception: ErrorReaction.globalHandler,
})
```

**Limitaciones:**
- Solo coincide tipo de runtime exacto (no jerarquía de tipos)
- No puede distinguir subclases
- Workaround especial para tipo `Exception`

**Cuándo usar:**
- Enrutamiento simple de errores por tipo
- Conjunto conocido de tipos de error
- Sin jerarquías de herencia
:::

## Comportamiento de Errores con runAsync()

Cuando usas `runAsync()` y el command lanza una excepción, **ambas** cosas suceden:

1. **Se llaman los handlers de error** - Los listeners de `.errors` y `globalExceptionHandler` reciben el error (basado en ErrorFilter)
2. **El Future completa con error** - La excepción se relanza al caller

**Importante:** DEBES envolver `runAsync()` en try/catch para prevenir crashes de la app:

```dart
// ✅ BIEN: Captura la excepción relanzada
try {
  final result = await loadCommand.runAsync();
  // Usa result...
} catch (e) {
  // Maneja el error - muestra feedback de UI, log, etc.
  showErrorToast(e.toString());
}

// ❌ MAL: Excepción no manejada crasheará la app
await loadCommand.runAsync(); // ¡Si esto lanza, la app crashea!
```

**Usando ambos try/catch y listener de .errors:**

Si tienes un listener de `.errors` para actualizaciones reactivas de UI, aún necesitas try/catch pero el bloque catch puede estar vacío:

```dart
// Configura listener de error para UI reactiva
loadCommand.errors.listen((error, _) {
  if (error != null) showErrorToast(error.error);
});

// Aún necesita try/catch para prevenir crash
try {
  final result = await loadCommand.runAsync();
  // Usa result...
} catch (e) {
  // Error ya manejado por listener de .errors arriba
  // Catch vacío solo previene el crash
}
```

::: warning ErrorReaction.none No Permitido
Usar `ErrorReaction.none` con `runAsync()` disparará un error de assertion. Como el error sería silenciado, no hay valor con el que completar el Future.
:::

## Cuando los Handlers de Error Lanzan Excepciones

Los handlers de error son código Dart regular - pueden fallar también. Cuando tu handler de error hace llamadas API async o procesa datos, esas operaciones pueden lanzar excepciones.

### El Problema

Los handlers de error que realizan efectos secundarios pueden fallar en muchos escenarios:

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">⚠️ <strong>Operaciones async</strong> - Logging a servicios remotos que podrían hacer timeout</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">⚠️ <strong>Procesamiento de datos</strong> - Errores de parsing o formateo</li>
</ul>

Sin manejo apropiado, estas excepciones secundarias podrían crashear tu app o pasar desapercibidas.

### reportErrorHandlerExceptionsToGlobalHandler

Controla si las excepciones lanzadas dentro de handlers de error se reportan al handler global:

<<< @/../code_samples/lib/command_it/error_handler_exception_example.dart#example

**Configuración:**
```dart
// En main() o inicialización de app (esto es el por defecto)
Command.reportErrorHandlerExceptionsToGlobalHandler = true;
```

Ver [Configuración Global - reportErrorHandlerExceptionsToGlobalHandler](/es/documentation/command_it/global_configuration#reporterrorhandlerexceptionstoglobalhandler) para detalles.

### Cómo Funciona

**Con `true` (por defecto, recomendado)**:

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Las excepciones en handlers de error se capturan automáticamente</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Se envían a <code>Command.globalExceptionHandler</code></li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ El error original del command se preserva en <code>CommandError.originalError</code></li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Tu app no crashea por código buggy de manejo de errores</li>
</ul>

**Con `false`**:

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Solo se loguea por el logger de errores de Flutter</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ No llegará a tu handler de excepciones global</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Menos visibilidad de bugs en handlers de error</li>
</ul>

::: tip Cómo Funciona Esto
La propiedad `.errors` es un `CustomValueNotifier` de **listen_it**, que proporciona la capacidad incorporada de capturar excepciones lanzadas por listeners. Puedes usar esta misma característica en tu propio código con `CustomValueNotifier` - ver [listen_it CustomValueNotifier](/es/documentation/listen_it/listen_it#customvaluenotifier) para detalles.
:::

::: tip Recomendación de Producción
Siempre mantén `reportErrorHandlerExceptionsToGlobalHandler: true` en producción. Los fallos de handlers de error indican bugs en tu código de manejo de errores que necesitan atención inmediata.
:::

## Stream de Errores Globales

`Stream` estático en la clase `Command` para todos los errores de commands enrutados al handler global:

```dart
static Stream<CommandError<dynamic>> get globalErrors
```

### Resumen

Un stream de broadcast que emite `CommandError<dynamic>` para cada error que dispararía `globalExceptionHandler`. Perfecto para monitoreo centralizado de errores, analytics, crash reporting, y notificaciones de UI globales.

### Comportamiento del Stream

**Emite cuando:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅️ <code>ErrorFilter</code> enruta error a handler global (basado en configuración del filtro)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅️ El handler de error mismo lanza una excepción (si <code>reportErrorHandlerExceptionsToGlobalHandler</code> es <code>true</code>)</li>
</ul>

**NO emite cuando:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Se usa <code>reportAllExceptions</code> (característica solo de debug, no para UI de producción)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ El error se maneja puramente localmente (<code>LocalErrorFilter</code> con listeners locales)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ El filtro de error retorna <code>ErrorReaction.none</code> o <code>ErrorReaction.throwException</code></li>
</ul>

### Casos de Uso

**1. Toasts de Error Globales (integración con `watch_it`)**

```dart
class MyApp extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    registerStreamHandler<Stream<CommandError>, CommandError>(
      target: Command.globalErrors,
      handler: (context, snapshot, cancel) {
        if (snapshot.hasData) {
          final error = snapshot.data!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${error.error}')),
          );
        }
      },
    );
    return MaterialApp(home: HomePage());
  }
}
```

**2. Logging Centralizado y Analytics**

Usa transformadores de stream para filtrar y enrutar tipos de error específicos:

```dart
void setupErrorMonitoring() {
  // Rastrear solo errores de red para analytics de reintento
  Command.globalErrors
      .where((error) => error.error is NetworkException)
      .listen((error) {
    analytics.logEvent('network_error', parameters: {
      'command': error.commandName ?? 'unknown',
      'error_code': (error.error as NetworkException).statusCode,
    });
  });

  // Log de errores críticos a crash reporter
  Command.globalErrors
      .where((error) => error.error is CriticalException)
      .listen((error) {
    crashReporter.logCritical(
      error.error,
      stackTrace: error.stackTrace,
      command: error.commandName,
    );
  });

  // Métricas generales de error (todos los errores)
  Command.globalErrors.listen((error) {
    metrics.incrementCounter('command_errors_total');
    metrics.recordErrorType(error.error.runtimeType.toString());
  });
}
```

### Características Clave

- **Stream de broadcast**: Soporta múltiples listeners
- **No puede cerrarse**: El stream es gestionado por command_it, no por código de usuario
- **Enfocado en producción**: Errores solo de debug de `reportAllExceptions` están excluidos
- **No emite eventos null**: A diferencia de `ValueListenable<CommandError?>`, el stream solo emite errores reales

### Relación con globalExceptionHandler

Ambos reciben los mismos errores, pero sirven propósitos diferentes:

| Característica | `globalExceptionHandler` | `globalErrors` |
|----------------|-------------------------|----------------|
| Tipo | Función callback | Stream |
| Propósito | Manejo inmediato de errores | Monitoreo reactivo de errores |
| Múltiples handlers | No (handler único) | Sí (múltiples listeners) |
| Integración con `watch_it` | No | Sí (`registerStreamHandler`, `watchStream`) |
| Mejor para | Crash reporting, logging | Notificaciones de UI, analytics |

::: tip Patrón Típico: Usar Ambos Juntos
Usa `globalExceptionHandler` para efectos secundarios inmediatos como crash reporting y logging, mientras que el stream `globalErrors` es perfecto para actualizaciones de UI reactivas usando `watch_it` (`registerStreamHandler` o `watchStream`). Esta separación mantiene tu manejo de errores limpio y enfocado.
:::

## Flujo de Trabajo de Manejo de Excepciones

El flujo general de manejo de excepciones:

![Flujo de Trabajo de Manejo de Excepciones](/images/exception_handling_simple.svg)

Para el flujo técnico completo con todos los puntos de decisión, ver el [diagrama completo de manejo de excepciones](/images/exception_handling_full.svg).

**Puntos clave:**
1. **Verificaciones obligatorias**: AssertionErrors y flags de debug pueden bypasear filtrado
2. **ErrorFilter**: Determina enrutamiento (local, global, throw, none)
3. **Handlers locales**: Listeners en `.errors`/`.results` se llaman si están configurados
4. **Handler global**: Se llama basándose en ErrorReaction (emite a stream + llama callback)
5. **Excepciones de handler**: Si el handler de error lanza, puede enrutarse a handler global con `originalError`

## Patrones de Enrutamiento de Errores

### Patrón 1: Errores de Usuario vs Sistema

```dart
errorFilter: PredicatesErrorFilter([
  // Errores para el usuario: mostrar en UI
  (error, _) => errorFilter<ValidationException>(
        error,
        ErrorReaction.localHandler,
      ),
  (error, _) => errorFilter<AuthException>(
        error,
        ErrorReaction.localHandler,
      ),

  // Errores de sistema: log y reportar
  (error, _) => ErrorReaction.globalHandler,
])
```

### Patrón 2: Reintentable vs Fatal

```dart
errorFilter: PredicatesErrorFilter([
  // Timeouts de red: handler local con UI de reintento
  (error, _) {
    if (error is ApiException && error.statusCode == 408) {
      return ErrorReaction.localHandler;
    }
    return null;
  },

  // Errores de auth: handler global (logout centralizado & limpieza de scope)
  (error, _) => errorFilter<AuthException>(
        error,
        ErrorReaction.globalHandler,
      ),

  // Otros: ambos handlers
  (error, _) => ErrorReaction.localAndGlobalHandler,
])
```

### Patrón 3: Configuración Por Command

```dart
class DataManager {
  // Command crítico: siempre reportar a handler global
  late final saveCriticalData = Command.createAsync<Data, void>(
    (data) => api.saveCritical(data),
    errorFilter: const ErrorFilterConstant(ErrorReaction.globalHandler),
  );

  // Sync en background: fallo silencioso (no molestar al usuario)
  late final backgroundSync = Command.createAsyncNoParam<void>(
    () => api.syncInBackground(),
    errorFilter: const ErrorFilterConstant(ErrorReaction.none),
  );

  // Commands normales: usar por defecto (local luego global)
  late final fetchData = Command.createAsyncNoParam<List<Data>>(
    () => api.fetch(),
    initialValue: [],
    // Sin errorFilter = usa Command.errorFilterDefault
  );
}
```

## Actualizaciones Optimistas con Auto-Rollback

`UndoableCommand` proporciona rollback automático en fallo, perfecto para actualizaciones optimistas de UI. Cuando una operación falla, el command automáticamente restaura el estado anterior - no se necesita recuperación manual de errores.

Para detalles completos sobre implementar actualizaciones optimistas, rollback automático, y patrones de undo/redo manual, ver [Actualizaciones Optimistas](/es/documentation/command_it/optimistic_updates).

## Configuración Global de Errores

Configura el comportamiento de manejo de errores globalmente en tu función `main()`:

```dart
void main() {
  // Filtro por defecto para todos los commands
  Command.errorFilterDefault = const GlobalIfNoLocalErrorFilter();

  // Handler global
  Command.globalExceptionHandler = (error, stackTrace) {
    loggingService.logError(error, stackTrace);
  };

  // AssertionErrors siempre lanzan (ignoran filtros)
  Command.assertionsAlwaysThrow = true; // por defecto

  // Reportar TODAS las excepciones (sobrescribir filtros)
  Command.reportAllExceptions = false; // por defecto

  // Reportar excepciones de handler de error a handler global
  Command.reportErrorHandlerExceptionsToGlobalHandler = true; // por defecto

  // Capturar stack traces detallados
  Command.detailedStackTraces = true; // por defecto

  runApp(MyApp());
}
```

### errorFilterDefault

ErrorFilter por defecto usado cuando no se especifica filtro por command:

```dart
static ErrorFilter errorFilterDefault = const GlobalIfNoLocalErrorFilter();
```

**Por defecto:** `GlobalIfNoLocalErrorFilter()` - Enrutamiento inteligente que intenta handlers locales primero, fallback a global

Usa cualquiera de los [filtros predefinidos](#filtros-de-error-simples) o [define el tuyo propio](#errorfilter-personalizado).

### assertionsAlwaysThrow

AssertionErrors bypasean todos los ErrorFilters y siempre se relanzan:

```dart
static bool assertionsAlwaysThrow = true; // por defecto
```

**Por defecto:** `true` (recomendado)

**Por qué existe:** AssertionErrors indican errores de programación (como fallos de `assert(condition)`). Deberían crashear inmediatamente durante desarrollo para capturar bugs, no ser silenciados por filtros de error.

**Recomendación:** Mantén esto `true` para capturar bugs temprano en desarrollo.

### reportAllExceptions

Asegura que cada error llame a `globalExceptionHandler`, sin importar la configuración de ErrorFilter:

```dart
static bool reportAllExceptions = false; // por defecto
```

**Por defecto:** `false`

**Cómo funciona:** Cuando es `true`, **cada error** llama a `globalExceptionHandler` inmediatamente, **además del** procesamiento normal de ErrorFilter. Los ErrorFilters aún se ejecutan y controlan handlers locales.

**Patrón común - Debug vs Producción:**
```dart
// En main.dart
Command.reportAllExceptions = kDebugMode;
```

**Qué hace esto:**
- Desarrollo: TODOS los errores llegan a handler global para visibilidad
- Producción: Solo errores enrutados por ErrorFilter llegan a handler global

**Cuándo usar:**
- Debugging de manejo de errores - asegurar que ningún error se silencia
- Modo desarrollo - ver todos los errores sin importar ErrorFilter
- Verificar crash reporting - confirmar que todos los errores llegan a analytics

::: warning Potenciales Llamadas Duplicadas
```dart
Command.reportAllExceptions = true;
Command.errorFilterDefault = const GlobalErrorFilter();

// Resultado: ¡globalExceptionHandler llamado DOS VECES por cada error!
// 1. Desde reportAllExceptions
// 2. Desde ErrorFilter
```
En producción, usa `reportAllExceptions` O ErrorFilters que llamen a global, no ambos.
:::

### reportErrorHandlerExceptionsToGlobalHandler

Reporta excepciones lanzadas por handlers de error a `globalExceptionHandler`:

```dart
static bool reportErrorHandlerExceptionsToGlobalHandler = true; // por defecto
```

**Por defecto:** `true` (recomendado) - Los handlers de error también pueden tener bugs; esto previene que código de manejo de errores crashee tu app

Ver [Cuando los Handlers de Error Lanzan Excepciones](#cuando-los-handlers-de-error-lanzan-excepciones) para detalles completos, ejemplos, y cómo funciona.

### detailedStackTraces

Limpia stack traces filtrando ruido de framework:

```dart
static bool detailedStackTraces = true; // por defecto
```

**Por defecto:** `true` (recomendado)

**Qué hace:** Usa el paquete `stack_trace` para filtrar y simplificar stack traces.

**Sin detailedStackTraces** - stack trace crudo con 50+ líneas de internos de framework

**Con detailedStackTraces** - filtrado y simplificado, mostrando solo frames relevantes

**Qué se filtra:**
- Frames relacionados con Zone (framework async)
- Internos del paquete `stack_trace`
- Frames del método interno `_run` de command_it

**Rendimiento:** El procesamiento de stack trace tiene overhead mínimo. Solo deshabilita si profiling muestra que es un cuello de botella (raro).

::: tip Ver También
Para configuración global no relacionada con errores (como `loggingHandler`, `useChainCapture`), ver [Configuración Global](/es/documentation/command_it/global_configuration).
:::

## Filtros de Error vs Try/Catch

**❌️ Enfoque tradicional:**

```dart
Future<void> loadData() async {
  try {
    final data = await api.fetch();
    // Manejar éxito
  } on ValidationException catch (e) {
    // Mostrar al usuario
  } on ApiException catch (e) {
    // Log a servicio
  } catch (e) {
    // Handler genérico
  }
}
```

**✅ Con ErrorFilters:**

```dart
late final loadCommand = Command.createAsyncNoParam<List<Data>>(
  () => api.fetch(),
  initialValue: [],
  errorFilter: PredicatesErrorFilter([
    (e, _) => errorFilter<ValidationException>(e, ErrorReaction.localHandler),
    (e, _) => errorFilter<ApiException>(e, ErrorReaction.globalHandler),
    (e, _) => ErrorReaction.localAndGlobalHandler,
  ]),
);

// Errores enrutados automáticamente
loadCommand.errors.listen((error, _) {
  if (error != null) showErrorDialog(error.error.toString());
});
```

**Beneficios:**
- Enrutamiento declarativo de errores
- Lógica de manejo centralizada
- Actualizaciones de UI automáticas via ValueListenable
- Sin bloques try/catch dispersos
- Enrutamiento de errores testeable

## Debugging de Manejo de Errores

**Habilitar stack traces detallados:**
```dart
Command.detailedStackTraces = true;
```

**Log de todas las decisiones de enrutamiento de errores:**
```dart
Command.globalExceptionHandler = (error, stackTrace) {
  debugPrint('Handler global: $error');
  debugPrint('Stack: $stackTrace');
};

// En tus predicados
PredicatesErrorFilter([
  (error, stackTrace) {
    debugPrint('Verificando error: ${error.runtimeType}');
    return errorFilter<ApiException>(error, ErrorReaction.localHandler);
  },
])
```

**Probar escenarios de error:**
```dart
// Forzar errores en desarrollo
final command = Command.createAsyncNoParam<Data>(
  () async {
    if (kDebugMode) {
      throw ApiException('Error de prueba');
    }
    return await api.fetch();
  },
  initialValue: Data.empty(),
  errorFilter: yourFilter,
);
```

**Log de todos los errores de command:**
```dart
command.errors.listen((error, _) {
  if (error != null) {
    debugPrint('''
      Error de Command:
      - Error: ${error.error}
      - Tipo: ${error.error.runtimeType}
      - Param: ${error.paramData}
      - Stack: ${error.stackTrace}
    ''');
  }
});
```

### Encontrar Handlers de Error Faltantes Durante Desarrollo

Establece el filtro de error por defecto para lanzar mientras pruebas manualmente tu app para capturar errores no manejados inmediatamente:

```dart
void main() {
  // Durante desarrollo, hacer que errores no manejados crasheen la app
  if (kDebugMode) {
    Command.errorFilterDefault = const ErrorFilterConstant(
      ErrorReaction.throwException,
    );
  }

  runApp(MyApp());
}
```

**Qué hace esto:**
- Cualquier error de command sin listener local de `.errors` o `.results` lanzará
- La app crashea inmediatamente, mostrándote exactamente qué command carece de manejo de errores
- Te fuerza a agregar manejo de errores antes de poder probar esa característica
- Solo activo en modo debug - producción usa enrutamiento normal de errores

**Ejemplo:**
```dart
// Sin manejo de errores - la app crasheará cuando esto falle
final loadData = Command.createAsyncNoParam<Data>(
  () => api.fetch(),
  initialValue: Data.empty(),
);

// ✅ Agrega manejo de errores para prevenir crash:
final loadData = Command.createAsyncNoParam<Data>(
  () => api.fetch(),
  initialValue: Data.empty(),
)..errors.listen((error, _) {
    if (error != null) {
      showErrorDialog(error.error.toString());
    }
  });
```

**Por qué esto ayuda:**
- Captura handlers de error faltantes tan pronto como disparas ese path de código
- Previene enviar características sin manejo de errores
- Hace el manejo de errores un requisito, no algo para después
- Remueve la verificación `if (kDebugMode)` una vez que todos los commands tienen handlers

::: tip
Este es un modo de desarrollo estricto. Una vez que hayas verificado que todos los commands tienen manejo de errores apropiado, cambia de vuelta al `GlobalIfNoLocalErrorFilter()` por defecto que proporciona mejor comportamiento de fallback.
:::

## Errores Comunes

### ❌️ Olvidar escuchar .errors

```dart
// ErrorFilter usa localHandler pero nada escucha
errorFilter: const LocalErrorFilter()
// Error: En modo debug, assertion lanza si no hay listeners
```

### ❌️ Orden incorrecto en PredicatesErrorFilter

```dart
// MAL: Exception general antes de tipos específicos
PredicatesErrorFilter([
  (e, _) => errorFilter<Exception>(e, ErrorReaction.globalHandler),
  (e, _) => errorFilter<ApiException>(e, ErrorReaction.localHandler), // ¡Nunca se alcanza!
])
```

```dart
// CORRECTO: Tipos específicos primero
PredicatesErrorFilter([
  (e, _) => errorFilter<ApiException>(e, ErrorReaction.localHandler),
  (e, _) => errorFilter<Exception>(e, ErrorReaction.globalHandler),
])
```

### ❌️ No manejar errores limpiados

::: tip Solo Necesario Si Usas clearErrors()
Esto solo es un problema si explícitamente llamas [clearErrors()](/es/documentation/command_it/command_properties#clearerrors-limpiar-estado-de-error). Por defecto, `.errors` [nunca notifica con null](#comportamiento-de-limpieza-de-errores), así que no necesitas verificaciones de null.
:::

```dart
// Si usas clearErrors(), maneja null:
command.errors.listen((error, _) {
  if (error != null) {
    showErrorDialog(error.error.toString());
  }
});
```

## Ver También

- [Propiedades del Command](/es/documentation/command_it/command_properties) — La propiedad `.errors`
- [Command Results](/es/documentation/command_it/command_results) — Usando errores con CommandResult
- [Fundamentos de Command](/es/documentation/command_it/command_basics) — Creando commands
- [Tipos de Command](/es/documentation/command_it/command_types) — Parámetros de filtro de error
- [Mejores Prácticas](/es/documentation/command_it/best_practices) — Patrones de manejo de errores en producción
