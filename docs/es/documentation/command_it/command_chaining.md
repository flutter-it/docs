# Encadenamiento de Commands

Conecta commands de forma declarativa usando `pipeToCommand`. Cuando un `ValueListenable` fuente cambia, automáticamente dispara el command destino.

## ¿Por Qué Usar pipeToCommand?

En lugar de configurar listeners manualmente:

```dart
// ❌ Enfoque manual - más boilerplate
sourceCommand.listen((value, _) {
  if (value.isNotEmpty) {
    targetCommand(value);
  }
});
```

Usa `pipeToCommand` para encadenamiento más limpio y declarativo:

```dart
// ✅ Enfoque declarativo
sourceCommand
    .where((value) => value.isNotEmpty)
    .pipeToCommand(targetCommand);
```

**Beneficios:**
- Declarativo y legible
- Se combina con operadores de `listen_it` (debounce, where, map)
- Retorna `ListenableSubscription` para limpieza fácil
- Funciona con cualquier `ValueListenable`, no solo commands

## Encadenamiento Inline con Cascade

El patrón más limpio: usa el operador cascade de Dart `..` para encadenar directamente en la definición del command:

```dart
class DataManager {
  late final refreshCommand = Command.createAsyncNoParam<List<Data>>(
    () => api.fetchData(),
    initialValue: [],
  );

  // ¡Encadena directamente en la definición - no se necesita constructor!
  late final saveCommand = Command.createAsyncNoResult<Data>(
    (data) => api.save(data),
  )..pipeToCommand(refreshCommand);
}
```

Esto elimina la necesidad de un constructor solo para configurar pipes. La suscripción se gestiona automáticamente cuando se dispone el command.

## Uso Básico

`pipeToCommand` funciona con cualquier `ValueListenable`:

### Desde un Command

Cuando un command completa, dispara otro:

<<< @/../code_samples/lib/command_it/command_chaining_basic.dart#basic

### Desde isRunning

Reacciona al estado de ejecución del command:

<<< @/../code_samples/lib/command_it/command_chaining_basic.dart#from_isrunning

### Desde results

Pasa el `CommandResult` completo (incluye estado de éxito/error):

<<< @/../code_samples/lib/command_it/command_chaining_basic.dart#from_results

### Desde ValueNotifier

También funciona con `ValueNotifier` simple:

<<< @/../code_samples/lib/command_it/command_chaining_basic.dart#from_valuenotifier

## Función Transform

Cuando los tipos de fuente y destino no coinciden, usa el parámetro `transform`:

### Transform Básico

<<< @/../code_samples/lib/command_it/command_chaining_transform.dart#transform_basic

### Transform Complejo

Crea objetos de parámetros complejos:

<<< @/../code_samples/lib/command_it/command_chaining_transform.dart#transform_complex

### Transform de Resultados

Transforma resultados del command antes de pasar:

<<< @/../code_samples/lib/command_it/command_chaining_transform.dart#transform_result

## Manejo de Tipos

`pipeToCommand` maneja tipos automáticamente:

1. **Transform proporcionado** → Usa la función transform
2. **Tipos coinciden** → Pasa el valor directamente a `target.run(value)`
3. **Tipos no coinciden** → Llama `target.run()` sin parámetros

Esto significa que puedes pasar a commands sin parámetros sin un transform:

```dart
// saveCommand retorna Data, refreshCommand no toma params
saveCommand.pipeToCommand(refreshCommand);  // ¡Funciona! Llama refreshCommand.run()
```

## Combinando con Operadores de listen_it

El verdadero poder viene de combinar `pipeToCommand` con operadores de `listen_it`:

### Búsqueda con Debounce

<<< @/../code_samples/lib/command_it/command_chaining_operators.dart#search_example

### Filtrar Antes de Pasar

<<< @/../code_samples/lib/command_it/command_chaining_operators.dart#filter_example

### Map y Transform

<<< @/../code_samples/lib/command_it/command_chaining_operators.dart#map_example

## Gestión de Suscripciones

`pipeToCommand` retorna un `ListenableSubscription`. Siempre guárdalo y cancélalo para prevenir memory leaks.

### Limpieza Básica

<<< @/../code_samples/lib/command_it/command_chaining_cleanup.dart#cleanup_basic

### Múltiples Suscripciones

<<< @/../code_samples/lib/command_it/command_chaining_cleanup.dart#cleanup_multiple

### Piping Condicional

Habilita/deshabilita pipes en tiempo de ejecución:

<<< @/../code_samples/lib/command_it/command_chaining_cleanup.dart#cleanup_conditional

## Advertencia: Pipes Circulares

::: danger Evita Pipes Circulares
Nunca crees cadenas de pipes circulares - causan loops infinitos:

```dart
// ❌ PELIGRO: ¡Loop infinito!
commandA.pipeToCommand(commandB);
commandB.pipeToCommand(commandA);  // A dispara B dispara A dispara B...
```

Si necesitas comunicación bidireccional, usa guardas:

```dart
// ✅ Seguro: Guarda contra loops
bool _updating = false;

commandA.listen((value, _) {
  if (!_updating) {
    _updating = true;
    commandB(value);
    _updating = false;
  }
});
```
:::

## Referencia de API

```dart
extension ValueListenablePipe<T> on ValueListenable<T> {
  ListenableSubscription pipeToCommand<TTargetParam, TTargetResult>(
    Command<TTargetParam, TTargetResult> target, {
    TTargetParam Function(T value)? transform,
  })
}
```

**Parámetros:**
- `target` — El command a disparar cuando la fuente cambia
- `transform` — Función opcional para convertir el valor fuente al tipo de parámetro destino

**Retorna:** `ListenableSubscription` — Cancela esto para detener el pipe

## Ver También

- [Restricciones](/es/documentation/command_it/restrictions) — Deshabilitar commands basado en estado
- [Propiedades del Command](/es/documentation/command_it/command_properties) — Propiedades observables como `isRunning`
- [Operadores de listen_it](/es/documentation/listen_it/operators/overview) — Operadores como `debounce`, `where`, `map`
