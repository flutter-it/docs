# SetNotifier

Un Set reactivo que notifica automáticamente a los listeners cuando su contenido cambia.

## Descripción General

`SetNotifier<T>` es una implementación de Set reactivo que:
- Extiende la interfaz estándar de Dart `Set<T>`
- Implementa `ValueListenable<Set<T>>`
- Notifica automáticamente a los listeners en las mutaciones
- Soporta transacciones para agrupar operaciones
- Proporciona modos de notificación configurables
- Garantiza unicidad de elementos (comportamiento de Set)

## Uso Básico

```dart
final selectedIds = SetNotifier<String>(data: {});

selectedIds.listen((set, _) => print('Selected: $set'));

selectedIds.add('id1');  // ✅ Notifica
selectedIds.add('id2');  // ✅ Notifica
selectedIds.add('id1');  // No se añade duplicado (comportamiento de Set)
```

## Creando un SetNotifier

### Set Vacío

```dart
final tags = SetNotifier<String>();
```

### Con Datos Iniciales

```dart
final permissions = SetNotifier<String>(
  data: {'read', 'write'},
);
```

### Con Modo de Notificación

```dart
final selectedItems = SetNotifier<String>(
  notificationMode: CustomNotifierMode.normal,
);
```

### Sin Igualdad Personalizada

**Importante:** A diferencia de `ListNotifier` y `MapNotifier`, `SetNotifier` **NO** soporta funciones de igualdad personalizadas. Los Sets usan inherentemente `==` y `hashCode` para pruebas de membresía. La igualdad personalizada solo aplicaría a decisiones de notificación, lo que podría ser confuso.

```dart
// ❌️ SetNotifier no tiene parámetro customEquality
// final items = SetNotifier<Product>(
//   customEquality: (a, b) => a.id == b.id,  // NO SOPORTADO
// );

// ✅ Sobrescribe == y hashCode en tu clase en su lugar
class Product {
  final String id;
  final String name;

  Product(this.id, this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

final products = SetNotifier<Product>();
```

## Operaciones Estándar de Set

SetNotifier soporta todas las operaciones estándar de Set con notificaciones automáticas:

### Añadiendo Elementos

```dart
final tags = SetNotifier<String>();

tags.add('flutter');           // Añadir elemento único
tags.addAll(['dart', 'web']);  // Añadir múltiples elementos
```

### Eliminando Elementos

```dart
tags.remove('flutter');           // Eliminar por valor
tags.removeAll({'dart', 'web'});  // Eliminar múltiples
tags.retainAll({'flutter'});      // Mantener solo especificados
tags.removeWhere((tag) => tag.startsWith('old_')); // Eliminar condicionalmente
tags.retainWhere((tag) => tag.length > 3);         // Mantener solo coincidentes
tags.clear();                     // Eliminar todos los elementos
```

### Operaciones de Set

Las operaciones estándar de set devuelven **nuevos sets** y no modifican el set actual, por lo que no disparan notificaciones:

```dart
final set1 = SetNotifier<int>(data: {1, 2, 3});
final set2 = {2, 3, 4};

// Estos devuelven nuevos sets, no modifican set1, sin notificaciones
final union = set1.union(set2);            // {1, 2, 3, 4}
final intersection = set1.intersection(set2); // {2, 3}
final difference = set1.difference(set2);   // {1}
```

Si quieres aplicar estas operaciones y disparar notificación:

```dart
final result = set1.union(set2);
set1.startTransAction();
set1.clear();
set1.addAll(result);
set1.endTransAction();  // Notificación
```

### Pruebas de Membresía

```dart
tags.contains('flutter');     // Verificar si el elemento existe
tags.containsAll({'flutter', 'dart'}); // Verificar si todos existen
tags.lookup('flutter');       // Obtener elemento canónico
```

## Integración con Flutter

### Con ValueListenableBuilder

<<< @/../code_samples/lib/listen_it/set_notifier_widget.dart#example

### Con watch_it

<<< @/../code_samples/lib/listen_it/set_notifier_watch_it.dart#example

## Modos de Notificación

SetNotifier soporta tres modos de notificación:

### always (Predeterminado)

```dart
final items = SetNotifier<String>(
  data: {'item1'},
  notificationMode: CustomNotifierMode.always,
);

items.add('item1');  // ✅ Notifica (aunque ya existe)
items.add('item2');  // ✅ Notifica
items.remove('xyz'); // ✅ Notifica (aunque no existe)
```

**¿Por qué predeterminado?** Sin ver el valor de retorno de `add()` o `remove()`, los usuarios podrían esperar actualizaciones de UI cuando realizan operaciones.

### normal

```dart
final items = SetNotifier<String>(
  data: {'item1'},
  notificationMode: CustomNotifierMode.normal,
);

items.add('item1');  // ❌️ Sin notificación (ya existe)
items.add('item2');  // ✅ Notifica (elemento nuevo)
items.remove('xyz'); // ❌️ Sin notificación (no existe)
```

**Mejor para:** Optimizar rendimiento cuando tienes muchos intentos de añadir/eliminar duplicados.

### manual

```dart
final items = SetNotifier<String>(
  notificationMode: CustomNotifierMode.manual,
);

items.add('item1');  // Sin notificación
items.add('item2');  // Sin notificación
items.notifyListeners();  // ✅ Notificación manual
```

[Aprende más sobre modos de notificación →](/documentation/listen_it/collections/notification_modes)

## Transacciones

Agrupa múltiples operaciones en una sola notificación:

```dart
final tags = SetNotifier<String>();

tags.startTransAction();
tags.add('flutter');
tags.add('dart');
tags.add('web');
tags.endTransAction();  // Una sola notificación
```

[Aprende más sobre transacciones →](/documentation/listen_it/collections/transactions)

## Valor Inmutable

El getter `.value` devuelve una vista no modificable:

```dart
final items = SetNotifier<String>(data: {'a', 'b'});

final immutableView = items.value;
print(immutableView);  // {a, b}

// ❌️ Lanza UnsupportedError
// immutableView.add('c');

// ✅ Mutar a través del notifier
items.add('c');  // Funciona y notifica
```

Esto asegura que todas las mutaciones pasen por el sistema de notificación.

## Comportamiento de Operaciones Masivas

Las operaciones masivas de SetNotifier **siempre notifican** (incluso con entrada vacía) en todos los modos excepto manual:

```dart
final items = SetNotifier<String>(
  notificationMode: CustomNotifierMode.normal,
);

items.addAll({});       // ✅ Notifica (aunque esté vacío)
items.removeAll({});    // ✅ Notifica (aunque esté vacío)
items.retainAll({});    // ✅ Notifica (aunque esté vacío)
```

**¿Por qué?** Por razones de rendimiento - para evitar comparar todos los elementos. Estas operaciones se usan típicamente para actualizaciones masivas.

## Casos de Uso

::: details Items Seleccionados

```dart
class SelectionModel<T> {
  final selected = SetNotifier<T>();

  bool isSelected(T item) => selected.contains(item);

  void toggle(T item) {
    if (selected.contains(item)) {
      selected.remove(item);
    } else {
      selected.add(item);
    }
  }

  void selectAll(Iterable<T> items) {
    selected.startTransAction();
    selected.addAll(items);
    selected.endTransAction();
  }

  void clearSelection() {
    selected.clear();
  }

  int get selectionCount => selected.length;
}
```
:::

::: details Filtros Activos

```dart
class FilterModel {
  final activeFilters = SetNotifier<String>(
    data: {},
    notificationMode: CustomNotifierMode.normal,
  );

  void toggleFilter(String filter) {
    if (activeFilters.contains(filter)) {
      activeFilters.remove(filter);
    } else {
      activeFilters.add(filter);
    }
  }

  void clearFilters() {
    activeFilters.clear();
  }

  void setFilters(Set<String> filters) {
    activeFilters.startTransAction();
    activeFilters.clear();
    activeFilters.addAll(filters);
    activeFilters.endTransAction();
  }

  bool isActive(String filter) => activeFilters.contains(filter);
}
```
:::

::: details Gestión de Etiquetas

```dart
class TagsModel {
  final tags = SetNotifier<String>();

  void addTag(String tag) {
    if (tag.trim().isNotEmpty) {
      tags.add(tag.trim().toLowerCase());
    }
  }

  void addTags(Iterable<String> newTags) {
    tags.startTransAction();
    for (final tag in newTags) {
      if (tag.trim().isNotEmpty) {
        tags.add(tag.trim().toLowerCase());
      }
    }
    tags.endTransAction();
  }

  void removeTag(String tag) {
    tags.remove(tag.toLowerCase());
  }

  bool hasTag(String tag) => tags.contains(tag.toLowerCase());

  void clearTags() {
    tags.clear();
  }

  List<String> get sortedTags => tags.toList()..sort();
}
```
:::

::: details Permisos de Usuario

```dart
class PermissionsModel {
  final permissions = SetNotifier<String>(
    data: {'read'},  // Permiso predeterminado
    notificationMode: CustomNotifierMode.normal,
  );

  void grantPermission(String permission) {
    permissions.add(permission);
  }

  void revokePermission(String permission) {
    permissions.remove(permission);
  }

  void setPermissions(Set<String> newPermissions) {
    permissions.startTransAction();
    permissions.clear();
    permissions.addAll(newPermissions);
    permissions.endTransAction();
  }

  bool hasPermission(String permission) => permissions.contains(permission);

  bool hasAllPermissions(Iterable<String> required) =>
      permissions.containsAll(required);

  bool hasAnyPermission(Iterable<String> options) =>
      options.any((p) => permissions.contains(p));
}
```
:::

## Consideraciones de Rendimiento

### Memoria

SetNotifier tiene sobrecarga mínima comparado con un Set regular:
- Extiende `DelegatingSet` (de package:collection)
- Añade mecanismo de notificación de `ChangeNotifier`
- Pequeña sobrecarga para modo de notificación y flags de transacción

### Notificaciones

Cada mutación dispara una notificación (a menos que esté en transacción o modo manual):
- **Costo:** O(n) donde n = número de listeners
- **Optimización:** Usa transacciones para operaciones masivas
- **Mejor práctica:** Mantén el conteo de listeners razonable (< 50)

### Rendimiento de Operaciones de Set

- `add()`, `remove()`, `contains()`: O(1) caso promedio
- `addAll()`, `removeAll()`: O(m) donde m = tamaño de entrada
- `union()`, `intersection()`, `difference()`: O(n + m) donde n, m son tamaños de set

### Sets Grandes

Para sets muy grandes (1000+ elementos):
- Considera paginación o carga diferida
- Usa transacciones al añadir/eliminar muchos elementos
- Considera modo `normal` si tienes muchas operaciones duplicadas

```dart
// ❌️ Malo: 1000 notificaciones
for (final item in items) {
  set.add(item);
}

// ✅ Bueno: 1 notificación
set.startTransAction();
for (final item in items) {
  set.add(item);
}
set.endTransAction();

// ✅ Aún mejor: addAll
set.startTransAction();
set.addAll(items);
set.endTransAction();
```

## Combinando con Operators

Puedes encadenar operators de listen_it en un SetNotifier:

```dart
final tags = SetNotifier<String>();

// Reaccionar solo cuando cambia el tamaño del set
final tagCount = tags.select<int>((set) => set.length);

// Filtrar a sets no vacíos
final hasTags = tags.where((set) => set.isNotEmpty);

// Debounce cambios rápidos
final debouncedTags = tags.debounce(Duration(milliseconds: 300));

// Usar en widget
ValueListenableBuilder<int>(
  valueListenable: tagCount,
  builder: (context, count, _) => Text('$count tags'),
);
```

[Aprende más sobre operators →](/documentation/listen_it/operators/overview)

## Referencia de API

### Constructor

```dart
SetNotifier({
  Set<T>? data,
  CustomNotifierMode notificationMode = CustomNotifierMode.always,
})
```

### Propiedades

| Propiedad | Tipo | Descripción |
|----------|------|-------------|
| `value` | `Set<T>` | Vista no modificable del set actual |
| `length` | `int` | Número de elementos |
| `isEmpty` | `bool` | Si el set está vacío |
| `isNotEmpty` | `bool` | Si el set tiene elementos |
| `first` | `T` | Primer elemento (orden no garantizado) |
| `last` | `T` | Último elemento (orden no garantizado) |
| `single` | `T` | Elemento único (lanza error si no hay exactamente uno) |

### Métodos

Todos los métodos estándar de `Set<T>` más:

| Método | Descripción |
|--------|-------------|
| `startTransAction()` | Comenzar transacción |
| `endTransAction()` | Terminar transacción y notificar |
| `notifyListeners()` | Notificar manualmente (útil con modo manual) |

### Valores de Retorno

Algunos métodos devuelven `bool` indicando si el set fue modificado:

```dart
final added = items.add('item');        // true si se añadió, false si ya existía
final removed = items.remove('item');   // true si se eliminó, false si no existía
```

En modo `normal`, las notificaciones se basan en estos valores de retorno.

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

### 3. Esperar Iteración Ordenada

```dart
// ❌️ Los Sets no garantizan orden
final items = SetNotifier<int>(data: {3, 1, 2});
print(items.toList());  // Puede ser [1, 2, 3] o [3, 1, 2] o cualquier orden

// ✅ Ordenar si necesitas orden específico
final sorted = items.toList()..sort();
```

### 4. No Sobrescribir == y hashCode

```dart
// ❌️ Sin igualdad apropiada, duplicados basados en identidad
class User {
  final String id;
  final String name;

  User(this.id, this.name);
}

final users = SetNotifier<User>();
users.add(User('1', 'John'));
users.add(User('1', 'John'));  // ¡Añade duplicado! (instancias diferentes)

// ✅ Sobrescribir == y hashCode
class User {
  final String id;
  final String name;

  User(this.id, this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

final users = SetNotifier<User>();
users.add(User('1', 'John'));
users.add(User('1', 'John'));  // Sin duplicado (mismo id)
```

## SetNotifier vs ListNotifier

| Característica | SetNotifier | ListNotifier |
|---------|-------------|--------------|
| **Duplicados** | Sin duplicados | Permite duplicados |
| **Orden** | Sin orden garantizado | Mantiene orden de inserción |
| **Búsqueda** | O(1) promedio | O(n) |
| **Caso de uso** | Items únicos, membresía rápida | Colecciones ordenadas |
| **Igualdad personalizada** | No (usar sobrescritura de ==) | Sí (parámetro customEquality) |

**Elige SetNotifier cuando:**
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Necesites elementos únicos</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Necesites pruebas de membresía rápidas (contains)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ El orden no importa</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Ejemplos: IDs seleccionados, filtros activos, permisos de usuario</li>
</ul>

**Elige ListNotifier cuando:**
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ El orden importa</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Se permiten duplicados</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Necesitas acceso por índice</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Ejemplos: listas de tareas, historial de mensajes, resultados de búsqueda</li>
</ul>

## Próximos Pasos

- [ListNotifier →](/documentation/listen_it/collections/list_notifier)
- [MapNotifier →](/documentation/listen_it/collections/map_notifier)
- [Modos de Notificación →](/documentation/listen_it/collections/notification_modes)
- [Transacciones →](/documentation/listen_it/collections/transactions)
- [Volver a Colecciones →](/documentation/listen_it/collections/introduction)
