<div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 2rem;">
  <img src="/images/command_it.svg" alt="command_it logo" width="100" />
  <h1 style="margin: 0;">Primeros Pasos</h1>
</div>

command_it es una forma de gestionar tu estado basada en `ValueListenable` y el patrón de diseño `Command`. Un `Command` es un objeto que envuelve una función, haciéndola invocable mientras proporciona actualizaciones de estado reactivas—perfecto para conectar tu UI con la lógica de negocio.

![Flujo de datos command_it](/images/command-it-flow.svg)

## Instalación

Añade a tu `pubspec.yaml`:

```yaml
dependencies:
  command_it: ^2.0.0
```

Para la configuración recomendada con `watch_it` y `get_it`, simplemente importa `flutter_it`:

```yaml
dependencies:
  flutter_it: ^1.0.0
```

## ¿Por Qué Commands?

Cuando empecé con Flutter, el enfoque más recomendado era `BLoC`. Pero enviar objetos a un `StreamController` para disparar procesos nunca me pareció correcto—debería sentirse como llamar a una función. Viniendo del mundo .NET, estaba acostumbrado a Commands: objetos invocables que automáticamente deshabilitan su botón disparador mientras se ejecutan y emiten resultados de forma reactiva.

Porté este concepto a Dart con [rx_command](https://pub.dev/packages/rx_command), pero los Streams se sentían pesados. Después de que Remi Rousselet me convenciera de lo más simples que son los `ValueNotifiers`, creé command_it: toda la potencia del patrón Command, cero Streams, 100% `ValueListenable`.

## Concepto Central

Un `Command` es:
1. **Un envoltorio de función** - Encapsula funciones sync/async como objetos invocables
2. **Un ValueListenable** - Publica resultados de forma reactiva para que tu UI pueda observar cambios
3. **Tipado seguro** - `Command<TParam, TResult>` donde `TParam` es el tipo de entrada y `TResult` es el tipo de salida

::: tip El Patrón Command
La filosofía central: **Inicia commands con `run()` (dispara y olvida), luego tu app/UI observa y reacciona a sus cambios de estado**. Este patrón reactivo mantiene tu UI responsiva sin bloqueos—disparas la acción y dejas que tu UI responda automáticamente a estados de carga, resultados y errores.
:::

Aquí está el ejemplo más simple posible usando **`watch_it`** (el enfoque recomendado):

<<< @/../code_samples/lib/command_it/counter_watch_it.dart#example

**Puntos clave:**
- Crea con `Command.createSyncNoParam<TResult>()` (ver [Tipos de Command](command_types.md) para diferentes firmas)
- Command tiene un **método `.run`** - úsalo como tearoff para `onPressed`
- Usa **`watchValue`** para observar el command - se reconstruye automáticamente cuando el valor cambia
- Registra tu servicio con `get_it` (llama a setup en `main()`), extiende `WatchingWidget` para la funcionalidad de `watch_it`
- El valor inicial es requerido para que la UI tenga algo que mostrar inmediatamente

::: tip Usando Commands sin `watch_it`
Los Commands también funcionan con `ValueListenableBuilder` simple si prefieres no usar `watch_it`. Ver [Sin `watch_it`](without_watch_it.md) para ejemplos. Para más información sobre `watch_it`, consulta la [documentación de `watch_it`](/es/documentation/watch_it/getting_started.md).
:::

## Ejemplo Real: Commands Async con Estados de Carga

La mayoría de apps reales necesitan operaciones async (llamadas HTTP, consultas a base de datos, etc.). Los Commands hacen esto trivial al rastrear el estado de ejecución automáticamente. Aquí hay un ejemplo con **`watch_it`**:

<<< @/../code_samples/lib/command_it/watch_it_simple.dart#example

**Qué está pasando:**
1. `Command.createAsync<TParam, TResult>()` envuelve una función async
2. `watchValue` observa tanto el resultado del command COMO su propiedad `isRunning`
3. La UI automáticamente muestra un indicador de carga mientras el command se ejecuta
4. Sin widgets `ValueListenableBuilder` anidados - `watch_it` mantiene el código limpio
5. El parámetro del command (`'London'`) se pasa a la función envuelta

Este patrón elimina el boilerplate de rastrear manualmente estados de carga y builders anidados → commands + `watch_it` manejan todo por ti.

::: tip Los Commands Siempre Notifican (Por Defecto)
Los Commands notifican a los listeners en **cada ejecución**, incluso si el valor del resultado es idéntico. Esto es intencional porque:

1. **Las acciones del usuario necesitan feedback** - Al hacer clic en "Actualizar", los usuarios esperan indicadores de carga incluso si los datos no han cambiado
2. **El estado cambia durante la ejecución** - `isRunning`, `CommandResult` y los estados de error se actualizan durante la operación async
3. **La acción importa, no solo el resultado** - El command se ejecutó (API llamada, archivo guardado), lo cual es importante independientemente del valor de retorno

**Cuándo usar `notifyOnlyWhenValueChanges: true`:**
- Commands de cómputo puro donde solo importa el resultado
- Actualizaciones de alta frecuencia donde resultados idénticos deberían ignorarse
- Optimización de rendimiento cuando los listeners son costosos

Para la mayoría de escenarios reales con acciones de usuario y operaciones async, el comportamiento por defecto es lo que quieres.
:::

## Conceptos Clave de un Vistazo

command_it ofrece características potentes para apps en producción:

### Propiedades del Command

El **command mismo** es un `ValueListenable<TResult>` que publica el resultado. Los Commands también exponen propiedades observables adicionales:
- **`value`** - Getter de propiedad para el resultado actual (no es un ValueListenable, solo el valor)
- **`isRunning`** - `ValueListenable<bool>` que indica si el command se está ejecutando actualmente (solo commands async)
- **`canRun`** - `ValueListenable<bool>` combinando `!isRunning && !restriction` (ver restricciones abajo)
- **`errors`** - `ValueListenable<CommandError?>` de errores de ejecución

Ver [Propiedades del Command](command_properties.md) para detalles.

### CommandResult

En lugar de observar múltiples propiedades por separado, usa `results` para obtener estado comprehensivo:

```dart
command.results // ValueListenable<CommandResult<TParam, TResult>>
```

`CommandResult` combina `data`, `error`, `isRunning` y `paramData` en un objeto. Perfecto para estados de UI comprehensivos de error/carga/éxito.

Ver [Command Results](command_results.md) para detalles.

### Control de Progreso

Rastrea el progreso de operaciones, muestra mensajes de estado y permite cancelación con la característica integrada de **Control de Progreso**:

<<< @/../code_samples/lib/command_it/progress_upload_basic.dart#example

```dart
// En UI:
watchValue((MyService s) => s.uploadCommand.progress)  // 0.0 a 1.0
watchValue((MyService s) => s.uploadCommand.statusMessage)  // Texto de estado
uploadCommand.cancel()  // Solicitar cancelación
```

**Todos los commands** exponen propiedades de progreso (incluso sin factory `WithProgress`) - los commands sin progreso simplemente devuelven valores por defecto con cero overhead.

Ver [Control de Progreso](progress_control.md) para detalles.

### Manejo de Errores (Error Handling)

Los Commands capturan excepciones automáticamente y las publican via la propiedad `errors`. Puedes usar operadores de **listen_it** para filtrar y manejar tipos de error específicos:

```dart
command.errors.where((error) => error?.error is NetworkError).listen((error, _) {
  showSnackbar('Error de red: ${error!.error.message}');
});
```

Para escenarios avanzados, usa **filtros de error** para enrutar diferentes tipos de error a nivel de command. Ver [Manejo de Errores](error_handling.md) para detalles.

### Restricciones

Controla cuándo un command puede ejecutarse pasando un `ValueListenable<bool>` como restricción:

```dart
final isOnline = ValueNotifier(true);

final command = Command.createAsync(
  fetchData,
  initialValue: [],
  restriction: isOnline, // El command solo se ejecuta cuando isOnline.value == true
);
```

Debido a que es un `ValueNotifier` pasado al constructor, un command puede habilitarse y deshabilitarse en cualquier momento cambiando el valor del notifier.

Ver [Restricciones](restrictions.md) para detalles.

## Siguientes Pasos

Elige tu ruta de aprendizaje basándote en tu objetivo:

### 📚 Quiero aprender los fundamentos
Empieza con [Fundamentos de Command](command_basics.md) para entender:
- Todos los métodos factory de command (sync/async, con/sin parámetros)
- Cómo ejecutar commands programáticamente vs. con triggers de UI
- Valores de retorno y valores iniciales

### ⚡ Quiero construir una característica real
Sigue el [Tutorial de App del Clima](/examples/command_it/weather_app_tutorial.md) para construir una característica completa:
- Commands async con llamadas API reales
- Debouncing de entrada de usuario
- Estados de carga y manejo de errores
- Restricciones de command
- Múltiples commands trabajando juntos

### 🛡️ Necesito manejo de errores robusto
Revisa [Manejo de Errores](error_handling.md):
- Capturar y mostrar errores
- Enrutar diferentes tipos de error a diferentes handlers
- Lógica de reintento y estrategias de fallback

### 🎯 Quiero patrones listos para producción
Ver [Mejores Prácticas](best_practices.md) para:
- Cuándo usar commands vs. otros patrones
- Evitar errores comunes
- Optimización de rendimiento
- Recomendaciones de arquitectura

### 🧪 Necesito escribir tests
Ve a [Testing](testing.md) para:
- Testing unitario de commands en aislamiento
- Widget testing con commands
- Mocking de respuestas de command
- Testing de escenarios de error

## Referencia Rápida

| Tema | Enlace |
|------|--------|
| Crear commands (todos los métodos factory) | [Fundamentos de Command](command_basics.md) |
| Tipos de command (firmas) | [Tipos de Command](command_types.md) |
| Propiedades observables (value, isRunning, etc.) | [Propiedades del Command](command_properties.md) |
| CommandResult (estado comprehensivo) | [Command Results](command_results.md) |
| Widget CommandBuilder | [Command Builders](command_builders.md) |
| Manejo de errores y enrutamiento | [Manejo de Errores](error_handling.md) |
| Ejecución condicional | [Restricciones](restrictions.md) |
| Patrones de testing | [Testing](testing.md) |
| Integración con `watch_it` | [Observando Commands con `watch_it`](/es/documentation/watch_it/observing_commands) |
| Patrones de producción | [Mejores Prácticas](best_practices.md) |

¡Listo para profundizar? ¡Elige un tema de la [Referencia Rápida](#referencia-rapida) de arriba o sigue una de las rutas de aprendizaje en [Siguientes Pasos](#siguientes-pasos)!
