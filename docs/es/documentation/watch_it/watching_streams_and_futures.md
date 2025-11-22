# Observando Streams y Futures

Ya aprendiste a observar datos síncronos. Ahora manejemos datos async con Streams y Futures.

## ¿Por Qué Funciones Especiales?

Streams y Futures son diferentes de `Listenable`:
- **Stream** - Emite múltiples valores a lo largo del tiempo
- **Future** - Se completa una vez con un valor
- Ambos tienen estados de carga/error

`watch_it` proporciona `watchStream()` y `watchFuture()` - como `StreamBuilder` y `FutureBuilder`, pero en una línea.

## watchStream - Streams Reactivos

Reemplaza `StreamBuilder` con `watchStream()`:

<<< @/../code_samples/lib/watch_it/chat_watch_stream_example.dart#example

### Manejando Estados de Stream

<<< @/../code_samples/lib/watch_it/user_activity_stream_example.dart#example

::: tip AsyncSnapshot y Null Safety
Cuando proporcionas un **initialValue no-null** y usas un **tipo de stream no-nullable** (como `Stream<String>`), `AsyncSnapshot.data` no será null. Comienza con tu valor inicial y se actualiza con eventos del stream:

<<< @/../code_samples/lib/watch_it/async_snapshot_always_has_value.dart#example

**Nota:** Si tu tipo de stream es nullable (como `Stream<String?>`), entonces los eventos del stream pueden emitir valores null, haciendo que `snapshot.data` sea null incluso con un `initialValue` no-null.
:::

### Comparar con StreamBuilder

**Sin `watch_it`:**

<<< @/../code_samples/lib/watch_it/stream_builder_comparison.dart#example

¡Mucho más anidado y verboso!

### Uso Avanzado de watchStream

#### Observar Streams Locales (parámetro target)

Si tu stream no está registrado en `get_it`, usa el parámetro `target`:

<<< @/../code_samples/lib/watch_it/watch_stream_with_target.dart#example

**Cuándo usar:**
- Stream pasado como parámetro de widget
- Streams creados localmente
- Streams de packages externos

#### Permitir Cambios de Stream (allowStreamChange)

Por defecto, `watchStream` se comporta diferente dependiendo de cómo proporciones el stream:

- **Con función `select`:** Llama al selector una vez para prevenir crear múltiples streams en cada reconstrucción
- **Con parámetro `target`:** Lanza error si la instancia del stream cambia entre reconstrucciones

Establece `allowStreamChange: true` si esperas que el stream cambie legítimamente entre reconstrucciones:

<<< @/../code_samples/lib/watch_it/watch_stream_allow_change.dart#example

**Qué sucede con `allowStreamChange: true`:**
- La función selectora se llama y evalúa en cada construcción
- Si la instancia del stream cambió, `watchStream` automáticamente se desuscribe del stream antiguo
- Se suscribe al nuevo stream
- El widget se reconstruye con datos del nuevo stream

**Cuándo usar:**
- El stream depende de parámetros reactivos (como ID de sala seleccionada)
- Cambiar entre diferentes streams basados en entrada del usuario
- **Importante:** Solo usa cuando el stream debería realmente cambiar, no cuando accidentalmente se recrea el mismo stream

#### Firma Completa del Método

```dart
AsyncSnapshot<R> watchStream<T extends Object, R>(
  Stream<R> Function(T)? select, {
  T? target,
  R? initialValue,
  bool preserveState = true,
  bool allowStreamChange = false,
  String? instanceName,
  GetIt? getIt,
})
```

**Todos los parámetros:**
- `select` - Función para obtener Stream del objeto registrado (opcional si usas `target`)
- `target` - Stream directo a observar (opcional, no desde `get_it`)
- `initialValue` - Valor mostrado antes del primer evento del stream (hace que `data` nunca sea null)
- `preserveState` - Mantener último valor cuando el stream cambia (predeterminado: `true`)
- `allowStreamChange` - Permitir que la instancia del stream cambie (predeterminado: `false`)
- `instanceName` - Para registros con nombre
- `getIt` - Instancia GetIt personalizada (raramente necesario)

## watchFuture - Futures Reactivos

Reemplaza `FutureBuilder` con `watchFuture()`:

<<< @/../code_samples/lib/watch_it/data_watch_future_example.dart#example

::: tip AsyncSnapshot y Null Safety
Al igual que `watchStream`, cuando proporcionas un **initialValue no-null** a `watchFuture` con un **tipo de future no-nullable** (como `Future<String>`), `AsyncSnapshot.data` no será null. Ver el [tip de AsyncSnapshot arriba](#manejando-estados-de-stream) para detalles.
:::

### Patrón Común: Inicialización de App

<<< @/../code_samples/lib/watch_it/splash_screen_initialization_example.dart#example

::: tip Avanzado: Esperar Múltiples Dependencias
Si necesitas esperar que múltiples servicios async se inicialicen (como database, auth, config), usa `allReady()` en lugar de futures individuales. Ver [Inicialización Async con allReady](/documentation/watch_it/advanced_integration.md#async-initialization-with-isready-and-allready) para más detalles.
:::

### Uso Avanzado de watchFuture

#### Permitir Cambios de Future (allowFutureChange)

Por defecto, `watchFuture` se comporta diferente dependiendo de cómo proporciones el future:

- **Con función `select`:** Llama al selector una vez para prevenir crear múltiples futures en cada reconstrucción
- **Con parámetro `target`:** Lanza error si la instancia del future cambia entre reconstrucciones

Establece `allowFutureChange: true` si esperas que el future cambie legítimamente entre reconstrucciones (como operaciones de reintentar):

<<< @/../code_samples/lib/watch_it/watch_future_allow_change.dart#example

**Qué sucede con `allowFutureChange: true`:**
- La función selectora se llama y evalúa en cada construcción
- Si la instancia del future cambió, `watchFuture` comienza a observar el nuevo future
- El widget se reconstruye cuando el nuevo future se completa
- La completación del future anterior se ignora

**Cuándo usar:**
- Funcionalidad de reintentar para requests fallidas
- El future depende de parámetros reactivos que cambian
- **Importante:** Solo usa cuando el future debería realmente cambiar, no cuando accidentalmente se recrea el mismo future

#### Firma Completa del Método

```dart
AsyncSnapshot<R> watchFuture<T extends Object, R>(
  Future<R> Function(T)? select, {
  T? target,
  required R initialValue,
  bool preserveState = true,
  bool allowFutureChange = false,
  String? instanceName,
  GetIt? getIt,
})
```

**Todos los parámetros:**
- `select` - Función para obtener Future del objeto registrado (opcional si usas `target`)
- `target` - Future directo a observar (opcional, no desde `get_it`)
- `initialValue` - **Requerido**. Valor mostrado antes de que el future se complete (hace que `data` nunca sea null)
- `preserveState` - Mantener último valor cuando el future cambia (predeterminado: `true`)
- `allowFutureChange` - Permitir que la instancia del future cambie (predeterminado: `false`)
- `instanceName` - Para registros con nombre
- `getIt` - Instancia GetIt personalizada (raramente necesario)

## Múltiples Fuentes Async

Observa múltiples streams o futures:

<<< @/../code_samples/lib/watch_it/dashboard_multiple_async_example.dart#example

## Mezclar Sync y Async

Combina datos síncronos y asíncronos:

<<< @/../code_samples/lib/watch_it/user_profile_sync_async_example.dart#example

## Guía Rápida de AsyncSnapshot

Tanto `watchStream()` como `watchFuture()` retornan `AsyncSnapshot<T>`:

<<< @/../code_samples/lib/watch_it/async_patterns.dart#async_snapshot_guide

## Patrones Comunes

### Patrón 1: Carga Simple

<<< @/../code_samples/lib/watch_it/async_patterns.dart#pattern1_simple_loading

### Patrón 2: Manejo de Errores

<<< @/../code_samples/lib/watch_it/async_patterns.dart#pattern2_error_handling

## ¡No Más Builders Anidados!

**Antes:**

<<< @/../code_samples/lib/watch_it/async_patterns.dart#nested_builders_before

**Después:**

<<< @/../code_samples/lib/watch_it/async_patterns.dart#nested_builders_after

¡Código plano y legible!

## Puntos Clave

✅ `watchStream()` reemplaza `StreamBuilder` - sin anidación
✅ `watchFuture()` reemplaza `FutureBuilder` - mismo beneficio
✅ Ambos retornan `AsyncSnapshot<T>` - misma API que conoces
✅ Suscripción y limpieza automáticas
✅ Combina datos sync y async fácilmente

**Siguiente:** Aprende sobre [efectos secundarios con handlers](/documentation/watch_it/handlers.md).

## Ver También

- [Your First Watch Functions](/documentation/watch_it/your_first_watch_functions.md) - Datos sync
- [Side Effects with Handlers](/documentation/watch_it/handlers.md) - Navegación, toasts
- [Watch Functions Reference](/documentation/watch_it/watch_functions.md) - API completa
