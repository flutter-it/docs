# Modos de Notificación

Controla cuándo se notifica a los listeners con tres modos de notificación: `always`, `normal` y `manual`.

## Descripción General

Todas las colecciones reactivas (ListNotifier, MapNotifier, SetNotifier) soportan tres modos de notificación via el enum `CustomNotifierMode`:

| Modo | Comportamiento | Usar Cuando |
|------|----------|----------|
| **always** | Notifica en cada operación, incluso si el valor no cambia | Predeterminado para colecciones - previene confusión de actualización de UI |
| **normal** | Solo notifica cuando el valor realmente cambia (usando `==` o igualdad personalizada) | Predeterminado para CustomValueNotifier - optimizando rendimiento |
| **manual** | Sin notificaciones automáticas - llama a `notifyListeners()` manualmente | Control completo sobre notificaciones |

**Por qué `always` es el predeterminado para colecciones:** Los usuarios esperan que la UI se reconstruya cuando realizan una operación (como añadir un item). Si la operación no dispara una notificación, podría sorprender a los usuarios cuando la UI no se actualiza como esperado. El modo `always` asegura comportamiento consistente independientemente de si los objetos sobrescriben `==`.

::: tip Predeterminados Diferentes
**Colecciones Reactivas** (ListNotifier, MapNotifier, SetNotifier) usan modo `always` por defecto.

**CustomValueNotifier** usa modo `normal` por defecto para ser un **reemplazo directo de ValueNotifier**, coincidiendo con su comportamiento de solo notificar cuando el valor realmente cambia.

[Aprende más sobre CustomValueNotifier →](/documentation/listen_it/listen_it#customvaluenotifier)
:::

## Uso Básico

<<< @/../code_samples/lib/listen_it/notification_modes.dart#example

## Modo always (Predeterminado)

Notifica a los listeners en cada operación, independientemente de si el valor realmente cambió.

### Por Qué Es el Predeterminado

```dart
class User {
  final String name;
  final int age;

  User(this.name, this.age);

  // ❌️ Sin sobrescritura de igualdad - cada instancia es única
}

final users = ListNotifier<User>();  // Predeterminado: modo always

users.listen((list, _) => print('Users: ${list.length}'));

final user1 = User('John', 25);
users.add(user1);  // ✅ Notifica
users.add(user1);  // ✅ Notifica (referencia duplicada, pero UI se actualiza)
```

**Problema con modo `normal` aquí:** Sin sobrescribir `==`, Dart usa igualdad de referencia. Aunque sea la misma referencia de objeto, los usuarios podrían esperar que la UI se actualice cuando llaman a `.add()`.

**Solución:** Usar modo `always` por defecto para que la UI siempre se actualice cuando se realizan operaciones. Esto coincide con las expectativas del usuario y previene confusión.

### Cuándo Usar always

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Opción predeterminada - funciona correctamente independientemente de la implementación de igualdad</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Cuando quieres que la UI se actualice en cada operación</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Cuando los objetos no sobrescriben el operador `==`</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Al depurar - ver cada operación</li>
</ul>

```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.always,
);

items.add('item');  // ✅ Notifica
items.add('item');  // ✅ Notifica (aunque sea duplicado)
items[0] = 'item';  // ✅ Notifica (aunque el valor no cambió)
```

## Modo normal

Solo notifica a los listeners cuando el valor realmente cambia, usando comparación `==` (o función de igualdad personalizada).

### Uso Básico

```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.normal,
);

items.listen((list, _) => print('Changed: $list'));

items.add('item1');  // ✅ Notifica (item nuevo)
items.add('item2');  // ✅ Notifica (item nuevo)
items[0] = 'item1';  // ❌️ Sin notificación (mismo valor)
items.remove('xyz'); // ❌️ Sin notificación (item no está en la lista)
```

### Con Igualdad Personalizada

Proporciona una función de comparación personalizada para objetos complejos:

```dart
class Product {
  final String id;
  final String name;
  final double price;

  Product(this.id, this.name, this.price);
}

final products = ListNotifier<Product>(
  notificationMode: CustomNotifierMode.normal,
  customEquality: (a, b) => a.id == b.id,  // Comparar solo por ID
);

final product1 = Product('1', 'Widget', 9.99);
final product2 = Product('1', 'Widget Pro', 14.99);  // Mismo ID, nombre diferente

products.add(product1);
products[0] = product2;  // ❌️ Sin notificación (mismo ID según customEquality)
```

### Operaciones Masivas en Modo normal

Diferentes operaciones masivas tienen diferente comportamiento de notificación:

**Operaciones de añadir/insertar** - Siempre notifican (incluso con entrada vacía):
```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.normal,
);

items.addAll([]);       // ✅ Notifica (aunque esté vacío)
items.insertAll(0, []); // ✅ Notifica (aunque esté vacío)
items.setAll(0, []);    // ✅ Notifica (aunque esté vacío)
```

**Operaciones de reemplazo** - Solo notifican si ocurrieron cambios:
```dart
items.fillRange(0, 2, 'a');    // Solo notifica si los valores cambiaron
items.replaceRange(0, 2, []); // Solo notifica si los valores cambiaron
```

### Cuándo Usar normal

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Optimización de rendimiento - reducir notificaciones innecesarias</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Los objetos sobrescriben el operador `==` correctamente</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Tienes lógica de igualdad personalizada</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Las operaciones sin efecto no deberían disparar actualizaciones de UI</li>
</ul>

```dart
class Todo {
  final String id;
  final String title;
  final bool completed;

  Todo(this.id, this.title, this.completed);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Todo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          completed == other.completed;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ completed.hashCode;
}

final todos = ListNotifier<Todo>(
  notificationMode: CustomNotifierMode.normal,
);

final todo1 = Todo('1', 'Buy milk', false);
todos.add(todo1);              // ✅ Notifica
todos[0] = todo1;               // ❌️ Sin notificación (mismo objeto)
todos[0] = Todo('1', 'Buy milk', false);  // ❌️ Sin notificación (igual por ==)
```

## Modo manual

Sin notificaciones automáticas - debes llamar a `notifyListeners()` manualmente.

### Uso Básico

```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.manual,
);

items.listen((list, _) => print('Manual notification: $list'));

items.add('item1');  // Sin notificación
items.add('item2');  // Sin notificación
items.add('item3');  // Sin notificación

items.notifyListeners();  // ✅ Una sola notificación para las 3 adiciones
```

### Cuándo Usar manual

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Operaciones complejas que requieren múltiples pasos</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Quieres control explícito sobre cuándo se disparan las notificaciones</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Agrupar operaciones para rendimiento (¡usa transacciones en su lugar!)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Notificaciones condicionales basadas en lógica personalizada</li>
</ul>

```dart
final cart = ListNotifier<Product>(
  notificationMode: CustomNotifierMode.manual,
);

void updateCart(List<Product> newProducts) {
  cart.clear();
  cart.addAll(newProducts);

  // Solo notificar si el carrito no está vacío
  if (cart.isNotEmpty) {
    cart.notifyListeners();
  }
}
```

### manual vs Transacciones

Para agrupar operaciones, **las transacciones son usualmente mejores** que el modo manual:

**❌️ Con modo manual:**
```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.manual,
);

// Debes recordar llamar a notifyListeners()
items.add('a');
items.add('b');
items.notifyListeners();  // ¡Fácil de olvidar!
```

**✅ Con transacciones (cualquier modo):**
```dart
final items = ListNotifier<String>();  // Cualquier modo funciona

items.startTransAction();
items.add('a');
items.add('b');
items.endTransAction();  // Notificación garantizada
```

[Aprende más sobre transacciones →](/documentation/listen_it/collections/transactions)

## Tabla de Comparación

| Operación | always | normal | manual |
|-----------|--------|--------|--------|
| `add(newItem)` | ✅ Notifica | ✅ Notifica | ❌️ Sin notificación |
| `add(duplicate)` (Set) | ✅ Notifica | ❌️ Sin notificación | ❌️ Sin notificación |
| `[index] = sameValue` | ✅ Notifica | ❌️ Sin notificación | ❌️ Sin notificación |
| `remove(nonExistent)` | ✅ Notifica | ❌️ Sin notificación | ❌️ Sin notificación |
| `addAll([])` (vacío) | ✅ Notifica | ✅ Notifica | ❌️ Sin notificación |
| `fillRange()` sin cambio | ✅ Notifica | ❌️ Sin notificación | ❌️ Sin notificación |
| `notifyListeners()` | ✅ Notifica | ✅ Notifica | ✅ Notifica |

## Eligiendo el Modo Correcto

### Árbol de Decisión

```
¿Necesitas control completo sobre las notificaciones?
├─ SÍ → Usa modo manual
│         (¡Pero considera transacciones en su lugar!)
└─ NO → ¿Tus objetos sobrescriben ==?
         ├─ SÍ → Usa modo normal
         │         (Reduce notificaciones innecesarias)
         └─ NO/INSEGURO → Usa modo always (predeterminado)
                        (Previene confusión de actualización de UI)
```

### Recomendaciones por Tipo de Colección

**ListNotifier:**
- Predeterminado: `always` - Los usuarios esperan actualizaciones de UI en cada operación
- Usa `normal` si: La lista contiene tipos de valor con `==` apropiado (String, int, etc.)
- Usa `manual` si: Tienes operaciones de lote complejas

**MapNotifier:**
- Predeterminado: `always` - Opción segura para cualquier tipo de valor
- Usa `normal` si: Tienes comparación de clave personalizada o igualdad de valor
- Usa `manual` si: Estás construyendo el map en etapas

**SetNotifier:**
- Predeterminado: `always` - Previene confusión al añadir duplicados
- Usa `normal` si: Quieres sin notificación al añadir items existentes
- Usa `manual` si: Estás cargando datos masivamente

## Ejemplos del Mundo Real

### Ejemplo 1: Carrito de Compras (modo normal)

```dart
class CartItem {
  final String id;
  final String name;
  final int quantity;
  final double price;

  CartItem(this.id, this.name, this.quantity, this.price);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          id == other.id &&
          name == other.name &&
          quantity == other.quantity &&
          price == other.price;

  @override
  int get hashCode => Object.hash(id, name, quantity, price);
}

final cart = ListNotifier<CartItem>(
  notificationMode: CustomNotifierMode.normal,
);

// Solo notifica cuando el carrito realmente cambia
void updateItemQuantity(String id, int newQuantity) {
  final index = cart.indexWhere((item) => item.id == id);
  if (index != -1) {
    final item = cart[index];
    cart[index] = CartItem(item.id, item.name, newQuantity, item.price);
    // Solo notifica si la cantidad realmente cambió
  }
}
```

### Ejemplo 2: Items Seleccionados (modo normal)

```dart
final selectedIds = SetNotifier<String>(
  notificationMode: CustomNotifierMode.normal,
);

selectedIds.listen((ids, _) => print('Selection changed: $ids'));

selectedIds.add('item1');  // ✅ Notifica
selectedIds.add('item1');  // ❌️ Sin notificación (ya está en el set)
selectedIds.add('item2');  // ✅ Notifica
```

### Ejemplo 3: Datos de Formulario (modo manual)

```dart
final formData = MapNotifier<String, String>(
  notificationMode: CustomNotifierMode.manual,
);

void loadFormData(Map<String, String> data) {
  formData.clear();
  formData.addAll(data);
  // Solo notificar después de que todos los datos estén cargados
  formData.notifyListeners();
}

void validateAndSubmit() {
  if (isValid(formData)) {
    formData.notifyListeners();  // Notificar solo si es válido
    submitForm(formData);
  }
}
```

## Consideraciones de Rendimiento

### Modo always
- **Pros:** Simple, predecible, previene bugs de UI
- **Contras:** Puede notificar más a menudo de lo necesario
- **Impacto:** Usualmente insignificante a menos que sean miles de actualizaciones/segundo

### Modo normal
- **Pros:** Reduce notificaciones innecesarias, mejor rendimiento
- **Contras:** Requiere implementación apropiada de `==`, ligeramente más complejo
- **Impacto:** Puede reducir significativamente reconstrucciones con operaciones sin efecto frecuentes

### Modo manual
- **Pros:** Control máximo, puede agrupar múltiples operaciones
- **Contras:** Fácil olvidar notificaciones, más propenso a errores
- **Impacto:** Mejor rendimiento cuando se usa correctamente

## Próximos Pasos

- [Transacciones →](/documentation/listen_it/collections/transactions)
- [ListNotifier →](/documentation/listen_it/collections/list_notifier)
- [MapNotifier →](/documentation/listen_it/collections/map_notifier)
- [SetNotifier →](/documentation/listen_it/collections/set_notifier)
- [Volver a Colecciones →](/documentation/listen_it/collections/introduction)
