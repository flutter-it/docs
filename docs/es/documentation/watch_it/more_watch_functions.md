# Más Funciones Watch

Ya aprendiste [`watchValue()`](/documentation/watch_it/your_first_watch_functions.md) para observar propiedades `ValueListenable`. Ahora exploremos las otras funciones watch.

## watchIt - Observar Objeto Completo en `get_it`

Cuando tu objeto registrado ES un `Listenable`, usa `watchIt()`:

<<< @/../code_samples/lib/watch_it/watch_it_change_notifier_example.dart#example

**Cuándo usar `watchIt()`:**
- Tu objeto extiende `ChangeNotifier` o `ValueNotifier`
- Necesitas llamar métodos en el objeto
- El objeto completo notifica cambios

## watch - Observar Cualquier Listenable

`watch()` es el más flexible - observa CUALQUIER `Listenable`:

<<< @/../code_samples/lib/watch_it/watch_local_listenable_example.dart#example

**Cuándo usar `watch()`:**
- Observar objetos `Listenable` locales
- Ya tienes una referencia al `Listenable`
- Caso más genérico

::: tip watch() es la Base
`watch()` es la función más flexible - podrías usarla para reemplazar `watchIt()` y `watchValue()`:

```dart
// Estos son equivalentes:
final manager = watchIt<CounterManager>();
final manager = watch(di<CounterManager>());

// Estos son equivalentes:
final count = watchValue((CounterManager m) => m.count);
final count = watch(di<CounterManager>().count).value;
```

**¿Por qué usar las funciones de conveniencia?**
- `watchIt()` es más limpio para obtener el objeto completo de `get_it`
- `watchValue()` proporciona mejor inferencia de tipos y sintaxis más limpia
- Cada una está optimizada para su caso de uso específico
:::

### Usar watch() Solo para Disparar Reconstrucciones

A veces no necesitas el valor de retorno - solo quieres disparar una reconstrucción cuando un Listenable cambia:

<<< @/../code_samples/lib/watch_it/watch_trigger_rebuild_example.dart#example

**Puntos clave:**
- `watch(controller)` dispara reconstrucción cuando el controller notifica
- No usamos el valor de retorno - solo llamamos `watch()` por el efecto secundario
- El widget se reconstruye, así que `controller.text.length` siempre está actualizado
- El estado de habilitación/deshabilitación del botón se actualiza automáticamente

## watchPropertyValue - Actualizaciones Selectivas

Solo se reconstruye cuando una propiedad específica de un objeto padre Listenable cambia:

**Firma del método:**
```dart
R watchPropertyValue<T extends Listenable, R>(
  R Function(T) selector,
  {String? instanceName, GetIt? getIt}
)
```

<<< @/../code_samples/lib/watch_it/watch_property_value_selective_example.dart#example

**La diferencia:**

<<< @/../code_samples/lib/watch_it/watch_comparison_snippets.dart#property_value_difference

## Comparación Rápida

<<< @/../code_samples/lib/watch_it/watch_comparison_snippets.dart#quick_comparison

## Elegir la Función Correcta

**Si tienes solo una o dos propiedades que deberían disparar una actualización:**

Usa `ValueNotifier` para cada propiedad y `watchValue()`:

<<< @/../code_samples/lib/watch_it/watch_comparison_snippets.dart#watchValue_usage

**Si el objeto completo puede ser actualizado o muchas propiedades pueden cambiar:**

Usa `ChangeNotifier` y `watchIt()`:

<<< @/../code_samples/lib/watch_it/watch_comparison_snippets.dart#watchIt_usage

O si el rendimiento es importante, usa `watchPropertyValue()` para actualizaciones selectivas:

<<< @/../code_samples/lib/watch_it/watch_comparison_snippets.dart#watchPropertyValue_usage

**Para Listenables locales no registrados en `get_it`:**

Usa `watch()`:

<<< @/../code_samples/lib/watch_it/watch_comparison_snippets.dart#watch_usage

## Ejemplo Práctico

Mezclando diferentes funciones watch:

<<< @/../code_samples/lib/watch_it/dashboard_mixed_watch_example.dart#example

## Puntos Clave

✅ `watchValue()` - Observa propiedades `ValueListenable` desde `get_it` (una o dos propiedades)
✅ `watchIt()` - Observa objetos `Listenable` completos desde `get_it` (muchas propiedades cambian)
✅ `watchPropertyValue()` - Actualizaciones selectivas desde `Listenable` en `get_it` (optimización de rendimiento)
✅ `watch()` - Más flexible, cualquier `Listenable` (local o parámetro)
✅ Elige basándote en el número de propiedades y patrones de actualización
✅ Mezcla y combina según tus necesidades

**Siguiente:** Aprende sobre [observar múltiples valores](/documentation/watch_it/watching_multiple_values.md).

## Ver También

- [Your First Watch Functions](/documentation/watch_it/your_first_watch_functions.md) - Empieza aquí
- [Watching Multiple Values](/documentation/watch_it/watching_multiple_values.md) - Estrategias para combinar valores
- [Watching Streams & Futures](/documentation/watch_it/watching_streams_and_futures.md) - Streams y Futures
- [Watch Functions Reference](/documentation/watch_it/watch_functions.md) - API completa
