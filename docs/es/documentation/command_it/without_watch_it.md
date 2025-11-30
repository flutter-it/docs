# Usando Commands sin `watch_it`

Todos los ejemplos en [Primeros Pasos](getting_started.md) usan **`watch_it`**, que es nuestro enfoque recomendado para apps en producción. Sin embargo, los commands funcionan perfectamente con `ValueListenableBuilder` simple o cualquier solución de gestión de estado que pueda observar un `Listenable` (como Provider o Riverpod).

## Navegación Rápida

| Enfoque | Mejor Para |
|---------|----------|
| [ValueListenableBuilder](#cuando-usar-valuelistenablebuilder) | Aprendizaje, prototipado, no se necesita DI |
| [CommandBuilder](#commandbuilder-lo-mas-facil) | Enfoque más simple con builders conscientes de estado |
| [CommandResult](#usando-commandresult) | Un solo builder para todos los estados del command |
| [StatefulWidget + .listen()](#patrones-con-statefulwidget) | Efectos secundarios (diálogos, navegación) |
| [Provider](#integracion-con-provider) | Apps existentes con Provider |
| [Riverpod](#integracion-con-riverpod) | Apps existentes con Riverpod |
| [flutter_hooks](#integracion-con-flutter_hooks) | Llamadas directas estilo watch (¡similar a `watch_it`!) |
| [Bloc/Cubit](#sobre-bloc-cubit) | Por qué los commands reemplazan Bloc para estado async |

## Cuándo Usar ValueListenableBuilder

Considera usar `ValueListenableBuilder` en lugar de `watch_it` cuando:
- Estás prototipando o aprendiendo y quieres minimizar dependencias
- Tienes un widget simple que no necesita inyección de dependencias
- Prefieres patrones de builder explícitos sobre observación implícita
- Estás trabajando en un proyecto que no usa `get_it`

Para apps en producción, aún recomendamos [`watch_it`](/es/documentation/watch_it/observing_commands) para código más limpio y mantenible.

::: tip Enfoque Más Fácil: CommandBuilder
Si quieres la forma más simple de usar commands sin `watch_it`, considera `CommandBuilder` - un widget que maneja todos los estados del command con mínimo boilerplate. Es más limpio que patrones manuales de `ValueListenableBuilder`. Salta a [ejemplo de CommandBuilder](#commandbuilder-lo-mas-facil) o ver [Command Builders](command_builders.md) para documentación completa.
:::

## Ejemplo Simple de Contador

Aquí está el ejemplo básico de contador usando `ValueListenableBuilder`:

<<< @/../code_samples/lib/command_it/counter_simple_sync.dart#example

**Puntos clave:**
- Usa `ValueListenableBuilder` para observar el command
- Usa `StatelessWidget` en lugar de `WatchingWidget`
- No se necesita registro en `get_it` - el servicio puede crearse directamente en el widget
- El command sigue siendo un `ValueListenable`, solo se observa diferente

## Ejemplo Async con Estados de Carga

Aquí está el ejemplo de clima mostrando commands async con indicadores de carga:

<<< @/../code_samples/lib/command_it/loading_state_example.dart#example

**Puntos clave:**
- Observa `isRunning` con un `ValueListenableBuilder` separado para estado de carga
- Se requieren builders anidados - uno para estado de carga, uno para datos
- Más verbose que `watch_it` pero funciona sin dependencias adicionales
- Todas las características de commands (async, manejo de errores, restricciones) aún funcionan

## Comparando los Enfoques

Para ejemplos de `watch_it`, ver [Observando Commands con `watch_it`](/es/documentation/watch_it/observing_commands).

| Aspecto | `watch_it` | ValueListenableBuilder |
|---------|----------|------------------------|
| **Dependencias** | Requiere `get_it` + `watch_it` | Sin dependencias adicionales |
| **Widget Base** | `WatchingWidget` | `StatelessWidget` o `StatefulWidget` |
| **Observación** | `watchValue((Service s) => s.command)` | `ValueListenableBuilder(valueListenable: command, ...)` |
| **Múltiples Propiedades** | Limpio - llamadas `watchValue` separadas | Se requieren builders anidados |
| **Boilerplate** | Mínimo | Más verbose |
| **Recomendado Para** | Apps en producción | Aprendizaje, prototipado |

## Usando CommandResult

Para la experiencia más limpia con `ValueListenableBuilder`, usa `CommandResult` para observar todo el estado del command en un solo builder:

```dart
class MyWidget extends StatelessWidget {
  final myCommand = Command.createAsync<void, String>(
    () async => 'Hola',
    initialValue: '',
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CommandResult<void, String>>(
      valueListenable: myCommand.results,
      builder: (context, result, _) {
        if (result.isRunning) {
          return CircularProgressIndicator();
        }

        if (result.hasError) {
          return Text('Error: ${result.error}');
        }

        return Text(result.data);
      },
    );
  }
}
```

Ver [Command Results](command_results.md) para más detalles sobre usar `CommandResult`.

## Patrones con StatefulWidget

Cuando necesitas reaccionar a eventos del command (como errores o cambios de estado) sin reconstruir la UI, usa un `StatefulWidget` con suscripciones `.listen()` en `initState`.

### Manejo de Errores con .listen()

Aquí está cómo manejar errores y mostrar diálogos usando StatefulWidget:

<<< @/../code_samples/lib/command_it/error_handling_stateful_example.dart#example

**Puntos clave:**
- Suscríbete a `.errors` en `initState` - se ejecuta una vez, no en cada build
- Usa `.where((e) => e != null)` para filtrar valores null (emitidos al inicio de ejecución)
- **CRÍTICO:** Cancela suscripciones en `dispose()` para prevenir memory leaks
- Almacena `StreamSubscription` para cancelar después
- Verifica `mounted` antes de mostrar diálogos para evitar errores en widgets disposed
- Dispone el command en `dispose()` para limpiar recursos

**Cuándo usar StatefulWidget + .listen():**
- Necesitas reaccionar a eventos (errores, cambios de estado) con efectos secundarios
- Quieres mostrar diálogos, disparar navegación, o loguear eventos
- Prefieres gestión explícita de suscripciones

**Importante:** ¡Siempre cancela suscripciones en `dispose()` para prevenir memory leaks!

::: tip ¿Quieres Limpieza Automática?
Para limpieza automática de suscripciones, considera usar `registerHandler` de `watch_it` - ver [Observando Commands con `watch_it`](/es/documentation/watch_it/observing_commands) para patrones que eliminan la gestión manual de suscripciones.
:::

Para más patrones de manejo de errores, ver [Propiedades del Command - Notificaciones de Error](/es/documentation/command_it/command_properties#errors---notificaciones-de-error).

## Observando canRun

La propiedad `canRun` automáticamente combina el estado de restricción y el estado de ejecución del command, haciéndola perfecta para habilitar/deshabilitar elementos de UI:

<<< @/../code_samples/lib/command_it/can_run_example.dart#example

**Puntos clave:**
- `canRun` es `false` cuando el command está ejecutándose O restringido
- Perfecto para `onPressed` de botón - deshabilita automáticamente durante ejecución
- Más limpio que verificar manualmente tanto `isRunning` como estado de restricción
- Se actualiza automáticamente cuando cualquier estado cambia

## Eligiendo Tu Enfoque

Cuando usas commands sin `watch_it`, tienes varias opciones:

### CommandBuilder (Lo Más Fácil)

**Mejor para:** Enfoque más simple con builders dedicados para cada estado

```dart
CommandBuilder(
  command: loadDataCommand,
  whileRunning: (context, _, __) => CircularProgressIndicator(),
  onError: (context, error, _, __) => Text('Error: $error'),
  onData: (context, data, _) => ListView(
    children: data.map((item) => ListTile(title: Text(item))).toList(),
  ),
)
```

**Pros:** Código más limpio, builders separados para cada estado, sin verificación manual de estado
**Contras:** Widget adicional en el árbol

Ver [Command Builders](command_builders.md) para documentación completa.

### ValueListenableBuilder con CommandResult

**Mejor para:** La mayoría de casos - un solo builder maneja todos los estados

```dart
ValueListenableBuilder<CommandResult<TParam, TResult>>(
  valueListenable: command.results,
  builder: (context, result, _) {
    if (result.isRunning) return LoadingWidget();
    if (result.hasError) return ErrorWidget(result.error);
    return DataWidget(result.data);
  },
)
```

**Pros:** Limpio, todo el estado en un solo lugar, sin anidación
**Contras:** Reconstruye UI en cada cambio de estado

### ValueListenableBuilders Anidados

**Mejor para:** Cuando necesitas diferente granularidad de rebuilds

```dart
ValueListenableBuilder<bool>(
  valueListenable: command.isRunning,
  builder: (context, isRunning, _) {
    if (isRunning) return LoadingWidget();
    return ValueListenableBuilder<TResult>(
      valueListenable: command,
      builder: (context, data, _) => DataWidget(data),
    );
  },
)
```

**Pros:** Control granular sobre rebuilds
**Contras:** La anidación puede volverse compleja con múltiples propiedades

### StatefulWidget + .listen()

**Mejor para:** Efectos secundarios (diálogos, navegación, logging)

```dart
class _MyWidgetState extends State<MyWidget> {
  ListenableSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = command.errors
      .where((e) => e != null)
      .listen((error, _) {
        if (mounted) showDialog(...);
      });
  }

  @override
  void dispose() {
    _subscription?.cancel();  // CRÍTICO: Prevenir memory leaks
    super.dispose();
  }
}
```

**Pros:** Separa efectos secundarios de UI, se ejecuta una vez, control total
**Contras:** Debe gestionar suscripciones manualmente, más boilerplate

**Árbol de decisión:**
1. ¿Quieres el enfoque más simple? → CommandBuilder
2. ¿Necesitas efectos secundarios (diálogos, navegación)? → StatefulWidget + .listen()
3. ¿Observando múltiples estados? → CommandResult
4. ¿Necesitas rebuilds granulares? → Builders anidados

::: tip ¿Quieres Código Aún Más Limpio?
`registerHandler` de `watch_it` proporciona limpieza automática de suscripciones. Ver [Observando Commands con `watch_it`](/es/documentation/watch_it/observing_commands) si quieres eliminar la gestión manual de suscripciones completamente.
:::

## Integración con Otras Soluciones de Gestión de Estado

Los Commands se integran bien con otras soluciones de gestión de estado (`watch_it` es la nuestra). Como cada propiedad del command (`isRunning`, `errors`, `results`, etc.) es en sí un `ValueListenable`, cualquier solución que pueda observar un `Listenable` puede observarlas con rebuilds granulares.

### Integración con Provider

Usa `ListenableProvider` para observar propiedades específicas del command:

<<< @/../code_samples/lib/command_it/provider_integration.dart#manager

**Setup con ChangeNotifierProvider:**

<<< @/../code_samples/lib/command_it/provider_integration.dart#setup

**Observación granular con ListenableProvider:**

<<< @/../code_samples/lib/command_it/provider_integration.dart#granular

**Puntos clave:**
- Usa `context.read<Manager>()` para obtener el manager sin escuchar
- Usa `ListenableProvider.value()` para proporcionar propiedades específicas del command
- Cada propiedad (`isRunning`, `results`, etc.) es un `Listenable` separado
- Solo los widgets observando esa propiedad específica se reconstruyen cuando cambia

### Integración con Riverpod

Con la anotación `@riverpod` de Riverpod, crea providers para propiedades específicas del command:

<<< @/../code_samples/lib/command_it/riverpod_integration.dart#providers

**En tu widget:**

<<< @/../code_samples/lib/command_it/riverpod_integration.dart#widget

**Puntos clave:**
- Usa wrapper `Raw<T>` para prevenir que Riverpod auto-dispose los notifiers
- Usa `ref.onDispose()` para limpiar commands cuando el provider se dispone
- Crea providers separados para cada propiedad del command que quieras observar
- Requiere paquete `riverpod_annotation` y generación de código (`build_runner`)

### Integración con flutter_hooks

flutter_hooks proporciona un patrón de observación directa muy similar a `watch_it`! Usa `useValueListenable` para observación limpia y declarativa:

**Setup del manager:**

<<< @/../code_samples/lib/command_it/flutter_hooks_integration.dart#manager

**En tu widget:**

<<< @/../code_samples/lib/command_it/flutter_hooks_integration.dart#widget

**Puntos clave:**
- `useValueListenable` proporciona llamadas directas estilo watch - ¡sin builders anidados!
- El patrón es muy similar a `watchValue` de `watch_it`
- Cada llamada a `useValueListenable` observa una propiedad específica para rebuilds granulares
- Requiere paquete `flutter_hooks`

### Sobre Bloc/Cubit

Commands y Bloc/Cubit resuelven el mismo problema - gestionar estado de operaciones async. Usar ambos crea redundancia:

| Característica | command_it | Bloc/Cubit |
|----------------|-----------|------------|
| Estado de carga | `command.isRunning` | `LoadingState()` |
| Manejo de errores | `command.errors` | `ErrorState(error)` |
| Resultado/Datos | `command.value` | `LoadedState(data)` |
| Ejecución | `command.run()` | `emit()` / `add(Event)` |
| Restricciones | `command.canRun` | Lógica manual |
| Tracking de progreso | `command.progress` | Implementación manual |

**Recomendación:** Elige un enfoque. Si ya estás usando Bloc/Cubit para operaciones async, no necesitas commands para esas operaciones. Si quieres usar commands, reemplazan la necesidad de Bloc/Cubit en gestión de estado async.

## Siguientes Pasos

¿Listo para aprender más?

- **¿Quieres usar `watch_it`?** Ver [Observando Commands con `watch_it`](/es/documentation/watch_it/observing_commands) para patrones comprehensivos
- **¿Necesitas más características de commands?** Revisa [Propiedades del Command](command_properties.md), [Manejo de Errores (Error Handling)](error_handling.md), y [Restricciones](restrictions.md)
- **¿Construyendo apps de producción?** Lee [Mejores Prácticas](best_practices.md) para guía de arquitectura

Para más sobre `watch_it` y por qué lo recomendamos, ver la [documentación de `watch_it`](/es/documentation/watch_it/getting_started.md).
