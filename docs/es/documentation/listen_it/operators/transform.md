# Operators de Transformación

Los operators de transformación te permiten convertir valores de un tipo a otro o reaccionar solo a cambios específicos de propiedades.

## map()

Transforma cada valor usando una función. El ValueListenable mapeado se actualiza cada vez que la fuente cambia.

### Uso Básico

<<< @/../code_samples/lib/listen_it/map_transform.dart#example

### Transformación de Tipo

Puedes cambiar el tipo proporcionando un parámetro de tipo:

```dart
final intNotifier = ValueNotifier<int>(42);

// Transformación de tipo explícita
final stringNotifier = intNotifier.map<String>((i) => 'Value: $i');

// El tipo se infiere como ValueListenable<String>
print(stringNotifier.value); // "Value: 42"
```

### Casos de Uso Comunes

::: details Formatear Valores para Mostrar

```dart
import 'package:intl/intl.dart';

final priceNotifier = ValueNotifier<double>(19.99);

final formatter = NumberFormat.currency(symbol: '\$');
final formattedPrice = priceNotifier.map((price) => formatter.format(price));

ValueListenableBuilder<String>(
  valueListenable: formattedPrice,
  builder: (context, price, _) => Text(price), // "$19.99"
);
```
:::

::: details Extraer Propiedades Anidadas

```dart
final userNotifier = ValueNotifier<User>(user);

final userName = userNotifier.map((user) => user.name);
final userEmail = userNotifier.map((user) => user.email);
```
:::

::: details Transformaciones Complejas

```dart
final dataNotifier = ValueNotifier<RawData>(data);

final processed = dataNotifier.map((raw) {
  return ProcessedData(
    value: raw.value * 2,
    formatted: raw.toString().toUpperCase(),
    timestamp: DateTime.now(),
  );
});
```
:::

### Cuándo Usar map()

Usa `map()` cuando:
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Necesites transformar cada valor</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Necesites cambiar el tipo</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ La transformación siempre sea válida</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Quieras ser notificado en cada cambio de la fuente</li>
</ul>

::: tip Rendimiento
La función de transformación se llama en **cada** cambio de valor de la fuente. Para transformaciones costosas, considera usar `select()` si solo necesitas reaccionar a cambios de propiedades específicas.
:::

## select()

Reacciona solo cuando una propiedad seleccionada del valor cambia. Esto es más eficiente que `map()` cuando solo te importan propiedades específicas de un objeto complejo.

### Uso Básico

<<< @/../code_samples/lib/listen_it/select_property.dart#example

### Cómo Funciona

La función de selector se llama en cada cambio de valor, pero el resultado solo se propaga cuando es **diferente** del resultado anterior (usando comparación `==`).

```dart
final userNotifier = ValueNotifier<User>(User(age: 18, name: "John"));

final ageNotifier = userNotifier.select<int>((u) => u.age);

ageNotifier.listen((age, _) => print('Age: $age'));

userNotifier.value = User(age: 18, name: "Johnny");
// Sin salida - la edad no cambió

userNotifier.value = User(age: 19, name: "Johnny");
// Imprime: Age: 19
```

### Casos de Uso Comunes

::: details Rastrear Propiedades Específicas del Modelo

```dart
class AppState {
  final bool isLoading;
  final String? error;
  final List<Item> items;

  AppState({required this.isLoading, this.error, required this.items});
}

final appState = ValueNotifier<AppState>(initialState);

// Solo reconstruir cuando cambia el estado de carga
final isLoading = appState.select<bool>((state) => state.isLoading);

// Solo reconstruir cuando cambia el error
final error = appState.select<String?>((state) => state.error);

// Solo reconstruir cuando cambia el conteo de items
final itemCount = appState.select<int>((state) => state.items.length);
```
:::

::: details Evitar Reconstrucciones Innecesarias

```dart
class Settings {
  final String theme;
  final String language;
  final bool notifications;

  Settings({required this.theme, required this.language, required this.notifications});
}

final settings = ValueNotifier<Settings>(defaultSettings);

// El widget solo se reconstruye cuando cambia el tema, no cuando cambian language o notifications
final theme = settings.select<String>((s) => s.theme);

ValueListenableBuilder<String>(
  valueListenable: theme,
  builder: (context, theme, _) => ThemedWidget(theme: theme),
);
```
:::

::: details Seleccionar Propiedades Computadas

```dart
class ShoppingCart {
  final List<Item> items;

  ShoppingCart(this.items);

  double get total => items.fold(0.0, (sum, item) => sum + item.price);
}

class Item {
  final double price;
  Item(this.price);
}

final cart = ValueNotifier<ShoppingCart>(ShoppingCart([]));

// Solo notificar cuando cambia el total
final total = cart.select<double>((c) => c.total);
```
:::

### map() vs select()

| Característica | map() | select() |
|---------|-------|----------|
| **Notifica cuando** | La fuente cambia | El valor seleccionado cambia |
| **Usar para** | Transformar siempre todos los cambios | Reaccionar solo a propiedades específicas |
| **Rendimiento** | Cada cambio de fuente | Solo cuando el valor seleccionado difiere |
| **Cambio de tipo** | Sí | Sí |

```dart
final user = ValueNotifier<User>(User(age: 18, name: "John"));

// map() - notifica en CADA cambio de usuario
final userMap = user.map((u) => u.age);
user.value = User(age: 18, name: "Johnny"); // ✅ Notifica (edad todavía 18)

// select() - notifica solo cuando la edad REALMENTE cambia
final userSelect = user.select<int>((u) => u.age);
user.value = User(age: 18, name: "Johnny"); // ❌️ Sin notificación (edad sin cambios)
```

### Cuándo Usar select()

Usa `select()` cuando:
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Solo te importan propiedades específicas de un objeto complejo</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Quieras evitar notificaciones innecesarias</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ El objeto cambia frecuentemente pero la propiedad que te importa no</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Quieras optimizar las reconstrucciones de widgets</li>
</ul>

::: tip Mejor Práctica
`select()` es ideal para view models u objetos de estado que tienen muchas propiedades pero tu widget solo depende de algunas de ellas.
:::

## Encadenando Transformaciones

Puedes encadenar `map()` y `select()` con otros operators:

```dart
final user = ValueNotifier<User>(user);

user
    .select<int>((u) => u.age)           // Solo cuando la edad cambia
    .where((age) => age >= 18)            // Solo adultos
    .map<String>((age) => 'Age: $age')    // Formatear para mostrar
    .listen((text, _) => print(text));
```

## Próximos Pasos

- [Aprende sobre operators de filtrado →](/documentation/listen_it/operators/filter)
- [Aprende sobre operators de combinación →](/documentation/listen_it/operators/combine)
- [Aprende sobre operators basados en tiempo →](/documentation/listen_it/operators/time)
