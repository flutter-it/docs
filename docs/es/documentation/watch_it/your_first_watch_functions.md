# Tus Primeras Funciones Watch

Las funciones watch son el núcleo de `watch_it` - hacen que tus widgets se reconstruyan automáticamente cuando los datos cambian. Empecemos con la más común.

## El Watch Más Simple: watchValue

La forma más común de observar datos es con `watchValue()`. Observa una propiedad `ValueListenable` de un objeto registrado en `get_it`.

### Ejemplo Básico de Contador

<<< @/../code_samples/lib/watch_it/counter_simple_example.dart#example

**Qué sucede:**
- `watchValue()` accede a `CounterManager` desde `get_it`
- Observa la propiedad `count`
- El widget se reconstruye automáticamente cuando count cambia
- Sin listeners manuales, sin limpieza necesaria

::: tip Magia de Inferencia de Tipos
Observa cómo especificamos el tipo del objeto padre en la función selectora:

`(CounterManager m) => m.count`

Al declarar el tipo del objeto padre `CounterManager`, Dart automáticamente **infiere** ambos parámetros de tipo genérico:

```dart
//  Recomendado - Dart infiere los tipos automáticamente
final count = watchValue((CounterManager m) => m.count);
```

**Firma del método:**
```dart
R watchValue<T extends Object, R>(
  ValueListenable<R> Function(T) selectProperty, {
  bool allowObservableChange = false,
  String? instanceName,
  GetIt? getIt,
})
```

Dart infiere:
- `T = CounterManager` (del tipo del objeto padre)
- `R = int` (de `m.count` que es `ValueListenable<int>`)

**Sin la anotación de tipo**, necesitarías especificar ambos genéricos manualmente:

```dart
// ❌️ Más verboso - parámetros de tipo manuales requeridos
final count = watchValue<CounterManager, int>((m) => m.count);
```

**Conclusión:** ¡Siempre especifica el tipo del objeto padre en tu función selectora para código más limpio y legible!
:::

## Observando Múltiples Objetos

¿Necesitas observar datos de diferentes managers? Solo añade más llamadas watch:

<<< @/../code_samples/lib/watch_it/multiple_objects_example.dart#example

Cuando CUALQUIERA de ellos cambia, el widget se reconstruye. ¡Eso es todo!

**Compara con ValueListenableBuilder:**

<<< @/../code_samples/lib/watch_it/multiple_objects_example.dart#builders

¡Tres niveles de anidación! Con `watch_it`, son solo tres líneas simples.

## Ejemplo Real: Lista de Tareas

<<< @/../code_samples/lib/watch_it/todo_manager_example.dart#example

¿Añadir una tarea? El widget se reconstruye automáticamente. Sin `setState`, sin `StreamBuilder`.

## Patrón Común: Estados de Carga

<<< @/../code_samples/lib/watch_it/data_widget_loading_example.dart#example

## Pruébalo Tú Mismo

1. Crea un `ValueNotifier` en tu manager:

   <<< @/../code_samples/lib/watch_it/try_it_yourself_example.dart#manager

2. Regístralo:

   <<< @/../code_samples/lib/watch_it/try_it_yourself_example.dart#register

3. Obsérvalo:

   <<< @/../code_samples/lib/watch_it/try_it_yourself_example.dart#watch

4. Cámbialo y observa la magia:

   <<< @/../code_samples/lib/watch_it/try_it_yourself_example.dart#change

## Puntos Clave

✅ `watchValue()` es tu función principal
✅ Una línea reemplaza listeners manuales y `setState`
✅ Funciona con cualquier `ValueListenable<T>`
✅ Suscripción y limpieza automáticas
✅ Múltiples llamadas watch = múltiples suscripciones

**Siguiente:** Aprende sobre [más funciones watch](/documentation/watch_it/more_watch_functions.md) para diferentes casos de uso.

## Ver También

- [WatchingWidgets](/documentation/watch_it/watching_widgets.md) - Qué tipo de widget usar (WatchingWidget, mixins, StatefulWidget)
- [More Watch Functions](/documentation/watch_it/more_watch_functions.md) - watchIt, watchPropertyValue, y más
- [Watching Multiple Values](/documentation/watch_it/watching_multiple_values.md) - Patrones avanzados para combinar valores
- [Watch Functions Reference](/documentation/watch_it/watch_functions.md) - Referencia completa de la API
