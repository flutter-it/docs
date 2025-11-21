# Operators Basados en Tiempo

Los operators basados en tiempo controlan cuándo se propagan los valores, ayudándote a manejar cambios rápidos y operaciones sensibles al tiempo.

## debounce()

Retrasa la propagación de valores hasta que ocurre una pausa. Perfecto para manejar entrada rápida del usuario como campos de búsqueda.

::: tip Disponible en Ambos Tipos
`debounce()` funciona tanto en `ValueListenable<T>` (devuelve valores con debounce) como en `Listenable` regular (solo aplica debounce a las notificaciones sin valores).
:::

### Uso Básico (ValueListenable)

<<< @/../code_samples/lib/listen_it/debounce_search.dart#example

### Cómo Funciona

`debounce()` crea un temporizador que se reinicia en cada cambio de valor. El valor solo se propaga cuando el temporizador se completa sin ser reiniciado:

```dart
final input = ValueNotifier<String>('');

final debounced = input.debounce(Duration(milliseconds: 500));

debounced.listen((value, _) => print('Debounced: $value'));

input.value = 'a';  // Temporizador inicia
input.value = 'ab'; // Temporizador se reinicia
input.value = 'abc'; // Temporizador se reinicia
// ... pausa de 500ms ...
// Imprime: "Debounced: abc" (solo después de la pausa)
```

### Casos de Uso Comunes

::: details Entrada de Búsqueda

El caso de uso más común - evitar llamadas API excesivas mientras se escribe:

```dart
final searchTerm = ValueNotifier<String>('');

searchTerm
    .debounce(const Duration(milliseconds: 300))
    .where((term) => term.length >= 3)
    .listen((term, _) => performSearch(term));
```
:::

::: details Autoguardado

Guardar la entrada del usuario después de que deja de escribir:

```dart
final documentContent = ValueNotifier<String>('');

documentContent
    .debounce(const Duration(seconds: 2))
    .listen((content, _) => autoSave(content));
```
:::

::: details Validación de Formularios

Validar entrada después de que el usuario deja de escribir:

```dart
final emailInput = ValueNotifier<String>('');

emailInput
    .debounce(const Duration(milliseconds: 500))
    .listen((email, _) => validateEmail(email));
```
:::

::: details Manejo de Redimensionamiento

Manejar eventos de redimensionamiento de ventana sin sobrecargar el sistema:

```dart
final windowSize = ValueNotifier<Size>(Size.zero);

windowSize
    .debounce(const Duration(milliseconds: 200))
    .listen((size, _) => recalculateLayout(size));
```
:::

### Eligiendo la Duración Correcta

| Duración | Caso de Uso |
|----------|----------|
| **100-200ms** | Feedback rápido (ej., vista previa en vivo, búsqueda instantánea) |
| **300-500ms** | Entrada de usuario estándar (ej., búsqueda, validación) |
| **1-2s** | Autoguardado, operaciones en segundo plano |
| **3-5s** | Operaciones pesadas, llamadas de red |

### Beneficios de Rendimiento

Sin debounce:
```dart
// Usuario escribe "flutter" (7 teclas)
// Sin debounce: ¡7 llamadas API!
searchInput.listen((term, _) => searchApi(term));

// Llamadas: 'f', 'fl', 'flu', 'flut', 'flutt', 'flutte', 'flutter'
```

Con debounce:
```dart
// Usuario escribe "flutter" (7 teclas)
// Con debounce: ¡1 llamada API!
searchInput
    .debounce(Duration(milliseconds: 300))
    .listen((term, _) => searchApi(term));

// Solo llama una vez con: 'flutter'
```

### Usando con Listenable Regular

Para `Listenable` regular (no `ValueListenable`), `debounce()` retrasa las notificaciones sin rastrear valores:

```dart
final notifier = ChangeNotifier();

final debounced = notifier.debounce(Duration(milliseconds: 500));

debounced.listen((_) {
  print('¡Notificación con debounce!');
});

// Notificaciones rápidas
notifier.notifyListeners();
notifier.notifyListeners();
notifier.notifyListeners();

// Solo una notificación después de pausa de 500ms
```

Esto es útil cuando tienes un `ChangeNotifier` o `Listenable` personalizado y quieres reducir la frecuencia de notificaciones sin necesidad de rastrear valores específicos.

### Encadenando con Otros Operators

Debounce funciona muy bien en cadenas de operators:

```dart
final searchInput = ValueNotifier<String>('');

searchInput
    .debounce(Duration(milliseconds: 300))  // Esperar pausa de escritura
    .where((term) => term.length >= 3)       // Longitud mínima
    .map((term) => term.trim())              // Limpiar
    .listen((term, _) => performSearch(term));
```

### Advertencias

::: warning setState y debounce
Usar `debounce()` dentro del método build de un widget con `setState` puede causar problemas porque el debounce crea un nuevo objeto de cadena en cada reconstrucción, perdiendo el estado del temporizador.

**❌️ NO HAGAS:**
```dart
Widget build(BuildContext context) {
  return ValueListenableBuilder(
    valueListenable: input.debounce(Duration(milliseconds: 300)), // ¡NUEVO DEBOUNCE EN CADA BUILD!
    builder: (context, value, _) => Text(value),
  );
}
```

**✅ MEJOR: Crear cadena fuera de build**
```dart
// Crear cadena con debounce como campo
late final debounced = input.debounce(Duration(milliseconds: 300));

Widget build(BuildContext context) {
  return ValueListenableBuilder(
    valueListenable: debounced, // Mismo debounce en cada build
    builder: (context, value, _) => Text(value),
  );
}
```

**✅ MEJOR AÚN: Usar watch_it con `get_it`**
```dart
class SearchWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // watch_it cachea la cadena automáticamente cuando usa watchValue
    final debouncedTerm = watchValue(
      (SearchModel m) => m.searchTerm
          .debounce(Duration(milliseconds: 300))
          .where((term) => term.length >= 3)
    );

    return Text('Search: $debouncedTerm');
  }
}

// Registrar SearchModel en get_it
class SearchModel {
  final searchTerm = ValueNotifier<String>('');
}
```
:::

### Cuándo Usar debounce()

Usa `debounce()` cuando:
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Tengas cambios de valor rápidos (usuario escribiendo, scrolling, redimensionando)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Quieras reducir llamadas API u operaciones costosas</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Solo te importe el valor "final" después de que los cambios se detienen</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Estés implementando búsqueda, autoguardado, o validación</li>
</ul>

## async()

Difiere las actualizaciones al siguiente frame, previniendo errores de "setState called during build".

### Uso Básico

```dart
final source = ValueNotifier<int>(0);

final asyncSource = source.async();

// Las actualizaciones se difieren al siguiente frame
asyncSource.listen((value, _) => setState(() => _data = value));
```

### Cómo Funciona

`async()` usa `scheduleMicrotask()` para diferir la notificación hasta después de que el frame actual se completa. Esto previene problemas al establecer estado durante construcciones de widgets.

### Cuándo Usar async()

Usa `async()` cuando:
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Necesites llamar a `setState()` desde un listener</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Estés obteniendo errores de "setState called during build"</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Quieras agrupar múltiples cambios síncronos</li>
</ul>

::: tip
En la mayoría de los casos, usar watch_it es una mejor solución que `async()`. watch_it maneja las actualizaciones de estado automáticamente sin requerir diferimiento async.
:::

## Ejemplo del Mundo Real

Implementación completa de búsqueda con debounce:

```dart
class SearchViewModel {
  final searchTerm = ValueNotifier<String>('');
  final results = ListNotifier<SearchResult>();
  final isSearching = ValueNotifier<bool>(false);

  SearchViewModel() {
    searchTerm
        .debounce(Duration(milliseconds: 300))
        .where((term) => term.length >= 3)
        .listen((term, _) => _performSearch(term));
  }

  Future<void> _performSearch(String term) async {
    isSearching.value = true;
    try {
      final apiResults = await searchApi(term);
      results.startTransAction();
      results.clear();
      results.addAll(apiResults);
      results.endTransAction();
    } finally {
      isSearching.value = false;
    }
  }
}
```

## Próximos Pasos

- [Aprende sobre operators de transformación →](/documentation/listen_it/operators/transform)
- [Aprende sobre operators de filtrado →](/documentation/listen_it/operators/filter)
- [Aprende sobre operators de combinación →](/documentation/listen_it/operators/combine)
- [Lee la guía de mejores prácticas →](/documentation/listen_it/best_practices)
