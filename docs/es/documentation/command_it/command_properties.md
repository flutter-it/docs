# Propiedades del Command

Los Commands exponen múltiples propiedades `ValueListenable` para diferentes aspectos de la ejecución. Aprende cuándo y cómo usar cada una.

## Resumen

### Propiedades de Instancia

Cada command proporciona estas propiedades observables:

| Propiedad | Tipo | Propósito |
|-----------|------|-----------|
| [**value**](#value---el-command-mismo) | `TResult` | Último resultado exitoso |
| [**isRunning**](#isrunning---estado-de-ejecucion-async) | `ValueListenable<bool>` | Estado de ejecución async (solo async) |
| [**isRunningSync**](#isrunningsync---estado-sincrono) | `ValueListenable<bool>` | Estado de ejecución sync |
| [**canRun**](#canrun---estado-combinado) | `ValueListenable<bool>` | Restricción + running combinados |
| [**errors**](#errors---notificaciones-de-error) | `ValueListenable<CommandError?>` | Notificaciones de error |
| [**results**](#results---todos-los-datos-combinados) | `ValueListenable<CommandResult>` | Todos los datos combinados |
| [**errorsDynamic**](#errorsdynamic---tipo-de-error-dinamico) | `ValueListenable<CommandError<dynamic>?>` | Errores con tipo dynamic |
| [**name**](#name---identificador-de-debug) | `String?` | Identificador de nombre de debug |
| [**clearErrors()**](#clearerrors---limpiar-estado-de-error) | `void` | Limpiar estado de error manualmente |

### Configuración Global

Propiedades estáticas que afectan a todos los commands en la app:

| Propiedad | Tipo | Por Defecto | Propósito |
|-----------|------|-------------|-----------|
| [**globalExceptionHandler**](#globalexceptionhandler) | `Function?` | `null` | Handler de errores global para todos los commands |
| [**errorFilterDefault**](#errorfilterdefault) | `ErrorFilter` | `ErrorHandlerGlobalIfNoLocal()` | Filtro de error por defecto |
| [**assertionsAlwaysThrow**](#assertionsalwaysthrow) | `bool` | `true` | AssertionErrors bypasean filtros |
| [**reportAllExceptions**](#reportallexceptions) | `bool` | `false` | Sobrescribir filtros, reportar todos los errores |
| [**detailedStackTraces**](#detailedstacktraces) | `bool` | `true` | Stack traces mejorados |
| [**loggingHandler**](#logginghandler) | `Function?` | `null` | Handler para todas las ejecuciones de commands |
| [**reportErrorHandlerExceptionsToGlobalHandler**](#reporterrorhandlerexceptionstoglobalhandler) | `bool` | `true` | Reportar excepciones de error handler |
| [**useChainCapture**](#usechaincapture) | `bool` | `false` | Trazas detalladas experimentales |

::: warning Commands Sync e isRunning
**Acceder a `.isRunning` en commands sync lanza un assertion error.** Los commands sync ejecutan inmediatamente sin dar tiempo a la UI para reaccionar, así que rastrear el estado de ejecución no tiene sentido.

Usa `.isRunningSync` en su lugar si necesitas un booleano para restricciones u otros propósitos - siempre devuelve `false` para commands sync y funciona tanto para sync como async.
:::

## value - El Command Mismo

El command **es** un `ValueListenable<TResult>`. Publica el último resultado exitoso:

```dart
final loadCommand = Command.createAsyncNoParam<List<Todo>>(
  () => api.fetchTodos(),
  initialValue: [],
);

// El Command es ValueListenable<List<Todo>>
ValueListenableBuilder<List<Todo>>(
  valueListenable: loadCommand, // El command mismo
  builder: (context, todos, _) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) => TodoTile(todos[index]),
    );
  },
)
```

**Cuándo usar:**
- Mostrar los datos del resultado
- Casos simples donde solo te importa el éxito
- Caso de uso más común

**Nota:** Solo se actualiza en completación exitosa. No se actualiza durante la ejecución o en errores.

::: tip Establecer .value Directamente
Puedes establecer `.value` directamente para actualizar o resetear el resultado del command:

```dart
// Limpiar el resultado del command
loadCommand.value = [];

// Establecer un valor específico
loadCommand.value = [Todo(id: 1, title: 'Default')];
```

**Comportamiento:**
- Establecer `.value` automáticamente dispara `notifyListeners()` y reconstruye la UI
- Por defecto (sin `notifyOnlyWhenValueChanges`), los listeners son notificados incluso si el nuevo valor es igual al valor anterior
- Con `notifyOnlyWhenValueChanges: true`, solo notifica si el valor realmente cambió

**Cuándo usar:**
- Resetear command a estado inicial/vacío
- Establecer un valor cacheado o por defecto sin ejecutar el command
- Limpiar estado de error estableciendo un valor conocido bueno

**Nota:** Esto bypasea la función del command - usa `.run()` si quieres ejecutar la lógica del command.
:::

## isRunning - Estado de Ejecución Async

Rastrea si un command async se está ejecutando actualmente:

<<< @/../code_samples/lib/command_it/loading_state_watch_it_example.dart#example

**Cuándo usar:**
- Mostrar indicadores de carga
- Deshabilitar botones durante la ejecución
- Mostrar mensajes "Procesando..."

**Limitaciones importantes:**
- **Solo commands async** - funciones `createAsync*`
- Lanza assertion si se accede en commands sync
- Se actualiza **asíncronamente** - breve delay antes de true

### ¿Por Qué Actualizaciones Async?

`isRunning` usa notificaciones asíncronas (via `asyncNotification: true` en `CustomValueNotifier`) para evitar condiciones de carrera. La actualización ocurre después de un breve delay:

```dart
command.run();
print(command.isRunning.value); // ¡Aún false!

await Future.microtask(() {});
print(command.isRunning.value); // Ahora true
```

**Implicación:**
- Usa `isRunning` cuando quieras actualizar elementos de UI (está diseñado para actualizaciones de UI)
- Usa `isRunningSync` si necesitas cambios de estado inmediatos para restricciones de command o lógica de negocio

## isRunningSync - Estado Síncrono

Versión síncrona de `isRunning`, actualizada inmediatamente:

```dart
command.run();
print(command.isRunningSync.value); // Inmediatamente true
```

**Cuándo usar:**
- **Como restricción para otros commands** (previene condiciones de carrera)
- Cuando necesitas estado inmediato para lógica de negocio (no para UI)

```dart
final saveCommand = Command.createAsync<Data, void>(
  (data) => api.save(data),
  restriction: loadCommand.isRunningSync, // No puede guardar mientras carga
);
```

**¿Por qué no para UI?**
`isRunningSync` se actualiza inmediatamente cuando un command se ejecuta. Si un botón dispara un command, `isRunningSync` cambia síncronamente, lo cual dispara un rebuild durante la fase de build y lanza una excepción de Flutter. Usa `isRunning` para actualizaciones de UI - sus notificaciones async previenen este problema.

## canRun - Estado Combinado

Combina automáticamente `!isRunning && !restriction`:

```dart
final isLoggedIn = ValueNotifier<bool>(false);

final deleteCommand = Command.createAsync<String, void>(
  (id) => api.delete(id),
  restriction: isLoggedIn.map((logged) => !logged),
);

// canRun es true cuando:
// 1. NO está ejecutándose
// 2. NO está restringido (isLoggedIn == true)
ValueListenableBuilder<bool>(
  valueListenable: deleteCommand.canRun,
  builder: (context, canRun, _) {
    return ElevatedButton(
      onPressed: canRun ? () => deleteCommand('123') : null,
      child: Text('Eliminar'),
    );
  },
)
```

**Cuándo usar:**
- Habilitar/deshabilitar botones basándose en múltiples condiciones
- Una sola propiedad en lugar de combinar manualmente
- Más simple que chequeos de `isRunning` + `restriction`

**Fórmula:** `canRun = !isRunning.value && !restriction.value`

## errors - Notificaciones de Error

Notifica cuando ocurren errores durante la ejecución:

**Comportamiento:**
- Se establece a `null` al inicio de la ejecución (limpia error previo sin notificación)
- Notifica con `CommandError<TParam>` si la función lanza
- `CommandError` contiene:
  - `error`: La excepción lanzada
  - `paramData`: Parámetro pasado al command
  - `stackTrace`: Stack trace (mejorado si `Command.detailedStackTraces` es true)

**Cuándo usar:**
- Mostrar diálogos de error
- Mostrar mensajes de error
- Registrar errores en analytics
- Manejo de errores simple sin filtros

**Con `watch_it`:**

```dart
class SaveWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final error = watchValue((DataManager m) => m.saveCommand.errors);

    // Mostrar mensaje de error si está presente
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => di<DataManager>().saveCommand(data),
          child: Text('Guardar'),
        ),
        if (error != null)
          ErrorBanner(
            message: error.error.toString(),
            onDismiss: () => di<DataManager>().saveCommand.clearErrors(),
          ),
      ],
    );
  }
}
```

**Sin `watch_it`:** Ver [Usando Commands sin `watch_it` - Manejo de Errores](/es/documentation/command_it/without_watch_it#manejo-de-errores)

## results - Todos los Datos Combinados

Combina estado de ejecución, datos de resultado, errores y parámetros en un solo observable:

```dart
ValueListenableBuilder<CommandResult<TParam, TResult>>(
  valueListenable: command.results,
  builder: (context, result, _) {
    if (result.isRunning) return CircularProgressIndicator();
    if (result.hasError) return ErrorWidget(result.error);
    return DataWidget(result.data);
  },
)
```

**Cuándo usar:**
- Un solo `ValueListenableBuilder` en lugar de múltiples builders anidados
- Necesitas estado comprehensivo (running, data, error) en un solo lugar
- Quieres datos del parámetro para mensajes de error o lógica de reintento

**Ver [Command Results](/es/documentation/command_it/command_results) para la estructura completa de CommandResult, ejemplos y el parámetro `includeLastResultInCommandResults`.**

## errorsDynamic - Tipo de Error Dinámico

Igual que `errors` pero con tipo de error dynamic:

```dart
ValueListenable<CommandError<dynamic>?> get errorsDynamic => _errors;
```

**Cuándo usar:**
- Fusionar listeners de errores de commands con diferentes tipos de parámetros
- Manejo de errores compartido entre múltiples commands

```dart
// Combinar errores de diferentes tipos de command
final saveCommand = Command.createAsync<Data, void>(...);
final deleteCommand = Command.createAsync<String, void>(...);

// Fusionar errores en un solo stream usando listen_it
[saveCommand.errorsDynamic, deleteCommand.errorsDynamic]
  .merge()
  .where((error) => error != null)
  .listen((error, _) {
    showErrorDialog(error!.error.toString());
  });
```

## clearErrors() - Limpiar Estado de Error

Limpia manualmente el estado de error y dispara listeners:

```dart
void clearErrors()
```

**Comportamiento:**
- Establece `errors.value` a `null`
- Explícitamente llama a `notifyListeners()` para actualizar la UI

**Cuándo usar:**
- Estás observando errores en UI y quieres ocultar el display de error sin esperar a la próxima ejecución
- Implementando flujos de recuperación de error personalizados

```dart
// Ejemplo: Banner de error descartable
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final error = watchValue((Manager m) => m.command.errors);

    return Column(
      children: [
        if (error != null)
          ErrorBanner(
            error: error.error.toString(),
            onDismiss: () => di<Manager>().command.clearErrors(),
          ),
        // ... resto de UI
      ],
    );
  }
}
```

::: tip Usando listen/registerHandler - No Se Necesita Clear
Si usas `.listen()` o `registerHandler()` para observar errores, solo se llaman cuando aparece un nuevo error (no cuando se limpia a null). En este caso, típicamente no necesitas `clearErrors()` para nada:

**Con `.listen()`:**
```dart
command.errors.listen((error, _) {
  showSnackBar(error!.error.toString()); // Se muestra una vez por error, nunca null
});
```

**Con `registerHandler()` (`watch_it`):**
```dart
registerHandler((Manager m) => m.command.errors, (context, error, cancel) {
  showSnackBar(error!.error.toString()); // Se muestra una vez por error, nunca null
});
```

Ya que los listeners solo se disparan en errores reales (nunca null), cada error se muestra una vez y no necesitas limpiar manualmente.

**Importante:** Si llamas `clearErrors()` en otro lugar de tu código, los handlers recibirán `null` cuando el error se limpie. En ese caso, añade un null check:

```dart
command.errors.listen((error, _) {
  if (error != null) {
    showSnackBar(error.error.toString());
  }
});
```

**Usa `clearErrors()` cuando:**
- Observas errores con `watchValue` - se reconstruye en cada cambio, necesita clear manual para ocultar UI
- Mostrando condicionalmente widgets de error basándose en estado de error
:::

::: tip Limpiando Errores Sin Notificación
También puedes establecer `command.errors.value = null` directamente para limpiar el error SIN disparar listeners. Esto es útil si quieres resetear silenciosamente el estado de error.

**¿Por qué modo manual?** El notifier `errors` usa `CustomNotifierMode.manual` porque los commands automáticamente lo establecen a `null` al inicio de cada ejecución (para limpiar errores previos). Esto no debería disparar listeners - solo errores reales deberían notificar.

Usa `clearErrors()` cuando quieras actualizaciones de UI (ej., descartar mensajes de error). Usa asignación directa cuando no.
:::

## name - Identificador de Debug

Devuelve el nombre de debug establecido via el parámetro `debugName`:

```dart
String? get name
```

**Cuándo usar:**
- Logging y debugging
- Identificar qué command disparó un error
- Disponible en `CommandError.commandName` y handlers de logging

```dart
final saveCommand = Command.createAsync<Data, void>(
  (data) => api.save(data),
  debugName: 'SaveUserData',
);

Command.globalExceptionHandler = (error, stackTrace) {
  print('Command ${error.commandName} falló: ${error.error}');
  // Output: "Command SaveUserData falló: ..."
};
```

## Eligiendo la Propiedad Correcta

**Para display simple de éxito:**
```dart
ValueListenableBuilder(valueListenable: command, ...)
```

**Para estados de carga:**
```dart
ValueListenableBuilder(valueListenable: command.isRunning, ...)
```

**Para habilitar/deshabilitar botones:**
```dart
ValueListenableBuilder(valueListenable: command.canRun, ...)
```

**Para manejo de errores:**
```dart
command.errors.listen((error, _) => showError(error))
```

**Para estado comprehensivo:**
```dart
ValueListenableBuilder(valueListenable: command.results, ...)
```

## Ver También

- [Fundamentos de Command](/es/documentation/command_it/command_basics) — Creando y ejecutando commands
- [Command Results](/es/documentation/command_it/command_results) — Inmersión profunda en CommandResult
- [Configuración Global](/es/documentation/command_it/global_configuration) — Referencia de propiedades estáticas
- [Manejo de Errores](/es/documentation/command_it/error_handling) — Manejando errores
- [Restricciones de Command](/es/documentation/command_it/restrictions) — Ejecución condicional
