# Fundamentos de Command

Aprende cómo crear y ejecutar commands, la base de command_it.

::: tip Los Ejemplos Usan `watch_it`
Todos los ejemplos usan **`watch_it`** para observar commands. Ver [Sin `watch_it`](/es/documentation/command_it/without_watch_it.md) si prefieres `ValueListenableBuilder`.
:::

## ¿Qué es un Command?

Un **Command** envuelve una función (sync o async) y la hace observable. En lugar de llamar una función directamente y rastrear manualmente su estado, creas un command que:

- Ejecuta tu función cuando es llamado
- Rastrea automáticamente el estado de ejecución (`isRunning`)
- Publica resultados via `ValueListenable`
- Maneja errores de forma elegante
- Previene ejecución paralela

**Piénsalo como**: Una función + gestión de estado automática + notificaciones reactivas.

::: tip El Patrón Command
La filosofía central: **Inicia commands con `run()` (dispara y olvida), luego tu app/UI observa y reacciona a sus cambios de estado**. Este patrón reactivo mantiene tu UI responsiva sin bloqueos—disparas la acción y dejas que tu UI responda automáticamente a estados de carga, resultados y errores.
:::

## Creando Tu Primer Command

Los Commands se crean usando funciones factory estáticas, no constructores. El tipo más común es `createAsyncNoParam` para funciones async sin parámetros:

<<< @/../code_samples/lib/command_it/counter_basic_example.dart#example

**Qué sucede:**
1. El Command envuelve tu función async
2. Cuando se llama `run()`, la función se ejecuta
3. Mientras se ejecuta, `isRunning` es `true`
4. El resultado se publica en la propiedad `value`
5. La UI se reconstruye automáticamente via `watchValue`

## Ejecutando Commands

Hay dos formas de ejecutar un command:

### 1. Usando `run()` (Dispara y Olvida)

```dart
// Llama al método run del command
loadDataCommand.run();

// O con un parámetro
searchCommand.run('flutter');
```

Usa `run()` cuando quieras disparar la ejecución sin esperar el resultado. Perfecto para handlers de botones.

### 2. Llamando como Clase Callable

Los Commands son clases callable, así que puedes invocarlos directamente:

```dart
// Callable - igual que run()
loadDataCommand();

// Con parámetro
searchCommand('flutter');
```

Esto es solo una abreviatura para `run()` - no devuelve un valor.

::: tip ¿Por Qué Usar `.run` para Tearoffs?
En el pasado, era posible pasar clases callable directamente como tearoffs. Sin embargo, debido a cambios en Dart, esto ya no es posible. Para VoidCallbacks opcionales (como `onPressed`), pasar una clase callable directamente es ahora un **error de compilación**. Incluso cuando compila, dispara la advertencia del linter `implicit_call_tearoffs` porque Dart implícitamente hace tearoff del método `.call()`, lo cual se considera poco claro.

**Siempre usa `.run` para tearoffs:**
```dart
// ✅ Bien - tearoff explícito
ElevatedButton(onPressed: command.run, ...)

// ❌ Evitar - implicit call tearoff (error de compilación para VoidCallback opcional)
ElevatedButton(onPressed: command, ...)
```

Por esto command_it renombró de `execute()` a `run()` en v9.0.0 - haciendo del método explícito la API principal.
:::

### 3. Usando `runAsync()` (Await del Resultado)

Usa `runAsync()` cuando necesites hacer await del resultado:

```dart
final result = await loadDataCommand.runAsync();
```

::: warning Usar con Moderación
`runAsync()` rompe el patrón de dispara-y-olvida descrito arriba. Solo úsalo cuando una API requiere que se devuelva un Future (como `RefreshIndicator.onRefresh`). Para código de aplicación normal, siempre usa `run()` y observa cambios de estado de forma reactiva.
:::

Perfecto para `RefreshIndicator`:

```dart
RefreshIndicator(
  onRefresh: () => updateCommand.runAsync(),
  child: ListView(...),
)
```

## Commands con Parámetro y Tipo de Retorno

La mayoría de commands necesitan tanto parámetros como valores de retorno. Usa `createAsync<TParam, TResult>` para funciones async con parámetro y resultado:

```dart
late final searchCommand = Command.createAsync<String, List<Todo>>(
  (query) async {
    await Future.delayed(Duration(milliseconds: 500));
    return fakeTodos.where((t) => t.title.contains(query)).toList();
  },
  initialValue: [],
);

// Llamar con parámetro
searchCommand.run('flutter');
```

**Parámetros de tipo:**
- Primer tipo (`String`) = tipo del parámetro
- Segundo tipo (`List<Todo>`) = tipo del resultado

## Commands Síncronos

Para funciones síncronas, usa `createSync`:

```dart
late final formatCommand = Command.createSync<String, String>(
  (text) => text.toUpperCase(),
  initialValue: '',
);

// Usar exactamente como commands async
formatCommand.run('hello');
```

**Importante:** Los commands sync no soportan `isRunning` - accederlo lanzará una excepción porque la UI no puede actualizarse mientras las funciones síncronas se ejecutan.

## Valores Iniciales

Los Commands que devuelven un valor requieren un `initialValue`:

```dart
Command.createAsyncNoParam<List<Todo>>(
  () => api.fetchTodos(),
  initialValue: [], // Requerido: ¿qué valor antes de la primera ejecución?
);
```

**¿Por qué?** Los Commands son `ValueListenable<TResult>`. Necesitan un valor desde el inicio, antes de que la primera ejecución complete. Esto es especialmente importante si el valor del command debe mostrarse en un widget—los widgets necesitan un valor en el primer build incluso si el command no ha sido ejecutado aún.

Los Commands que devuelven `void` no necesitan valores iniciales:

```dart
Command.createAsyncNoResult<String>(
  (message) => api.sendMessage(message),
  // No se necesita initialValue
);
```

## Prevención Automática de Ejecución Paralela

Los Commands automáticamente previenen la ejecución paralela:

```dart
final saveCommand = Command.createAsyncNoParam<void>(
  () async {
    await Future.delayed(Duration(seconds: 2));
    await api.save();
  },
);

// Clic rápido en botón
saveCommand.run(); // Inicia ejecución
saveCommand.run(); // Ignorado - ya ejecutándose
saveCommand.run(); // Ignorado - ya ejecutándose
// ... pasan 2 segundos ...
saveCommand.run(); // Ahora este se ejecuta
```

**Esto previene:**
- Doble envío
- Condiciones de carrera
- Llamadas API desperdiciadas

## Usando Commands en Managers

**Mejor práctica:** Crea commands en clases manager/controller, no en widgets:

```dart
class TodoManager {
  final api = ApiClient();

  late final loadTodosCommand = Command.createAsyncNoParam<List<Todo>>(
    () => api.fetchTodos(),
    initialValue: [],
  );

  late final saveTodoCommand = Command.createAsyncNoResult<Todo>(
    (todo) => api.saveTodo(todo),
  );
}

// En widget
class TodoListWidget extends StatelessWidget {
  final manager = TodoManager();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Todo>>(
      valueListenable: manager.loadTodosCommand,
      builder: (context, todos, _) => ListView(...),
    );
  }
}
```

**¿Por qué?**
- Separa lógica de negocio de UI
- Más fácil de testear
- Reutilizable entre widgets
- Límites de responsabilidad claros

## Disposing Commands

Los Commands deben ser disposed para prevenir memory leaks:

```dart
class TodoManager {
  late final loadCommand = Command.createAsyncNoParam<List<Todo>>(...);

  void dispose() {
    loadCommand.dispose();
  }
}
```

**Al usar StatefulWidget:**

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final TodoManager manager;

  @override
  void initState() {
    super.initState();
    manager = TodoManager();
  }

  @override
  void dispose() {
    manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ...;
}
```

**Con get_it:** Registra como singleton y haz dispose al cerrar la app o usa scopes para limpieza automática. **Con watch_it:** Usa [`createOnce()`](/es/documentation/watch_it/lifecycle#createonce) para gestión automática del ciclo de vida.

## Ver También

- [Propiedades del Command](/es/documentation/command_it/command_properties) — value, isRunning, canRun, errors, results
- [Tipos de Command](/es/documentation/command_it/command_types) — Todas las funciones factory
- [Manejo de Errores](/es/documentation/command_it/error_handling) — Manejando errores elegantemente
- [Mejores Prácticas](/es/documentation/command_it/best_practices) — Patrones de producción
