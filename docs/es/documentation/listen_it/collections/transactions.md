# Transacciones

Agrupa múltiples operaciones en una sola notificación para mejor rendimiento y actualizaciones atómicas.

## Descripción General

Las transacciones te permiten hacer múltiples cambios a una colección reactiva mientras disparas solo una notificación al final. Esto es útil para:

- **Rendimiento** - Reducir reconstrucciones de UI de múltiples operaciones
- **Actualizaciones atómicas** - Asegurar que todos los cambios se completen antes de notificar a los listeners
- **Código más limpio** - Agrupación explícita de operaciones relacionadas

## Uso Básico

<<< @/../code_samples/lib/listen_it/transactions.dart#example

## Cómo Funcionan las Transacciones

Cuando llamas a `startTransAction()`:
1. El flag `_inTransaction` se establece en `true`
2. Todas las operaciones de mutación actualizan la colección pero no notifican a los listeners
3. El flag `_hasChanged` rastrea si ocurrieron cambios reales
4. Cuando se llama a `endTransAction()`, se dispara una sola notificación (si ocurrieron cambios)

```dart
final items = ListNotifier<int>();

items.listen((list, _) => print('Notification: $list'));

// Sin transacción: 3 notificaciones
items.add(1);  // Notificación 1
items.add(2);  // Notificación 2
items.add(3);  // Notificación 3

items.clear();

// Con transacción: 1 notificación
items.startTransAction();
items.add(1);  // Sin notificación
items.add(2);  // Sin notificación
items.add(3);  // Sin notificación
items.endTransAction();  // Una sola notificación con [1, 2, 3]
```

## Casos de Uso

### 1. Carga Masiva de Datos

Cargar múltiples items sin disparar notificaciones para cada uno:

```dart
final products = ListNotifier<Product>();

products.listen((list, _) => rebuildUI());

void loadProducts(List<Product> data) {
  products.startTransAction();
  products.clear();
  products.addAll(data);
  products.endTransAction();  // Una sola reconstrucción de UI
}
```

### 2. Actualizaciones de Estado Atómicas

Asegurar que cambios relacionados ocurran juntos:

```dart
final cart = ListNotifier<CartItem>();

void updateItemQuantity(String itemId, int newQuantity) {
  cart.startTransAction();

  final index = cart.indexWhere((item) => item.id == itemId);
  if (index != -1) {
    if (newQuantity <= 0) {
      cart.removeAt(index);
    } else {
      final item = cart[index];
      cart[index] = CartItem(item.id, item.name, newQuantity, item.price);
    }
  }

  cart.endTransAction();  // Una sola notificación para la operación completa
}
```

### 3. Múltiples Operaciones Relacionadas

Agrupar operaciones que deben verse como un solo cambio lógico:

```dart
final todos = ListNotifier<Todo>();

void moveTodo(int fromIndex, int toIndex) {
  todos.startTransAction();

  final todo = todos.removeAt(fromIndex);
  todos.insert(toIndex, todo);

  todos.endTransAction();  // Una sola notificación
}
```

### 4. Agrupación Condicional

Lógica compleja con múltiples rutas:

```dart
final items = ListNotifier<String>();

void processUpdates(List<String> updates) {
  items.startTransAction();

  for (final update in updates) {
    if (shouldAdd(update)) {
      items.add(update);
    } else if (shouldRemove(update)) {
      items.remove(update);
    } else if (shouldUpdate(update)) {
      final index = items.indexOf(update);
      if (index != -1) {
        items[index] = update;
      }
    }
  }

  items.endTransAction();  // Una sola notificación para todos los cambios
}
```

## Comportamiento de Transacciones con Modos de Notificación

Las transacciones funcionan con todos los modos de notificación:

### Con Modo always (Predeterminado)

```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.always,
);

items.startTransAction();
items.add('a');
items.add('b');
items.endTransAction();  // ✅ Notifica (modo always)
```

### Con Modo normal

```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.normal,
);

items.startTransAction();
items.add('a');
items.add('a');  // Duplicado, sin cambio real
items.endTransAction();  // ✅ Notifica (algo cambió)

items.startTransAction();
items.remove('nonexistent');  // Sin cambio real
items.endTransAction();  // ❌️ Sin notificación (nada cambió)
```

### Con Modo manual

```dart
final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.manual,
);

items.startTransAction();
items.add('a');
items.add('b');
items.endTransAction();  // ❌️ Sin notificación (modo manual)

// Debe llamar a notifyListeners() manualmente incluso después de la transacción
items.notifyListeners();  // ✅ Ahora notifica
```

[Aprende más sobre modos de notificación →](/documentation/listen_it/collections/notification_modes)

## Transacciones Anidadas

Las transacciones anidadas **no están permitidas** y causarán un error de aserción:

```dart
final items = ListNotifier<int>();

items.startTransAction();
items.add(1);

// ❌️ ERROR: Aserción falló
items.startTransAction();  // ¡No se pueden anidar transacciones!
```

**Por qué no están permitidas:**
- Implementación más simple
- Código más claro - una transacción a la vez
- Evitar confusión sobre cuándo se disparan las notificaciones

**Alternativa:** Completa la primera transacción antes de iniciar otra:

```dart
void operation1() {
  items.startTransAction();
  items.add(1);
  items.endTransAction();
}

void operation2() {
  items.startTransAction();
  items.add(2);
  items.endTransAction();
}

// Llamar por separado
operation1();
operation2();
```

## Seguridad de Transacciones

### Siempre Terminar Transacciones

Asegúrate de siempre llamar a `endTransAction()`, incluso si ocurren errores:

**❌️ Inseguro:**
```dart
items.startTransAction();
items.add(data);  // Podría lanzar excepción
items.endTransAction();  // ¡Podría nunca ser llamado!
```

**✅ Seguro:**
```dart
items.startTransAction();
try {
  items.add(data);
} finally {
  items.endTransAction();  // Siempre llamado
}
```

### Las Aserciones Ayudan a Detectar Errores

La implementación incluye aserciones para ayudar a detectar errores:

```dart
// Aserción al iniciar transacción anidada
assert(!_inTransaction, 'Only one transaction at a time');

// Aserción al terminar sin transacción activa
assert(_inTransaction, 'No active transaction');
```

Estas aserciones solo se disparan en modo debug pero ayudan a detectar bugs durante el desarrollo.

## Beneficios de Rendimiento

### Sin Transacciones

```dart
final items = ListNotifier<String>();

items.listen((list, _) {
  // Reconstrucción costosa de UI
  rebuildComplexWidget(list);
});

void loadData(List<String> data) {
  for (final item in data) {
    items.add(item);  // ¡Reconstruye UI para CADA item!
  }
}

// ¡Cargar 100 items = 100 reconstrucciones de UI!
loadData(List.generate(100, (i) => 'item$i'));
```

### Con Transacciones

```dart
final items = ListNotifier<String>();

items.listen((list, _) {
  // Reconstrucción costosa de UI
  rebuildComplexWidget(list);
});

void loadData(List<String> data) {
  items.startTransAction();
  for (final item in data) {
    items.add(item);  // Sin notificación
  }
  items.endTransAction();  // ¡Una sola reconstrucción de UI!
}

// ¡Cargar 100 items = 1 reconstrucción de UI!
loadData(List.generate(100, (i) => 'item$i'));
```

**Mejora de rendimiento:** ¡De O(n) reconstrucciones a O(1) reconstrucción!

## Ejemplos del Mundo Real

### Ejemplo 1: Checkout de Carrito de Compras

```dart
class CheckoutService {
  final cart = ListNotifier<CartItem>();
  final purchaseHistory = ListNotifier<Purchase>();

  Future<void> checkout() async {
    cart.startTransAction();

    // Crear registro de compra
    final purchase = Purchase(
      items: List.from(cart),
      total: calculateTotal(cart),
      timestamp: DateTime.now(),
    );

    // Procesar pago
    await processPayment(purchase);

    // Añadir al historial
    purchaseHistory.add(purchase);

    // Limpiar carrito
    cart.clear();

    cart.endTransAction();  // Una sola notificación después de completar checkout
  }
}
```

### Ejemplo 2: Reordenamiento con Arrastrar y Soltar

<<< @/../code_samples/lib/listen_it/transaction_reorder_widget.dart#example

### Ejemplo 3: Sincronización de Datos por Lotes

```dart
class DataSyncService {
  final cache = MapNotifier<String, User>();

  Future<void> syncUsers() async {
    final updates = await fetchUserUpdates();

    cache.startTransAction();

    for (final update in updates) {
      switch (update.type) {
        case UpdateType.add:
          cache[update.id] = update.user;
          break;
        case UpdateType.remove:
          cache.remove(update.id);
          break;
        case UpdateType.modify:
          cache[update.id] = update.user;
          break;
      }
    }

    cache.endTransAction();  // Una sola notificación después de todas las actualizaciones
  }
}
```

### Ejemplo 4: Actualizaciones Masivas de Formulario

```dart
class FormModel {
  final fields = MapNotifier<String, String>();

  void loadFromJson(Map<String, dynamic> json) {
    fields.startTransAction();
    fields.clear();
    json.forEach((key, value) {
      fields[key] = value.toString();
    });
    fields.endTransAction();  // Una sola notificación
  }

  void resetToDefaults() {
    fields.startTransAction();
    fields['name'] = '';
    fields['email'] = '';
    fields['phone'] = '';
    fields['address'] = '';
    fields.endTransAction();  // Una sola notificación
  }
}
```

## Mejores Prácticas

### 1. Usar Transacciones para Operaciones Masivas

Cada vez que hagas múltiples cambios relacionados:

```dart
// ✅ Bueno
items.startTransAction();
for (final item in newItems) {
  items.add(item);
}
items.endTransAction();

// ❌️ Malo
for (final item in newItems) {
  items.add(item);  // ¡Notificación para cada uno!
}
```

### 2. Mantener Transacciones Cortas

No mantener transacciones abiertas por largos períodos o a través de operaciones async:

```dart
// ❌️ Malo - transacción mantenida durante operación async
items.startTransAction();
items.clear();
await fetchData();  // Operación async larga
items.addAll(data);
items.endTransAction();

// ✅ Bueno - transacción solo alrededor de operaciones síncronas
final data = await fetchData();
items.startTransAction();
items.clear();
items.addAll(data);
items.endTransAction();
```

### 3. Usar try/finally para Seguridad

Siempre asegurar que las transacciones terminen:

```dart
items.startTransAction();
try {
  // Operaciones que podrían lanzar error
  complexOperation();
} finally {
  items.endTransAction();
}
```

### 4. Preferir Transacciones Sobre Modo manual

Para agrupar operaciones, las transacciones son más claras que el modo manual:

```dart
// ✅ Mejor - funciona con cualquier modo de notificación
items.startTransAction();
items.add('a');
items.add('b');
items.endTransAction();

// ❌️ Peor - requiere modo manual, fácil olvidar notificación
items.add('a');
items.add('b');
items.notifyListeners();
```

## Comparación: Transacciones vs Modo manual

| Característica | Transacciones | Modo manual |
|---------|-------------|-------------|
| **Sintaxis** | `startTransAction()` / `endTransAction()` | `notifyListeners()` |
| **Funciona con cualquier modo** | ✅ Sí | ❌️ No (requiere modo manual) |
| **Intención clara** | ✅ Agrupación explícita | ❌️ Fácil olvidar notificación |
| **Aserciones** | ✅ Ayuda a detectar errores | ❌️ Sin verificaciones de seguridad |
| **Recomendado** | ✅ Sí | ⚠️ Usa transacciones en su lugar |

## Próximos Pasos

- [Modos de Notificación →](/documentation/listen_it/collections/notification_modes)
- [ListNotifier →](/documentation/listen_it/collections/list_notifier)
- [MapNotifier →](/documentation/listen_it/collections/map_notifier)
- [SetNotifier →](/documentation/listen_it/collections/set_notifier)
- [Volver a Colecciones →](/documentation/listen_it/collections/introduction)
