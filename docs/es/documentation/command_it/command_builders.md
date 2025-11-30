# Command Builders

Simplifica la integración de UI con commands usando `CommandBuilder` - un widget que maneja todos los estados del command (carga, datos, error) con mínimo boilerplate.

## ¿Por Qué Usar CommandBuilder?

En lugar de construir manualmente widgets `ValueListenableBuilder` para `command.results`, usa `CommandBuilder` para manejar declarativamente todos los estados del command:

```dart
// En lugar de esto:
ValueListenableBuilder<CommandResult<void, String>>(
  valueListenable: command.results,
  builder: (context, result, _) {
    if (result.isRunning) return CircularProgressIndicator();
    if (result.hasError) return Text('Error: ${result.error}');
    return Text('Contador: ${result.data}');
  },
)

// Usa esto:
CommandBuilder(
  command: command,
  whileRunning: (context, _, __) => CircularProgressIndicator(),
  onError: (context, error, _, __) => Text('Error: $error'),
  onData: (context, value, _) => Text('Contador: $value'),
)
```

**Beneficios:**
- Código más limpio y declarativo
- Builders separados para cada estado
- Menos anidación que ValueListenableBuilder
- Acceso a parámetros con type-safety

## Ejemplo Básico

<<< @/../code_samples/lib/command_it/command_builder_example.dart#example

## Parámetros

Todos los parámetros son opcionales excepto `command`:

**Tipos Genéricos:**
- `TParam` - El parámetro que se pasó cuando se llamó al command (ej., la consulta de búsqueda)
- `TResult` - El valor de retorno de la ejecución del command

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| **command** | `Command<TParam, TResult>` | Requerido. El command a observar |
| **onData** | `Widget Function(BuildContext, TResult, TParam?)` | Builder para ejecución exitosa con valor de retorno |
| **onSuccess** | `Widget Function(BuildContext, TParam?)` | Builder para ejecución exitosa (ignora valor de retorno) |
| **onNullData** | `Widget Function(BuildContext, TParam?)` | Builder cuando el command retorna null |
| **whileRunning** | `Widget Function(BuildContext, TResult?, TParam?)` | Builder mientras el command se ejecuta |
| **onError** | `Widget Function(BuildContext, Object, TResult?, TParam?)` | Builder cuando el command lanza error |
| **runCommandOnFirstBuild** | `bool` | Si es true, ejecuta el command en initState (por defecto: false) |
| **initialParam** | `TParam?` | Parámetro a pasar cuando runCommandOnFirstBuild es true |

### Cuándo Usar Cada Builder

**onData** - Commands con valores de retorno:
```dart
CommandBuilder(
  command: searchCommand,
  onData: (context, items, query) => ItemList(items),  // ✅ Usa items
)
```

**onSuccess** - Commands void o cuando no necesitas el resultado:
```dart
CommandBuilder(
  command: deleteCommand,
  onSuccess: (context, deletedItem) => Text('Eliminado: ${deletedItem?.name}'),
)
```

**onNullData** - Manejar resultados null explícitamente:
```dart
CommandBuilder(
  command: fetchCommand,
  onData: (context, data, _) => DataWidget(data),
  onNullData: (context, _) => Text('No hay datos disponibles'),
)
```

**whileRunning** - Mostrar estado de carga:
```dart
whileRunning: (context, lastValue, param) => Column(
  children: [
    CircularProgressIndicator(),
    if (lastValue != null) Text('Anterior: $lastValue'), // Mostrar datos obsoletos
    if (param != null) Text('Cargando: $param'),
  ],
)
```

**onError** - Manejar errores:
```dart
onError: (context, error, lastValue, param) => ErrorWidget(
  error: error,
  onRetry: () => command(param), // Reintentar con mismo parámetro
)
```

::: tip
El parámetro `lastValue` en `whileRunning` y `onError` solo contendrá datos si el command fue creado con `includeLastResultInCommandResults: true`. De lo contrario, siempre será `null`. Ver [includeLastResultInCommandResults](/es/documentation/command_it/command_results#includelastresultincommandresults).
:::

## Mostrando Parámetro en UI

Accede al parámetro del command en cualquier builder:

```dart
CommandBuilder(
  command: searchCommand,
  whileRunning: (context, _, query) => Text('Buscando: $query'),
  onData: (context, items, query) => Column(
    children: [
      Text('Resultados para: $query'),
      ItemList(items),
    ],
  ),
  onError: (context, error, _, query) => Text('Búsqueda "$query" falló: $error'),
)
```

## Ejecutando Commands Automáticamente al Montar

CommandBuilder puede ejecutar automáticamente un command cuando el widget se construye por primera vez usando el parámetro `runCommandOnFirstBuild`. Esto es particularmente útil cuando no usas `watch_it` (que proporciona `callOnce` para este propósito).

### Uso Básico (Sin Parámetro)

```dart
CommandBuilder(
  command: loadTodosCommand,
  runCommandOnFirstBuild: true, // Ejecuta command en initState
  whileRunning: (context, _, __) => CircularProgressIndicator(),
  onData: (context, todos, _) => TodoList(todos),
  onError: (context, error, _, __) => ErrorWidget(error),
)
```

**Qué sucede:**
1. El widget se construye
2. El command se ejecuta automáticamente en `initState`
3. La UI muestra estado de carga → estado de datos/error
4. El command solo se ejecuta **una vez** - no en rebuilds

### Con Parámetros

Usa `initialParam` para pasar un parámetro al command:

```dart
CommandBuilder(
  command: searchCommand,
  runCommandOnFirstBuild: true,
  initialParam: 'flutter', // Parámetro a pasar
  whileRunning: (context, _, query) => Text('Buscando: $query'),
  onData: (context, items, query) => ItemList(items),
  onError: (context, error, _, query) => Text('Búsqueda falló: $error'),
)
```

### Cuándo Usar

**✅ Usa runCommandOnFirstBuild cuando:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ No usas <code>watch_it</code> (sin acceso a <code>callOnce</code>)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ El widget debe cargar sus propios datos al montar</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Quieres widgets de carga de datos autocontenidos</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Escenarios simples de fetch de datos</li>
</ul>

**❌️ No uses cuando:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Usas <code>watch_it</code> - prefiere <code>callOnce</code> en su lugar (separación más clara)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ El <code>Command</code> ya se está ejecutando en otro lugar</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Necesitas lógica condicional antes de ejecutar</li>
</ul>

### Comparación con callOnce de `watch_it`

**Con `watch_it` (recomendado si usas `watch_it`):**
```dart
class TodoWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    callOnce((Manager m) => m.loadTodos()); // Trigger explícito

    return CommandBuilder(
      command: getIt<Manager>().loadTodos,
      onData: (context, todos, _) => TodoList(todos),
    );
  }
}
```

**Sin `watch_it` (usa runCommandOnFirstBuild):**
```dart
class TodoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CommandBuilder(
      command: getIt<Manager>().loadTodos,
      runCommandOnFirstBuild: true, // Trigger incorporado
      onData: (context, todos, _) => TodoList(todos),
    );
  }
}
```

## Reglas de Precedencia de Builders

Tanto `CommandBuilder` como `CommandResult.toWidget()` usan las mismas reglas de precedencia para determinar qué builder llamar:

**Orden de precedencia completo:**
1. **`if (error != null)`** → llama `onError`
2. **`if (isRunning)`** → llama `whileRunning`
3. **`if (onSuccess != null)`** → llama `onSuccess` ⚠️ **¡Tiene prioridad sobre onData!**
4. **`if (data != null)`** → llama `onData`
5. **`else`** → llama `onNullData`

::: tip onData vs onSuccess
**Cuando el command completa exitosamente:**
1. Si `onSuccess` está proporcionado → llámalo (no verifica si data es null)
2. Si no, si data != null → llama `onData`
3. Si no → llama `onNullData`

**Elige `onSuccess` cuando:**
- El command retorna void (ej., `Command.createAsyncNoResult`)
- Solo necesitas mostrar mensaje de confirmación/éxito
- Los datos del resultado son irrelevantes para la UI

**Elige `onData` cuando:**
- El command retorna datos que necesitas mostrar/usar
- Quieres manejar datos no-null diferente de datos null
:::

## Método de Extensión toWidget()

El método de extensión `.toWidget()` en `CommandResult` proporciona el mismo patrón de builder declarativo que `CommandBuilder`, pero para usar cuando ya tienes acceso a un `CommandResult` (ej., via `watch_it`, `provider`, o `flutter_hooks`).

<<< @/../code_samples/lib/command_it/command_result_towidget_example.dart#example

**Parámetros:**

Debes proporcionar **al menos uno** de estos dos:

- **`onData`** - `Widget Function(TResult result, TParam? param)?`
  - Se llama cuando el command tiene **datos no-null** (solo si `onSuccess` no está proporcionado)
  - Recibe tanto los datos del resultado como el parámetro
  - Usa para commands que retornan datos que necesitas mostrar

- **`onSuccess`** - `Widget Function(TParam? param)?`
  - Se llama en completación exitosa (sin error, no ejecutándose)
  - **NO** recibe datos del resultado, solo el parámetro
  - **Tiene prioridad** sobre `onData` si ambos están proporcionados
  - Usa para commands que retornan void o cuando no necesitas el valor del resultado

Builders opcionales:

- **`whileRunning`** - `Widget Function(TResult? lastResult, TParam? param)?`
  - Se llama mientras el command se ejecuta
  - Recibe último resultado (si `includeLastResultInCommandResults: true`) y parámetro

- **`onError`** - `Widget Function(Object error, TResult? lastResult, TParam? param)?`
  - Se llama cuando ocurre un error
  - Recibe error, último resultado y parámetro

- **`onNullData`** - `Widget Function(TParam? param)?`
  - Se llama cuando data es null (solo si ni `onSuccess` ni `onData` lo manejan)
  - Recibe solo el parámetro

**Diferencias clave con CommandBuilder:**

| Característica | CommandBuilder | toWidget() |
|---------------|---------------|-----------|
| BuildContext en builders | ✅ Sí (como parámetro) | ❌️ No (acceso desde build envolvente) |
| Requiere CommandResult | ❌️ No (toma Command) | ✅ Sí |
| Caso de uso | Uso directo de Command | Ya observando results |
| Precedencia de builders | Igual que toWidget() | Igual que CommandBuilder |

## Cuándo Usar Qué

**Usa CommandBuilder cuando:**
- Construyes UI directamente desde un Command
- Prefieres composición declarativa de widgets
- No usas gestión de estado que expone results
- Quieres BuildContext pasado a las funciones builder

**Usa toWidget() cuando:**
- Ya observas `command.results` via watch_it/provider/hooks
- Quieres firmas de builder más simples (sin parámetro BuildContext)
- Prefieres menos boilerplate cuando ya estás suscrito a results

**Usa ValueListenableBuilder cuando:**
- Necesitas control completo sobre la lógica de renderizado
- Combinaciones de estado complejas más allá de patrones estándar
- Lógica de caching personalizada crítica para rendimiento

## Patrones Comunes

### Loading con Datos Anteriores

Mostrar datos obsoletos mientras se cargan datos frescos:

::: warning Configuración Requerida
Este patrón requiere que el command se cree con `includeLastResultInCommandResults: true`. Sin esta opción, `lastItems` siempre será `null` durante la ejecución. Ver [Command Results - includeLastResultInCommandResults](/es/documentation/command_it/command_results#includelastresultincommandresults) para detalles.
:::

```dart
// El command debe crearse con esta opción:
final searchCommand = Command.createAsync<String, List<Item>>(
  searchApi,
  [],
  includeLastResultInCommandResults: true, // Requerido para el patrón de abajo
);

CommandBuilder(
  command: searchCommand,
  whileRunning: (context, lastItems, query) => Column(
    children: [
      LinearProgressIndicator(),
      if (lastItems != null)
        Opacity(opacity: 0.5, child: ItemList(lastItems)),
    ],
  ),
  onData: (context, items, _) => ItemList(items),
)
```

### Error con Reintento

::: warning Configuración Requerida
Para mostrar el último valor exitoso (línea 7), el command debe crearse con `includeLastResultInCommandResults: true`. Ver [Command Results - includeLastResultInCommandResults](/es/documentation/command_it/command_results#includelastresultincommandresults).
:::

```dart
onError: (context, error, lastValue, param) => Column(
  children: [
    Text('Error: $error'),
    ElevatedButton(
      onPressed: () => command(param), // Reintentar con mismo parámetro
      child: Text('Reintentar'),
    ),
    if (lastValue != null) Text('Último exitoso: $lastValue'),
  ],
)
```

### Builders Condicionales

No todos los builders son requeridos - proporciona solo lo que necesitas:

```dart
// Mínimo: solo mostrar datos
CommandBuilder(
  command: command,
  onData: (context, data, _) => Text(data),
)

// Sin indicador de carga necesario
CommandBuilder(
  command: command,
  onData: (context, data, _) => Text(data),
  onError: (context, error, _, __) => Text('Error: $error'),
  // whileRunning omitido - no muestra nada mientras carga
)
```

## Ver También

- [Command Results](/es/documentation/command_it/command_results) - Entendiendo la estructura de CommandResult
- [Fundamentos de Command](/es/documentation/command_it/command_basics) - Creando y ejecutando commands
- [Propiedades del Command](/es/documentation/command_it/command_properties) - La propiedad `.results`
- [Observando Commands con watch_it](/es/documentation/watch_it/observing_commands) - Usando con gestión de estado reactiva
