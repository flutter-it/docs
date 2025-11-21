# Introducción a Colecciones

Las colecciones reactivas notifican automáticamente a los listeners cuando su contenido cambia, facilitando la construcción de UIs reactivas sin llamadas manuales a `notifyListeners()`.

## ¿Qué Son las Colecciones Reactivas?

listen_it proporciona tres tipos de colecciones reactivas que implementan `ValueListenable`:

- **[ListNotifier\<T\>](/documentation/listen_it/collections/list_notifier)** - List reactivo con notificaciones automáticas
- **[MapNotifier\<K,V\>](/documentation/listen_it/collections/map_notifier)** - Map reactivo con notificaciones automáticas
- **[SetNotifier\<T\>](/documentation/listen_it/collections/set_notifier)** - Set reactivo con notificaciones automáticas

Cada tipo de colección extiende la interfaz estándar de colección de Dart (List, Map, Set) y añade capacidades reactivas.

## Ejemplo Rápido

<<< @/../code_samples/lib/listen_it/list_notifier_basic.dart#example

## Características Clave

### 1. Notificaciones Automáticas

Cada operación de mutación notifica automáticamente a los listeners:

```dart
final items = ListNotifier<String>();

items.listen((list, _) => print('List changed: $list'));

items.add('item1');        // ✅ Notifica
items.addAll(['a', 'b']);  // ✅ Notifica
items[0] = 'updated';      // ✅ Notifica
items.removeAt(0);         // ✅ Notifica
```

### 2. Modos de Notificación

Controla cuándo se disparan las notificaciones con tres modos:

- **always** (predeterminado) - Notifica en cada operación, incluso si el valor no cambia
- **normal** - Solo notifica cuando el valor realmente cambia (usando `==` o igualdad personalizada)
- **manual** - Sin notificaciones automáticas, llama a `notifyListeners()` manualmente

[Aprende por qué el predeterminado notifica siempre →](/documentation/listen_it/collections/notification_modes)

### 3. Transacciones

Agrupa múltiples operaciones en una sola notificación:

```dart
final items = ListNotifier<int>();

items.startTransAction();
items.add(1);
items.add(2);
items.add(3);
items.endTransAction();  // Una sola notificación para las 3 adiciones
```

[Aprende más sobre transacciones →](/documentation/listen_it/collections/transactions)

### 4. Valores Inmutables

El getter `.value` devuelve una vista no modificable:

```dart
final items = ListNotifier<String>(data: ['a', 'b']);

final immutableView = items.value;  // UnmodifiableListView
// immutableView.add('c');  // ❌️ Lanza UnsupportedError
```

Esto asegura que todas las mutaciones pasen por el sistema de notificación.

### 5. Interfaz ValueListenable

Todas las colecciones implementan `ValueListenable`, por lo que funcionan con:

- `ValueListenableBuilder` - Widget reactivo estándar de Flutter
- `watch_it` - Para código reactivo más limpio
- Cualquier otra solución de gestión de estado que observe Listenables
- Todos los [operators](/documentation/listen_it/operators/overview) de listen_it - Encadena transformaciones en colecciones

## Casos de Uso

### ListNotifier - Colecciones Ordenadas

Usa cuando el orden importa y se permiten duplicados:

- Listas de tareas
- Historial de mensajes de chat
- Resultados de búsqueda
- Feeds de actividad
- Items vistos recientemente

### MapNotifier - Almacenamiento Clave-Valor

Usa cuando necesitas búsquedas rápidas por clave:

- Preferencias de usuario
- Datos de formularios
- Cachés
- Configuraciones
- Mapeos de ID a objeto

```dart
final preferences = MapNotifier<String, dynamic>(
  data: {'theme': 'dark', 'fontSize': 14},
);

preferences.listen((map, _) => savePreferences(map));

preferences['theme'] = 'light';  // ✅ Notifica
```

### SetNotifier - Colecciones Únicas

Usa cuando necesitas items únicos y pruebas de membresía rápidas:

- IDs de items seleccionados
- Filtros activos
- Etiquetas
- Categorías únicas
- Permisos de usuario

```dart
final selectedIds = SetNotifier<String>(data: {});

selectedIds.listen((set, _) => print('Selection changed: $set'));

selectedIds.add('item1');  // ✅ Notifica
selectedIds.add('item1');  // No se añade duplicado (comportamiento de Set)
```

## Integración con Flutter

### Con ValueListenableBuilder

Enfoque estándar de Flutter:

<<< @/../code_samples/lib/listen_it/list_notifier_widget.dart#example

### Con [watch_it](/documentation/watch_it/getting_started) (¡Recomendado!)

Más limpio y conciso:

<<< @/../code_samples/lib/listen_it/list_notifier_watch_it.dart#example

## Eligiendo la Colección Correcta

| Colección | Cuándo Usar | Ejemplo |
|------------|-------------|---------|
| **ListNotifier\<T\>** | El orden importa, duplicados permitidos | Listas de tareas, historial de mensajes |
| **MapNotifier\<K,V\>** | Necesitas búsquedas clave-valor | Configuraciones, cachés, datos de formulario |
| **SetNotifier\<T\>** | Items únicos, pruebas de membresía rápidas | IDs seleccionados, filtros, etiquetas |

## Patrones Comunes

### Inicializar con Datos

Todas las colecciones aceptan datos iniciales:

```dart
final items = ListNotifier<String>(data: ['a', 'b', 'c']);
final prefs = MapNotifier<String, int>(data: {'count': 42});
final tags = SetNotifier<String>(data: {'flutter', 'dart'});
```

### Escuchar Cambios

Usa `.listen()` para efectos secundarios fuera del árbol de widgets:

```dart
final cart = ListNotifier<Product>();

cart.listen((products, _) {
  final total = products.fold(0.0, (sum, p) => sum + p.price);
  print('Cart total: \$$total');
});
```

### Agrupar Operaciones con Transacciones

Mejora el rendimiento agrupando actualizaciones:

<<< @/../code_samples/lib/listen_it/transactions.dart#example

### Elegir Modo de Notificación

El predeterminado es `always` porque los usuarios esperan que la UI se reconstruya en cada operación. Usar el modo `normal` podría sorprender a los usuarios si la UI no se actualiza cuando realizan una operación (como añadir un item que ya existe), pero puedes optimizar con `normal` cuando entiendes las compensaciones:

```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.normal,
);

items.add('item1');  // ✅ Notifica
items.add('item1');  // ❌️ Sin notificación (duplicado en set/map, o sin cambio)
```

## ¿Por Qué Colecciones Reactivas?

### Sin Colecciones Reactivas

```dart
class TodoList extends ValueNotifier<List<Todo>> {
  TodoList() : super([]);

  void addTodo(Todo todo) {
    value.add(todo);
    notifyListeners();  // Notificación manual
  }

  void removeTodo(int index) {
    value.removeAt(index);
    notifyListeners();  // Notificación manual
  }

  void updateTodo(int index, Todo todo) {
    value[index] = todo;
    notifyListeners();  // Notificación manual
  }
}
```

### Con ListNotifier

```dart
final todos = ListNotifier<Todo>();

todos.add(todo);           // ✅ Notificación automática
todos.removeAt(index);     // ✅ Notificación automática
todos[index] = updatedTodo; // ✅ Notificación automática
```

**Beneficios:**
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Menos código repetitivo</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ APIs estándar de List/Map/Set</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Notificaciones automáticas</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Soporte de transacciones para agrupación</li>
</ul>

## Próximos Pasos

- [ListNotifier →](/documentation/listen_it/collections/list_notifier)
- [MapNotifier →](/documentation/listen_it/collections/map_notifier)
- [SetNotifier →](/documentation/listen_it/collections/set_notifier)
- [Modos de Notificación →](/documentation/listen_it/collections/notification_modes)
- [Transacciones →](/documentation/listen_it/collections/transactions)
