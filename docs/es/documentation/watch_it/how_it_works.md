# ¿Cómo Funciona?

## Levantando la cortina de magia

*No es necesario entender este capítulo para usar `watch_it` exitosamente.*

Podrías preguntarte cómo es posible observar múltiples objetos sin pasar identificadores a las funciones `watch*()`. El mecanismo puede sentirse como un hack inteligente, pero es el mismo patrón usado por `flutter_hooks` y React Hooks, y la API limpia que proporciona vale la pena.

## El Concepto

Cuando usas `WatchingWidget`, `WatchingStatefulWidget`, o los mixins, añades un handler al mecanismo de build de Flutter.

**Antes de que se llame a la función `build()`**, un objeto `_WatchItState` se asigna a una variable global `_activeWatchItState`. Este objeto contiene:
- Una referencia al Element del widget (para disparar reconstrucciones)
- Una lista de entradas watch

A través de esta variable global, las funciones `watch*()` pueden acceder al Element y sus datos almacenados.

**En la primera construcción**: Cada llamada `watch*()` crea una nueva entrada watch en la lista e incrementa un contador.

**En reconstrucciones**: El contador se restablece a cero, y con cada llamada `watch*()` se incrementa nuevamente para acceder a los datos almacenados durante la construcción anterior.

**Después de que la construcción se completa**: La variable global se restablece a `null`. Es por esto que llamar a `watch*()` fuera de build lanza un error.

**Al disponerse el widget**: Todas las entradas watch se disponen, limpiando todos los listeners y suscripciones automáticamente.

## Por Qué Importa el Orden

Ahora está claro por qué las funciones `watch*()` deben siempre ser llamadas en el **mismo orden**:

Cada llamada `watch*()` recupera sus datos por posición de índice en la lista. Si el orden cambia entre construcciones, se recuperan los datos incorrectos, causando errores de tipo.

```dart
// Primera construcción
final todos = watchValue(...);  // índice 0
final user = watchValue(...);   // índice 1

// Reconstrucción con orden diferente - ¡INCORRECTO!
if (condition) {
  final user = watchValue(...);  // índice 0 - ¡espera datos de todos!
}
final todos = watchValue(...);   // índice 1 - ¡espera datos de user!
```

No se permiten condicionales que cambiarían el orden, porque la relación entre la llamada `watch*()` y su entrada almacenada se rompería.

Para reglas detalladas y patrones seguros, ver [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md).

## Mismo Patrón que Hooks

Si esto suena familiar, es porque el mismo mecanismo exacto es usado por `flutter_hooks` y React Hooks. Es un patrón probado que cambia un requisito estricto de ordenamiento por una API limpia e intuitiva - pero con una API más intuitiva que `flutter_hooks` a través de integración profunda con `get_it`.

## Lectura Adicional

- [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) - Restricciones de ordenamiento CRÍTICAS
- [Debugging & Tracing](/documentation/watch_it/debugging_tracing.md) - Herramientas para encontrar violaciones de ordenamiento
- [Best Practices](/documentation/watch_it/best_practices.md) - Patrones para uso efectivo
