# Command Results

Inmersión profunda en `CommandResult` - el objeto de estado comprehensivo que combina estado de ejecución, datos de resultado, errores y parámetros en una sola propiedad observable.

## Resumen

La propiedad `.results` es un `ValueListenable<CommandResult<TParam, TResult>>` que proporciona toda la información de ejecución del command en una sola clase de valor. Esta propiedad se actualiza en cada cambio de estado del command (running, éxito, error):

```dart
class CommandResult<TParam, TResult> {
  final TParam? paramData;             // Parámetro pasado al command
  final TResult? data;                 // Valor del resultado
  final bool isUndoValue;              // True si es de una operación de undo
  final Object? error;                 // Error si se lanzó
  final bool isRunning;                // Estado de ejecución
  final ErrorReaction? errorReaction;  // Cómo se manejó el error (si ocurrió)
  final StackTrace? stackTrace;        // Stack trace del error (si ocurrió)

  // Getters de conveniencia
  bool get hasData => data != null;
  bool get hasError => error != null && !isUndoValue;  // Excluye errores de undo
  bool get isSuccess => !isRunning && !hasError;
}
```

**Acceso via la propiedad `.results`:**

```dart
ValueListenableBuilder<CommandResult<String, List<Todo>>>(
  valueListenable: command.results,
  builder: (context, result, _) {
    // Usa result.data, result.error, result.isRunning, etc.
  },
)
```

## Cuándo Usar CommandResult

<p>Usa <code>.results</code> cuando necesites:</p>

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Todo el estado en un solo lugar (running, data, error)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Datos del parámetro para mensajes de error</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Un solo builder en lugar de múltiples builders anidados</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Manejo de estado comprehensivo</li>
</ul>

**Usa propiedades individuales cuando:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">Solo necesitas los datos: Usa el command mismo (<code>ValueListenable&lt;TResult&gt;</code>)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">Solo necesitas el estado de carga: Usa `.isRunning`</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">Solo necesitas errores: Usa `.errors`</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">Quieres evitar rebuilds en cada cambio de estado (las propiedades individuales solo se actualizan para su estado específico)</li>
</ul>

## Transiciones de Estado del Result

### Flujo Normal (Éxito)

```
Inicial:    { data: null, error: null, isRunning: false }
            ↓ command.run('query')
Running:    { data: null, error: null, isRunning: true }
            ↓ operación async completa
Éxito:      { data: [results], error: null, isRunning: false }
```

**Nota:** El `data` inicial es `null` a menos que establezcas un parámetro `initialValue` al crear el command.

### Flujo de Error

```
Inicial:    { data: null, error: null, isRunning: false }
            ↓ command.run('query')
Running:    { data: null, error: null, isRunning: true }
            ↓ se lanza excepción
Error:      { data: null, error: Exception(), isRunning: false }
```

### includeLastResultInCommandResults

Por defecto, `CommandResult.data` se vuelve `null` durante la ejecución del command y cuando ocurren errores. Establece `includeLastResultInCommandResults: true` para mantener el último valor exitoso visible en ambos estados:

```dart
Command.createAsync<String, List<Todo>>(
  (query) => api.search(query),
  initialValue: [],
  includeLastResultInCommandResults: true, // Mantener datos antiguos visibles
);
```

**Cuándo este flag afecta el comportamiento:**

1. **Durante la ejecución** (`isRunning: true`) - Los datos antiguos permanecen en `result.data` en lugar de volverse `null`
2. **Durante estados de error** (`hasError: true`) - Los datos antiguos permanecen en `result.data` en lugar de volverse `null`

**Flujo modificado (con `initialValue: []`):**

```
Inicial:    { data: [], error: null, isRunning: false }
            ↓ command.run('query')
Running:    { data: [], error: null, isRunning: true }  ← Datos antiguos mantenidos
            ↓ éxito
Éxito:      { data: [nuevos resultados], error: null, isRunning: false }

            ↓ command.run('query2')
Running:    { data: [resultados antiguos], error: null, isRunning: true }  ← Aún visibles
            ↓ error
Error:      { data: [resultados antiguos], error: Exception(), isRunning: false }  ← Aún visibles
```

**Casos de uso comunes:**

- **Pull-to-refresh** - Mostrar datos obsoletos mientras se cargan datos frescos
- **Stale-while-revalidate** - Seguir mostrando contenido antiguo durante actualizaciones
- **Recuperación de errores** - Mostrar últimos datos buenos conocidos incluso cuando ocurren errores
- **UI Optimista** - Mantener estabilidad de UI durante refrescos en background

**Cuándo usar:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Escenarios de refresco de listas/feeds donde estados vacíos se ven mal</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Resultados de búsqueda que se actualizan incrementalmente</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Datos que es mejor tener obsoletos que ausentes</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Login/autenticación donde datos obsoletos son engañosos</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Datos críticos donde mostrar valores antiguos durante errores es inseguro</li>
</ul>

## Ejemplo Completo

### Con `watch_it` (Recomendado)

<<< @/../code_samples/lib/command_it/command_result_watch_it_example.dart#example

**Cómo funciona:**
1. `watchValue` observa la propiedad `.results`
2. El widget se reconstruye automáticamente cuando cambia el estado
3. Verifica `result.isRunning` primero → mostrar carga
4. Verifica `result.hasError` después → mostrar error (con datos del parámetro)
5. Verifica `result.hasData` → mostrar datos
6. Fallback → estado inicial

### Sin `watch_it`

<<< @/../code_samples/lib/command_it/command_result_example.dart#example

La misma lógica usando `ValueListenableBuilder` para usuarios que prefieren no usar `watch_it`.

## Usando .toWidget() con CommandResult

El método de extensión `.toWidget()` proporciona una forma declarativa de construir UI desde CommandResult. Para documentación completa sobre cómo usar `.toWidget()`, incluyendo:

- Parámetros del builder y reglas de precedencia
- Diferencias entre `onData` y `onSuccess`
- Cuándo usar `.toWidget()` vs verificaciones manuales de estado
- Ejemplos y patrones comunes

Ver **[Command Builders - Método de Extensión toWidget()](/es/documentation/command_it/command_builders#metodo-de-extension-towidget)**

## Propiedades del Result

### data - El Valor del Resultado

```dart
if (result.hasData) {
  final items = result.data!; // Seguro de desempaquetar
  return ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, i) => ItemTile(items[i]),
  );
}
```

**Comportamiento:**
- `null` mientras el command se ejecuta (a menos que `includeLastResultInCommandResults`)
- `null` en error (a menos que `includeLastResultInCommandResults`)
- Contiene el valor del resultado en éxito
- Siempre `null` para commands con resultado `void`

**Nullability:**
- El tipo es `TResult?` (nullable)
- Usa `hasData` para verificar antes de acceder
- Seguro de desempaquetar después de verificar `hasData`

### error - La Excepción

```dart
if (result.hasError) {
  return ErrorWidget(
    message: result.error.toString(),
    onRetry: command.run,
  );
}
```

**Comportamiento:**
- `null` cuando no hay error
- Contiene la excepción lanzada en fallo
- Se limpia a `null` cuando el command se ejecuta de nuevo
- El tipo es `Object?` (cualquier cosa lanzable)

::: tip CommandResult.error vs Propiedad Command.errors
**Distinción importante:**
- `CommandResult.error` contiene el **objeto de error puro/raw** (tipo `Object?`)
- La propiedad `.errors` del command contiene `CommandError<TParam>?` que **envuelve** el error con contexto adicional (datos del parámetro, nombre del command, stack trace, reacción al error)

Cuando usas `CommandResult`, tienes acceso directo al error lanzado. Cuando usas la propiedad `.errors`, obtienes el error envuelto con metadata.
:::

**Tipos de error:**
```dart
if (result.hasError) {
  if (result.error is ApiException) {
    // Manejar errores de API
  } else if (result.error is ValidationException) {
    // Manejar errores de validación
  } else {
    // Error genérico
  }
}
```

::: tip Manejo de Errores (Error Handling) en UI vs Filtros de Error
El patrón anterior es recomendado para **mostrar diferente UI basándose en tipo de error**. Para estrategias de manejo de errores más sofisticadas (enrutar errores a diferentes handlers, logging, relanzar, silenciar errores específicos, etc.), usa **[Filtros de Error](/es/documentation/command_it/error_handling)** que ofrecen posibilidades mucho más ricas para controlar reacciones a errores.
:::

### isRunning - Estado de Ejecución

```dart
if (result.isRunning) {
  return Center(
    child: Column(
      children: [
        CircularProgressIndicator(),
        Text('Cargando...'),
      ],
    ),
  );
}
```

**Comportamiento:**
- `true` mientras la función async se ejecuta
- `false` inicialmente y después de completar
- Se actualiza asíncronamente (via microtask) - ver [Propiedades del Command](/es/documentation/command_it/command_properties)

### paramData - El Parámetro de Entrada

```dart
if (result.hasError) {
  return Column(
    children: [
      Text('Error: ${result.error}'),
      if (result.paramData != null)
        Text('Falló para la consulta: ${result.paramData}'),
      ElevatedButton(
        onPressed: () => command(result.paramData), // Reintentar con mismo parámetro
        child: Text('Reintentar'),
      ),
    ],
  );
}
```

**Comportamiento:**
- Contiene el parámetro pasado al command
- `null` para commands sin parámetro
- El tipo es `TParam?` (nullable)
- Útil para mensajes de error y lógica de reintento

**Casos de uso:**
- Mostrar qué consulta falló en el mensaje de error
- Botón de reintentar con los mismos parámetros
- Logging de qué operación falló

## Getters de Conveniencia

### hasData

```dart
bool get hasData => data != null;

// Uso
if (result.hasData) {
  return DataView(result.data!);
}
```

**Preferido sobre:**
```dart
if (result.data != null) { ... }
```

### hasError

```dart
bool get hasError => error != null;

// Uso
if (result.hasError) {
  return ErrorView(result.error.toString());
}
```

**Preferido sobre:**
```dart
if (result.error != null) { ... }
```

### isSuccess

```dart
bool get isSuccess => !hasError && !isRunning;

// Uso
if (result.isSuccess && result.hasData) {
  return SuccessView(result.data!);
}
```

**Útil para:**
- Distinguir completación exitosa del estado inicial
- Mostrar animaciones/mensajes de éxito
- Renderizado condicional después de completar

## Patrones con CommandResult

### Patrón 1: Estados Progresivos

**Con `watch_it`:**

```dart
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final result = watchValue((Manager m) => m.command.results);

    // 1. Loading
    if (result.isRunning) {
      return LoadingState(query: result.paramData);
    }

    // 2. Error
    if (result.hasError) {
      return ErrorState(
        error: result.error!,
        query: result.paramData,
        onRetry: () => di<Manager>().command(result.paramData),
      );
    }

    // 3. Éxito
    if (result.hasData) {
      return DataState(data: result.data!);
    }

    // 4. Inicial (sin datos, sin error, no ejecutándose)
    return InitialState();
  }
}
```

**Sin `watch_it`:**

```dart
ValueListenableBuilder<CommandResult<String, Data>>(
  valueListenable: command.results,
  builder: (context, result, _) {
    // 1. Loading
    if (result.isRunning) {
      return LoadingState(query: result.paramData);
    }

    // 2. Error
    if (result.hasError) {
      return ErrorState(
        error: result.error!,
        query: result.paramData,
        onRetry: () => command(result.paramData),
      );
    }

    // 3. Éxito
    if (result.hasData) {
      return DataState(data: result.data!);
    }

    // 4. Inicial (sin datos, sin error, no ejecutándose)
    return InitialState();
  },
)
```

### Patrón 2: UI Optimista con Datos Obsoletos

**Setup:**

```dart
Command.createAsync<String, List<Item>>(
  (query) => api.search(query),
  initialValue: [],
  includeLastResultInCommandResults: true, // Mantener datos antiguos
);
```

**Con `watch_it`:**

```dart
class SearchWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final result = watchValue((SearchManager m) => m.searchCommand.results);

    return Stack(
      children: [
        // Siempre mostrar datos (antiguos o nuevos)
        if (result.hasData)
          ItemList(items: result.data!),

        // Superponer indicador de carga
        if (result.isRunning)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(),
          ),

        // Mostrar banner de error
        if (result.hasError)
          ErrorBanner(error: result.error),
      ],
    );
  }
}
```

**Sin `watch_it`:**

```dart
ValueListenableBuilder<CommandResult<String, List<Item>>>(
  valueListenable: searchCommand.results,
  builder: (context, result, _) {
    return Stack(
      children: [
        // Siempre mostrar datos (antiguos o nuevos)
        if (result.hasData)
          ItemList(items: result.data!),

        // Superponer indicador de carga
        if (result.isRunning)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(),
          ),

        // Mostrar banner de error
        if (result.hasError)
          ErrorBanner(error: result.error),
      ],
    );
  },
)
```

### Patrón 3: Reintentar con Parámetros Originales

```dart
if (result.hasError) {
  return ErrorView(
    error: result.error!,
    operation: 'Buscando "${result.paramData}"',
    onRetry: () {
      // Reintentar con exactamente el mismo parámetro
      command(result.paramData);
    },
  );
}
```

### Patrón 4: Logging con Contexto

Usa la propiedad `.errors` para logging - proporciona contexto más rico que `CommandResult.error`:

```dart
command.errors.listen((commandError, _) {
  if (commandError != null) {
    logger.error(
      'Command falló: ${commandError.command}',
      error: commandError.error,
      stackTrace: commandError.stackTrace,
      param: commandError.paramData,
      errorReaction: commandError.errorReaction,
    );
  }
});
```

**Por qué `.errors` es mejor para logging:**
- Incluye `stackTrace` capturado automáticamente
- Proporciona nombre del `command` para identificar qué command falló
- Contiene `errorReaction` mostrando cómo se manejó el error
- Todo el contexto empaquetado en el wrapper `CommandError<TParam>`

## CommandResult vs Propiedades Individuales

### Usando propiedades individuales (múltiples watchers)

```dart
// Con watch_it - solo reconstruye para las propiedades que observas
class TodoWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final isRunning = watchValue((TodoManager m) => m.loadTodos.isRunning);
    final todos = watchValue((TodoManager m) => m.loadTodos);

    if (isRunning) return CircularProgressIndicator();
    return TodoList(todos: todos);
  }
}
```

**Beneficios:**
- Cada propiedad solo se actualiza cuando su valor cambia
- No se necesitan verificaciones `if` cuando observas 1-2 propiedades
- Menos rebuilds - solo cuando las propiedades observadas cambian

### Usando CommandResult (watcher único)

```dart
// Propiedad única con verificaciones if
class TodoWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final result = watchValue((TodoManager m) => m.loadTodos.results);

    if (result.isRunning) return CircularProgressIndicator();
    if (result.hasError) return ErrorWidget(result.error);
    return TodoList(todos: result.data ?? []);
  }
}
```

**Trade-offs:**
- **Más rebuilds**: Se actualiza en cada cambio de estado (running, éxito, error)
- **Requiere verificaciones `if`**: Debes verificar propiedades de estado
- **Watcher único**: Todo el estado en un solo lugar
- **Mejor para**: Cuando necesitas 3+ propiedades o toda la información de estado

**Recomendación:**
- **Necesitas solo 1-2 propiedades** (ej., solo data + isRunning): Usa propiedades individuales
- **Necesitas 3+ propiedades** o estado completo: Usa CommandResult

## Errores Comunes

### ❌️️ Acceder a data sin verificación de null

```dart
// MAL: data podría ser null
return ListView.builder(
  itemCount: result.data.length, // ¡Crash si es null!
  ...
);
```

```dart
// CORRECTO: Verificar hasData primero
if (result.hasData) {
  return ListView.builder(
    itemCount: result.data!.length,
    ...
  );
}
```

### ❌️️ Orden incorrecto de verificación de estado

```dart
// MAL: Verifica data antes de verificar isRunning
if (result.hasData) return DataView(result.data!);
if (result.isRunning) return LoadingView();
```

```dart
// CORRECTO: Verificar isRunning primero
if (result.isRunning) return LoadingView();
if (result.hasData) return DataView(result.data!);
```

### ❌️️ Ignorar el estado inicial

```dart
// MAL: ¿Qué pasa si no hay data, no hay error, no está ejecutándose?
if (result.isRunning) return LoadingView();
if (result.hasError) return ErrorView(result.error!);
return DataView(result.data!); // ¡Crash en estado inicial!
```

```dart
// CORRECTO: Manejar todos los estados
if (result.isRunning) return LoadingView();
if (result.hasError) return ErrorView(result.error!);
if (result.hasData) return DataView(result.data!);
return InitialView(); // Estado inicial
```

## Ver También

- [Propiedades del Command](/es/documentation/command_it/command_properties) — Todas las propiedades observables del command
- [Fundamentos de Command](/es/documentation/command_it/command_basics) — Creando y ejecutando commands
- [Manejo de Errores (Error Handling)](/es/documentation/command_it/error_handling) — Uso de la propiedad errors
- [Widget CommandBuilder](/es/documentation/command_it/command_builders) — Widget que usa CommandResult
