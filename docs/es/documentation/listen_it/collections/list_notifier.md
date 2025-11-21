# ListNotifier

Un List reactivo que notifica automáticamente a los listeners cuando su contenido cambia.

## Descripción General

`ListNotifier<T>` es una implementación de List reactivo que:
- Extiende la interfaz estándar de Dart `List<T>`
- Implementa `ValueListenable<List<T>>`
- Notifica automáticamente a los listeners en las mutaciones
- Soporta transacciones para agrupar operaciones
- Proporciona modos de notificación configurables

## Uso Básico

<<< @/../code_samples/lib/listen_it/list_notifier_basic.dart#example

## Creando un ListNotifier

### Lista Vacía

```dart
final items = ListNotifier<String>();
```

### Con Datos Iniciales

```dart
final items = ListNotifier<String>(
  data: ['item1', 'item2', 'item3'],
);
```

### Con Modo de Notificación

```dart
final items = ListNotifier<String>(
  data: ['initial'],
  notificationMode: CustomNotifierMode.normal,
);
```

### Con Igualdad Personalizada

```dart
class Product {
  final String id;
  final String name;

  Product(this.id, this.name);
}

final products = ListNotifier<Product>(
  notificationMode: CustomNotifierMode.normal,
  customEquality: (a, b) => a.id == b.id,  // Comparar solo por ID
);
```

## Operaciones Estándar de List

ListNotifier soporta todas las operaciones estándar de List con notificaciones automáticas:

### Añadiendo Elementos

```dart
final items = ListNotifier<String>();

items.add('item1');              // Añadir un item
items.addAll(['item2', 'item3']); // Añadir múltiples items
items.insert(0, 'first');        // Insertar en índice
items.insertAll(1, ['a', 'b']);  // Insertar múltiples en índice
```

### Eliminando Elementos

```dart
items.remove('item1');           // Eliminar por valor
items.removeAt(0);               // Eliminar por índice
items.removeLast();              // Eliminar último item
items.removeRange(0, 2);         // Eliminar rango
items.removeWhere((item) => item.startsWith('a')); // Eliminar condicionalmente
items.retainWhere((item) => item.length > 3);      // Mantener solo coincidentes
items.clear();                   // Eliminar todos los items
```

### Actualizando Elementos

```dart
items[0] = 'updated';            // Actualizar por índice
items.setAll(0, ['a', 'b']);     // Establecer múltiples empezando en índice
items.setRange(0, 2, ['x', 'y']); // Reemplazar rango
items.fillRange(0, 3, 'same');   // Llenar rango con mismo valor
```

### Reordenando y Ordenando

```dart
items.sort();                    // Ordenar items
items.sort((a, b) => a.compareTo(b)); // Ordenamiento personalizado
items.shuffle();                 // Aleatorizar orden
items.swap(0, 1);                // Intercambiar dos elementos (específico de ListNotifier)
```

### Cambiando Longitud

```dart
items.length = 10;               // Crecer o encoger la lista
```

## Operaciones Especiales de ListNotifier

### swap()

Intercambiar dos elementos por índice - solo notifica si los elementos son diferentes:

```dart
final items = ListNotifier<int>(data: [1, 2, 3]);

items.swap(0, 2);  // ✅ Notifica: [3, 2, 1]

// Con modo normal y elementos iguales
final items2 = ListNotifier<int>(
  data: [1, 1, 1],
  notificationMode: CustomNotifierMode.normal,
);

items2.swap(0, 1);  // ❌️ Sin notificación (elementos son iguales)
```

## Integración con Flutter

### Con ValueListenableBuilder

<<< @/../code_samples/lib/listen_it/list_notifier_widget.dart#example

### Con watch_it

<<< @/../code_samples/lib/listen_it/list_notifier_watch_it.dart#example

## Modos de Notificación

ListNotifier soporta tres modos de notificación:

### always (Predeterminado)

```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.always,
);

items.add('item');   // ✅ Notifica
items[0] = 'item';   // ✅ Notifica (aunque el valor no cambió)
items.remove('xyz'); // ✅ Notifica (aunque no está en la lista)
```

### normal

```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.normal,
);

items.add('item');   // ✅ Notifica
items[0] = 'item';   // ❌️ Sin notificación (valor sin cambios)
items.remove('xyz'); // ❌️ Sin notificación (no está en la lista)
```

### manual

```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.manual,
);

items.add('item1');  // Sin notificación
items.add('item2');  // Sin notificación
items.notifyListeners();  // ✅ Notificación manual
```

[Aprende más sobre modos de notificación →](/documentation/listen_it/collections/notification_modes)

## Transacciones

Agrupa múltiples operaciones en una sola notificación:

<<< @/../code_samples/lib/listen_it/transactions.dart#example

[Aprende más sobre transacciones →](/documentation/listen_it/collections/transactions)

## Valor Inmutable

El getter `.value` devuelve una vista no modificable:

```dart
final items = ListNotifier<String>(data: ['a', 'b', 'c']);

final immutableView = items.value;
print(immutableView);  // [a, b, c]

// ❌️ Lanza UnsupportedError
// immutableView.add('d');

// ✅ Mutar a través del notifier
items.add('d');  // Funciona y notifica
```

Esto asegura que todas las mutaciones pasen por el sistema de notificación.

## Comportamiento de Operaciones Masivas

ListNotifier tiene un comportamiento especial para operaciones masivas:

### Operaciones de Añadir/Insertar

Estas **siempre notifican** (incluso con entrada vacía) en todos los modos excepto manual:

```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.normal,
);

items.addAll([]);       // ✅ Notifica (aunque esté vacío)
items.insertAll(0, []); // ✅ Notifica (aunque esté vacío)
items.setAll(0, []);    // ✅ Notifica (aunque esté vacío)
items.setRange(0, 0, []); // ✅ Notifica (aunque esté vacío)
```

**¿Por qué?** Por razones de rendimiento - para evitar comparar todos los elementos. Estas operaciones se usan típicamente para carga masiva de datos.

### Operaciones de Reemplazo

Estas **solo notifican si ocurrieron cambios** en modo normal:

```dart
final items = ListNotifier<String>(
  data: ['a', 'a', 'a'],
  notificationMode: CustomNotifierMode.normal,
);

items.fillRange(0, 3, 'a');  // ❌️ Sin notificación (valores sin cambios)
items.fillRange(0, 3, 'b');  // ✅ Notifica (valores cambiados)

items.replaceRange(0, 2, ['b', 'b']);  // ❌️ Sin notificación (mismos valores)
items.replaceRange(0, 2, ['c', 'd']);  // ✅ Notifica (valores cambiados)
```

### Operaciones Que Siempre Notifican

Algunas operaciones **siempre activan** el flag hasChanged:

- `shuffle()` - El orden cambia aunque los valores no
- `sort()` - El orden probablemente cambia
- `swap()` - Intercambiando elementos (pero verifica igualdad primero)
- `setAll()`, `setRange()` - Actualizaciones masivas

## Casos de Uso

::: details Lista de Tareas

```dart
class TodoListModel {
  final todos = ListNotifier<Todo>();

  void addTodo(String title) {
    todos.add(Todo(id: generateId(), title: title, completed: false));
  }

  void toggleTodo(String id) {
    final index = todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      final todo = todos[index];
      todos[index] = Todo(id: todo.id, title: todo.title, completed: !todo.completed);
    }
  }

  void removeTodo(String id) {
    todos.removeWhere((t) => t.id == id);
  }

  void reorderTodos(int oldIndex, int newIndex) {
    todos.startTransAction();
    final todo = todos.removeAt(oldIndex);
    todos.insert(newIndex, todo);
    todos.endTransAction();
  }
}
```
:::

::: details Mensajes de Chat

```dart
class ChatModel {
  final messages = ListNotifier<Message>();

  void addMessage(Message message) {
    messages.add(message);
  }

  void loadHistory(List<Message> history) {
    messages.startTransAction();
    messages.clear();
    messages.addAll(history);
    messages.endTransAction();
  }

  void deleteMessage(String messageId) {
    messages.removeWhere((m) => m.id == messageId);
  }
}
```
:::

::: details Resultados de Búsqueda

```dart
class SearchModel {
  final results = ListNotifier<SearchResult>();
  final isSearching = ValueNotifier<bool>(false);

  Future<void> search(String query) async {
    if (query.isEmpty) {
      results.clear();
      return;
    }

    isSearching.value = true;

    try {
      final newResults = await searchApi(query);

      results.startTransAction();
      results.clear();
      results.addAll(newResults);
      results.endTransAction();
    } finally {
      isSearching.value = false;
    }
  }
}
```
:::

::: details Carrito de Compras

```dart
class ShoppingCart {
  final items = ListNotifier<CartItem>(
    notificationMode: CustomNotifierMode.normal,
    customEquality: (a, b) => a.productId == b.productId,
  );

  void addItem(Product product) {
    final existingIndex = items.indexWhere((item) => item.productId == product.id);

    if (existingIndex != -1) {
      // Actualizar cantidad
      final existing = items[existingIndex];
      items[existingIndex] = CartItem(
        productId: existing.productId,
        name: existing.name,
        quantity: existing.quantity + 1,
        price: existing.price,
      );
    } else {
      // Añadir nuevo item
      items.add(CartItem(
        productId: product.id,
        name: product.name,
        quantity: 1,
        price: product.price,
      ));
    }
  }

  void removeItem(String productId) {
    items.removeWhere((item) => item.productId == productId);
  }

  double get total => items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
}
```
:::

## Consideraciones de Rendimiento

### Memoria

ListNotifier tiene sobrecarga mínima comparada con una List regular:
- Extiende `DelegatingList` (de package:collection)
- Añade mecanismo de notificación de `ChangeNotifier`
- Pequeña sobrecarga para modo de notificación y flags de transacción

### Notificaciones

Cada mutación dispara una notificación (a menos que esté en transacción o modo manual):
- **Costo:** O(n) donde n = número de listeners
- **Optimización:** Usa transacciones para operaciones masivas
- **Mejor práctica:** Mantén el conteo de listeners razonable (< 50)

### Listas Grandes

Para listas muy grandes (1000+ items):
- Considera paginación en lugar de cargar todo de una vez
- Usa transacciones al añadir/eliminar muchos items
- Considera modo `normal` si tienes muchas operaciones sin efecto

```dart
// ❌️ Malo: 1000 notificaciones
for (var i = 0; i < 1000; i++) {
  items.add(i);
}

// ✅ Bueno: 1 notificación
items.startTransAction();
for (var i = 0; i < 1000; i++) {
  items.add(i);
}
items.endTransAction();

// ✅ Aún mejor: addAll
items.startTransAction();
items.addAll(List.generate(1000, (i) => i));
items.endTransAction();
```

## Combinando con Operators

Puedes encadenar operators de listen_it en un ListNotifier:

```dart
final todos = ListNotifier<Todo>();

// Reaccionar solo cuando cambia la longitud de la lista
final todoCount = todos.select<int>((list) => list.length);

// Filtrar a tareas incompletas
final incompleteTodos = todos.where((list) => list.any((t) => !t.completed));

// Debounce cambios rápidos
final debouncedTodos = todos.debounce(Duration(milliseconds: 300));

// Usar en widget
ValueListenableBuilder<int>(
  valueListenable: todoCount,
  builder: (context, count, _) => Text('$count todos'),
);
```

[Aprende más sobre operators →](/documentation/listen_it/operators/overview)

## Referencia de API

### Constructor

```dart
ListNotifier({
  List<T>? data,
  CustomNotifierMode notificationMode = CustomNotifierMode.always,
  bool Function(T, T)? customEquality,
})
```

### Propiedades

| Propiedad | Tipo | Descripción |
|----------|------|-------------|
| `value` | `List<T>` | Vista no modificable de la lista actual |
| `length` | `int` | Número de elementos (setter dispara notificación) |
| `first` | `T` | Primer elemento |
| `last` | `T` | Último elemento |
| `isEmpty` | `bool` | Si la lista está vacía |
| `isNotEmpty` | `bool` | Si la lista tiene elementos |

### Métodos

Todos los métodos estándar de `List<T>` más:

| Método | Descripción |
|--------|-------------|
| `swap(int index1, int index2)` | Intercambiar dos elementos |
| `startTransAction()` | Comenzar transacción |
| `endTransAction()` | Terminar transacción y notificar |
| `notifyListeners()` | Notificar manualmente (útil con modo manual) |

## Errores Comunes

### 1. Modificar la Vista .value

```dart
// ❌️ No intentes modificar el getter .value
final view = items.value;
view.add('item');  // ¡Lanza UnsupportedError!

// ✅ Modificar a través del notifier
items.add('item');
```

### 2. Olvidar Transacciones

```dart
// ❌️ Muchas notificaciones
for (final item in newItems) {
  items.add(item);
}

// ✅ Una sola notificación
items.startTransAction();
for (final item in newItems) {
  items.add(item);
}
items.endTransAction();
```

### 3. Transacciones Anidadas

```dart
// ❌️ Lanzará error de aserción
items.startTransAction();
items.add('a');
items.startTransAction();  // ¡ERROR!

// ✅ Terminar primera transacción antes de iniciar otra
items.startTransAction();
items.add('a');
items.endTransAction();

items.startTransAction();
items.add('b');
items.endTransAction();
```

## Próximos Pasos

- [MapNotifier →](/documentation/listen_it/collections/map_notifier)
- [SetNotifier →](/documentation/listen_it/collections/set_notifier)
- [Modos de Notificación →](/documentation/listen_it/collections/notification_modes)
- [Transacciones →](/documentation/listen_it/collections/transactions)
- [Volver a Colecciones →](/documentation/listen_it/collections/introduction)
