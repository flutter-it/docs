# Testing de Commands

Aprende cómo escribir tests efectivos para commands, verificar transiciones de estado, y probar manejo de errores. command_it está diseñado para ser altamente testeable.

## Por Qué los Commands Son Fáciles de Testear

Los Commands proporcionan interfaces claras para testing:

- **Estado observable**: Todos los cambios de estado via `ValueListenable`
- **Comportamiento predecible**: Run → ejecutar → notificar
- **Contención de errores**: Los errores no crashean tests
- **Sin dependencias de UI**: Testea lógica de negocio independientemente

## Patrón Básico de Testing

<<< @/../code_samples/test/command_it/command_testing_example_test.dart#example

## El Patrón Collector

Usa un helper `Collector` para acumular emisiones de `ValueListenable`:

```dart
class Collector<T> {
  List<T>? values;

  void call(T value) {
    values ??= <T>[];
    values!.add(value);
  }

  void reset() {
    values?.clear();
    values = null;
  }
}

// Uso en tests
final resultCollector = Collector<String>();
command.listen((result, _) => resultCollector(result));

await command.runAsync();

expect(resultCollector.values, ['initial', 'loaded data']);
```

**¿Por qué este patrón?**

Los Commands están diseñados para funcionar **asíncronamente sin ser awaited** - están hechos para ser **observados**, no awaited. Este es el principio arquitectural central de command_it:

- Los Commands emiten cambios de estado via `ValueListenable` (results, errors, isRunning)
- La UI observa commands reactivamente, no via `await`
- Los tests necesitan verificar la **secuencia** de valores emitidos
- Collector acumula todas las emisiones para que puedas hacer assertions sobre transiciones de estado completas

Mientras `runAsync()` es útil cuando necesitas hacer await de un resultado (como con `RefreshIndicator`), el patrón Collector testea commands de la manera en que típicamente se usan: dispara-y-olvida con observación.

## Testing de Commands Async

### Usando runAsync()

```dart
test('Command async se ejecuta exitosamente', () async {
  final command = Command.createAsyncNoParam<String>(
    () async {
      await Future.delayed(Duration(milliseconds: 100));
      return 'resultado';
    },
    initialValue: '',
  );

  // Await del resultado
  final result = await command.runAsync();

  expect(result, 'resultado');
});
```

## Testing de Manejo de Errores

### Testing Básico de Errores

```dart
test('Command maneja errores', () async {
  final errorCollector = Collector<CommandError?>();

  final command = Command.createAsyncNoParam<String>(
    () async {
      throw Exception('Error de prueba');
    },
    initialValue: '',
  );

  command.errors.listen((error, _) => errorCollector(error));

  try {
    await command.runAsync();
    fail('Debería haber lanzado');
  } catch (e) {
    expect(e.toString(), contains('Error de prueba'));
  }

  // errors emite null primero, luego el error
  expect(errorCollector.values?.length, 2);
  expect(errorCollector.values?.last?.error.toString(), contains('Error de prueba'));
});
```

### Testing de ErrorFilters

```dart
test('ErrorFilter enruta errores correctamente', () async {
  var localHandlerCalled = false;
  var globalHandlerCalled = false;

  Command.globalExceptionHandler = (error, stackTrace) {
    globalHandlerCalled = true;
  };

  final command = Command.createAsyncNoParam<String>(
    () => throw Exception('Error de prueba'),
    initialValue: '',
    errorFilter: PredicatesErrorFilter([
      (error, stackTrace) => ErrorReaction.localHandler,
    ]),
  );

  command.errors.listen((error, _) {
    if (error != null) localHandlerCalled = true;
  });

  try {
    await command.runAsync();
  } catch (_) {}

  expect(localHandlerCalled, true);
  expect(globalHandlerCalled, false); // Solo local
});
```

## MockCommand

Para testing de código que depende de commands, usa la clase incorporada `MockCommand` para crear entornos de test controlados. El patrón de abajo muestra cómo crear un manager real con commands reales, luego una versión mock para testing.

<<< @/../code_samples/test/command_it/mock_command_example_test.dart#example

**Métodos clave de MockCommand:**

- **<code>queueResultsForNextRunCall(List&lt;CommandResult&lt;TParam, TResult&gt;&gt;)</code>** - Encola múltiples resultados para ser retornados en secuencia
- **`startRun()`** - Dispara manualmente el estado running
- **`endRunWithData(TResult data)`** - Completa ejecución con un resultado
- **`endRunNoData()`** - Completa ejecución sin resultado (commands void)
- **`endRunWithError(String message)`** - Completa ejecución con un error
- **`runCount`** - Trackea cuántas veces se ejecutó el command

### Control Automático vs Manual de Estado

**Importante:** El método `run()` de MockCommand **automáticamente alterna `isRunning`**, pero sucede **síncronamente**:

```dart
// Cuando llamas run():
mockCommand.run('param');
// isRunning va: false → true → false (instantáneamente)
```

Este toggle síncrono significa que típicamente no capturarás el estado `true` en tests. Para testing de transiciones de estado, usa los **métodos de control manual**:

**Control Manual (Recomendado para Testing):**

```dart
final mockCommand = MockCommand<String, String>(initialValue: '');

// Tú controlas cuándo cambia el estado
mockCommand.startRun('param');              // isRunning = true
expect(mockCommand.isRunning.value, true);  // ✅ Puede verificar estado de carga

// Después, completa la operación
mockCommand.endRunWithData('resultado');    // isRunning = false
expect(mockCommand.isRunning.value, false); // ✅ Puede verificar estado completado
```

**Automático via run() (Dispara-y-Olvida Rápido):**

```dart
final mockCommand = MockCommand<String, String>(initialValue: '');

// Encola resultados primero
mockCommand.queueResultsForNextRunCall([
  CommandResult('param', 'resultado', null, false),
]);

// Luego run - isRunning brevemente true, luego inmediatamente false
mockCommand.run('param');

// isRunning ya es false ahora (síncrono)
expect(mockCommand.isRunning.value, false);
```

**Usa métodos de control manual cuando:**
- Testing de UI de estado loading/running
- Verificando transiciones de estado en secuencia
- Testing de manejo de estado de error
- Simulando operaciones de larga duración

**Usa `run()` + `queueResultsForNextRunCall()` cuando:**
- Solo te importa el resultado final
- Testing de resultados simples de éxito/error
- No necesitas verificar estados intermedios

**Este patrón demuestra:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Servicio real con command real usando <code>get_it</code> para dependencias</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Servicio mock implementa servicio real y sobrescribe command con MockCommand</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Métodos de control hacen código de test legible y mantenible</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Manager usa <code>get_it</code> para acceder al servicio (inyección de dependencias completa)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Tests registran servicio mock para controlar comportamiento del command</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Sin delays async - tests corren instantáneamente</li>
</ul>

**Cuándo usar MockCommand:**

- Testing de código que depende de commands sin delays async
- Testing de manejo de estados loading, éxito, y error
- Testing unitario de servicios que coordinan commands
- Cuando necesitas control preciso sobre transiciones de estado de commands

## Ver También

- [Fundamentos de Command](/es/documentation/command_it/command_basics) — Creando commands
- [Propiedades del Command](/es/documentation/command_it/command_properties) — Propiedades observables
- [Manejo de Errores (Error Handling)](/es/documentation/command_it/error_handling) — Gestión de errores
- [Mejores Prácticas](/es/documentation/command_it/best_practices) — Patrones de producción
