# Efectos Secundarios con Handlers

Ya aprendiste las funciones [`watch()`](/documentation/watch_it/your_first_watch_functions.md) para reconstruir widgets. Pero ¿qué pasa con acciones que NO necesitan una reconstrucción, como llamar a una función, navegación, mostrar toasts, o logging?

Ahí es donde entran los **handlers**. Los handlers pueden reaccionar a cambios en [ValueListenables](#registerhandler-for-valuelistenables), [Listenables](#registerchangenotifierhandler-for-changenotifier), [Streams](#registerstreamhandler-for-streams), y [Futures](#registerfuturehandler-for-futures) sin disparar reconstrucciones de widget.

## registerHandler - Lo Básico

`registerHandler()` ejecuta un callback cuando los datos cambian, pero no dispara una reconstrucción:

<<< @/../code_samples/lib/watch_it/register_handler_basic_example.dart#example

**El patrón:**
1. `select` - Qué observar (como `watchValue`)
2. `handler` - Qué hacer cuando cambia
3. El handler recibe `context`, `value`, y función `cancel`

## Patrones Comunes de Handlers

::: details Navegación en Éxito {open}

<<< @/../code_samples/lib/watch_it/handler_navigation_example.dart#example

:::

::: details Llamar Funciones de Negocio

Uno de los usos más comunes de handlers es llamar comandos o métodos en objetos de negocio en respuesta a triggers:

<<< @/../code_samples/lib/watch_it/handler_trigger_business_object.dart#example

**Puntos clave:**
- El handler observa un trigger (envío de formulario, presión de botón, etc.)
- El handler llama comando/método en objeto de negocio
- El mismo widget puede opcionalmente observar el estado del comando (para indicadores de carga, etc.)
- Separación clara: handler dispara acción, watch muestra estado

:::

::: details Mostrar Snackbar

<<< @/../code_samples/lib/watch_it/handler_snackbar_example.dart#example

:::

## Watch vs Handler: Cuándo Usar Cada Uno

**Usa `watch()` cuando necesites RECONSTRUIR el widget:**

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#watch_vs_handler_watch

**Usa `registerHandler()` cuando necesites un EFECTO SECUNDARIO (sin reconstrucción):**

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#watch_vs_handler_handler

## Ejemplo Completo: Creación de Todo

Este ejemplo combina múltiples patrones de handler - navegación en éxito, manejo de errores, y observación de estado de carga:

<<< @/../code_samples/lib/watch_it/register_handler_example.dart#example

**Este ejemplo demuestra:**
- Observar resultado de comando para navegación
- Handler de error separado con UI de error
- Combinar `registerHandler()` (efectos secundarios) con `watchValue()` (estado de UI)
- Usar `createOnce()` para controllers

## El Parámetro `cancel`

Todos los handlers reciben una función `cancel`. Llámala para dejar de reaccionar:

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#cancel_parameter

**Caso de uso común**: Acciones de una sola vez

<<< @/../code_samples/lib/watch_it/handler_cancel_example.dart#example

## Tipos de Handler

`watch_it` proporciona handlers especializados para diferentes tipos de datos:

### registerHandler - Para ValueListenables

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#register_handler_generic

### registerStreamHandler - Para Streams

<<< @/../code_samples/lib/watch_it/register_stream_handler_example.dart#example

**Usar cuando:**
- Observar un Stream
- Quieres reaccionar a cada evento
- No necesitas mostrar el valor (sin reconstrucción)

### registerFutureHandler - Para Futures

<<< @/../code_samples/lib/watch_it/register_future_handler_example.dart#example

**Usar cuando:**
- Observar un Future
- Quieres ejecutar código cuando se complete
- No necesitas mostrar el valor

### registerChangeNotifierHandler - Para ChangeNotifier

<<< @/../code_samples/lib/watch_it/register_change_notifier_handler_example.dart#example

**Usar cuando:**
- Observar un `ChangeNotifier`
- Necesitas acceso al objeto notifier completo
- Quieres disparar acciones en cualquier cambio

## Patrones Avanzados

::: details Encadenar Acciones

Los handlers sobresalen en encadenar acciones - disparar una operación después de que otra se complete:

<<< @/../code_samples/lib/watch_it/handler_chain_actions_reload.dart#example

**Puntos clave:**
- El handler observa la completación del guardado
- El handler dispara recarga en otro servicio
- Patrón común: guardar → recargar lista, actualizar → refrescar datos
- Cada servicio permanece independiente

:::

::: details Manejo de Errores

<<< @/../code_samples/lib/watch_it/command_handler_error_example.dart#example

:::

::: details Acciones con Debounce

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#pattern4_debounced_actions

:::

## Configuración Opcional de Handler

Todas las funciones handler aceptan parámetros opcionales adicionales:

**`target`** - Proporciona un objeto local a observar (en lugar de usar get_it):
```dart
final myManager = UserManager();

registerHandler(
  select: (UserManager m) => m.currentUser,
  handler: (context, user, cancel) { /* ... */ },
  target: myManager, // Usa este objeto local, no get_it
);

// O proporciona el listenable/stream/future directamente sin selector
registerHandler(
  handler: (context, user, cancel) { /* ... */ },
  target: myValueNotifier, // Observa este ValueNotifier directamente
);
```

::: warning Importante
Si se usa `target` como el objeto observable (listenable/stream/future) y cambia durante construcciones con `allowObservableChange: false` (el predeterminado), se lanzará una excepción. Establece `allowObservableChange: true` si el observable target necesita cambiar entre construcciones.
:::

**`allowObservableChange`** - Controla el comportamiento de caché del selector (predeterminado: `false`):

Ver [Safety: Automatic Caching in Selector Functions](/documentation/watch_it/watching_multiple_values.md#safety-automatic-caching-in-selector-functions) para explicación detallada de este parámetro.

**`executeImmediately`** - Ejecuta handler en la primera construcción con el valor actual (predeterminado: `false`):
```dart
registerHandler(
  select: (DataManager m) => m.data,
  handler: (context, value, cancel) { /* ... */ },
  executeImmediately: true, // Handler llamado inmediatamente con valor actual
);
```

Cuando es `true`, el handler se llama en la primera construcción con el valor actual del objeto observado, sin esperar un cambio. El handler luego continúa ejecutándose en cambios subsiguientes.

## Árbol de Decisión Handler vs Watch

**Pregúntate: "¿Este cambio necesita actualizar la UI?"**

**Sí** → Usa `watch()`:

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#decision_tree_watch

**NO (¿Debería llamar a una función, navegar, mostrar un toast, etc?)** → Usa `registerHandler()`:

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#decision_tree_handler

**Importante**: No puedes actualizar variables locales dentro de un handler que se usarán en la función build fuera del handler. Los handlers no disparan reconstrucciones, por lo que cualquier cambio de variable no se reflejará en la UI. Si necesitas actualizar la UI, usa `watch()` en su lugar.

## Errores Comunes

### ❌️ Usar watch() para navegación

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#mistake_bad

### ✅ Usar handler para navegación

<<< @/../code_samples/lib/watch_it/handler_patterns.dart#mistake_good

## ¿Qué Sigue?

Ahora sabes cuándo reconstruir (watch) vs cuándo ejecutar efectos secundarios (handlers). Siguiente:

- [Observing Commands](/documentation/watch_it/observing_commands.md) - Integración comprehensiva con command_it
- [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) - Restricciones CRÍTICAS
- [Lifecycle Functions](/documentation/watch_it/lifecycle.md) - `callOnce`, `createOnce`, etc.

## Puntos Clave

✅ `watch()` = Reconstruir el widget
✅ `registerHandler()` = Efecto secundario (navegación, toast, etc.)
✅ Los handlers reciben `context`, `value`, y `cancel`
✅ Usa `cancel()` para acciones de una sola vez
✅ Combina watch y handlers en el mismo widget
✅ Elige basándote en: "¿Esto necesita actualizar la UI?"

## Ver También

- [Your First Watch Functions](/documentation/watch_it/your_first_watch_functions.md) - Aprende lo básico de watch
- [Observing Commands](/documentation/watch_it/observing_commands.md) - Integración con command_it
- [Watch Functions Reference](/documentation/watch_it/watch_functions.md) - Docs completos de API
