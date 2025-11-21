# MapNotifier

Un Map reactivo que notifica automáticamente a los listeners cuando su contenido cambia.

## Descripción General

`MapNotifier<K, V>` es una implementación de Map reactivo que:
- Extiende la interfaz estándar de Dart `Map<K, V>`
- Implementa `ValueListenable<Map<K, V>>`
- Notifica automáticamente a los listeners en las mutaciones
- Soporta transacciones para agrupar operaciones
- Proporciona modos de notificación configurables

## Uso Básico

```dart
final preferences = MapNotifier<String, dynamic>(
  data: {'theme': 'dark', 'fontSize': 14},
);

preferences.listen((map, _) => print('Preferences: $map'));

preferences['theme'] = 'light';  // ✅ Notifica
preferences['fontSize'] = 16;    // ✅ Notifica
```

## Creando un MapNotifier

### Map Vacío

```dart
final cache = MapNotifier<String, User>();
```

### Con Datos Iniciales

```dart
final settings = MapNotifier<String, dynamic>(
  data: {
    'theme': 'dark',
    'language': 'en',
    'notifications': true,
  },
);
```

### Con Modo de Notificación

```dart
final cache = MapNotifier<String, User>(
  notificationMode: CustomNotifierMode.normal,
);
```

### Con Igualdad Personalizada

```dart
class Config {
  final String value;
  Config(this.value);
}

final configs = MapNotifier<String, Config>(
  notificationMode: CustomNotifierMode.normal,
  customEquality: (a, b) => a?.value == b?.value,  // Comparar por campo value
);
```

## Operaciones Estándar de Map

MapNotifier soporta todas las operaciones estándar de Map con notificaciones automáticas:

### Añadiendo/Actualizando Entradas

```dart
final map = MapNotifier<String, int>();

map['key1'] = 1;                    // Añadir/actualizar entrada única
map.addAll({'key2': 2, 'key3': 3}); // Añadir múltiples entradas
map.addEntries([
  MapEntry('key4', 4),
  MapEntry('key5', 5),
]);                                 // Añadir entradas desde iterable
map.putIfAbsent('key6', () => 6);   // Añadir si no está presente
```

### Eliminando Entradas

```dart
map.remove('key1');                 // Eliminar por clave
map.removeWhere((k, v) => v > 3);   // Eliminar condicionalmente
map.clear();                        // Eliminar todas las entradas
```

### Actualizando Valores

```dart
map.update('key1', (value) => value + 1);  // Actualizar existente
map.update('key1', (v) => v + 1, ifAbsent: () => 1);  // Actualizar o añadir
map.updateAll((k, v) => v * 2);            // Actualizar todos los valores
```

## Integración con Flutter

### Con ValueListenableBuilder

<<< @/../code_samples/lib/listen_it/map_notifier_widget.dart#example

### Con watch_it

<<< @/../code_samples/lib/listen_it/map_notifier_watch_it.dart#example

## Modos de Notificación

MapNotifier soporta tres modos de notificación:

### always (Predeterminado)

```dart
final map = MapNotifier<String, int>(
  data: {'count': 0},
  notificationMode: CustomNotifierMode.always,
);

map['count'] = 0;     // ✅ Notifica (aunque el valor no cambió)
map.remove('missing'); // ✅ Notifica (aunque la clave no existe)
```

### normal

```dart
final map = MapNotifier<String, int>(
  data: {'count': 0},
  notificationMode: CustomNotifierMode.normal,
);

map['count'] = 0;     // ❌️ Sin notificación (valor sin cambios)
map['count'] = 1;     // ✅ Notifica (valor cambió)
map.remove('missing'); // ❌️ Sin notificación (la clave no existe)
```

### manual

```dart
final map = MapNotifier<String, int>(
  notificationMode: CustomNotifierMode.manual,
);

map['key1'] = 1;  // Sin notificación
map['key2'] = 2;  // Sin notificación
map.notifyListeners();  // ✅ Notificación manual
```

[Aprende más sobre modos de notificación →](/documentation/listen_it/collections/notification_modes)

## Transacciones

Agrupa múltiples operaciones en una sola notificación:

```dart
final settings = MapNotifier<String, dynamic>();

settings.startTransAction();
settings['theme'] = 'dark';
settings['fontSize'] = 14;
settings['language'] = 'en';
settings.endTransAction();  // Una sola notificación
```

[Aprende más sobre transacciones →](/documentation/listen_it/collections/transactions)

## Valor Inmutable

El getter `.value` devuelve una vista no modificable:

```dart
final map = MapNotifier<String, int>(data: {'a': 1, 'b': 2});

final immutableView = map.value;
print(immutableView);  // {a: 1, b: 2}

// ❌️ Lanza UnsupportedError
// immutableView['c'] = 3;

// ✅ Mutar a través del notifier
map['c'] = 3;  // Funciona y notifica
```

Esto asegura que todas las mutaciones pasen por el sistema de notificación.

## Comportamiento de Operaciones Masivas

Las operaciones masivas de MapNotifier **siempre notifican** (incluso con entrada vacía) en todos los modos excepto manual:

```dart
final map = MapNotifier<String, int>(
  notificationMode: CustomNotifierMode.normal,
);

map.addAll({});          // ✅ Notifica (aunque esté vacío)
map.addEntries([]);      // ✅ Notifica (aunque esté vacío)
```

**¿Por qué?** Por razones de rendimiento - para evitar comparar todos los elementos. Estas operaciones se usan típicamente para carga masiva de datos.

## Casos de Uso

::: details Preferencias de Usuario

```dart
class PreferencesModel {
  final preferences = MapNotifier<String, dynamic>(
    data: {
      'theme': 'light',
      'fontSize': 14,
      'notifications': true,
    },
  );

  void setTheme(String theme) {
    preferences['theme'] = theme;
  }

  void setFontSize(int size) {
    preferences['fontSize'] = size;
  }

  void toggleNotifications() {
    preferences['notifications'] = !(preferences['notifications'] as bool);
  }

  void resetToDefaults() {
    preferences.startTransAction();
    preferences['theme'] = 'light';
    preferences['fontSize'] = 14;
    preferences['notifications'] = true;
    preferences.endTransAction();
  }

  void loadFromStorage(Map<String, dynamic> saved) {
    preferences.startTransAction();
    preferences.clear();
    preferences.addAll(saved);
    preferences.endTransAction();
  }
}
```
:::

::: details Gestión de Caché

```dart
class UserCache {
  final cache = MapNotifier<String, User>(
    notificationMode: CustomNotifierMode.normal,
  );

  void cacheUser(User user) {
    cache[user.id] = user;
  }

  void cacheUsers(List<User> users) {
    cache.startTransAction();
    for (final user in users) {
      cache[user.id] = user;
    }
    cache.endTransAction();
  }

  void removeUser(String userId) {
    cache.remove(userId);
  }

  void clearExpired() {
    cache.removeWhere((id, user) => user.isExpired);
  }

  User? getUser(String userId) => cache[userId];

  void clear() {
    cache.clear();
  }
}
```
:::

::: details Datos de Formulario

```dart
class FormModel {
  final fields = MapNotifier<String, String>(
    data: {
      'name': '',
      'email': '',
      'phone': '',
    },
  );

  void updateField(String field, String value) {
    fields[field] = value;
  }

  void loadFromJson(Map<String, dynamic> json) {
    fields.startTransAction();
    json.forEach((key, value) {
      fields[key] = value.toString();
    });
    fields.endTransAction();
  }

  Map<String, String> toJson() => Map.from(fields);

  void reset() {
    fields.startTransAction();
    fields.updateAll((key, value) => '');
    fields.endTransAction();
  }
}
```
:::

::: details Gestor de Configuración

```dart
class ConfigManager {
  final config = MapNotifier<String, dynamic>(
    notificationMode: CustomNotifierMode.normal,
  );

  Future<void> loadConfig() async {
    final data = await fetchConfigFromServer();

    config.startTransAction();
    config.clear();
    config.addAll(data);
    config.endTransAction();
  }

  T? get<T>(String key) => config[key] as T?;

  void set(String key, dynamic value) {
    config[key] = value;
  }

  void setAll(Map<String, dynamic> updates) {
    config.startTransAction();
    config.addAll(updates);
    config.endTransAction();
  }

  bool has(String key) => config.containsKey(key);

  void remove(String key) {
    config.remove(key);
  }
}
```
:::

## Consideraciones de Rendimiento

### Memoria

MapNotifier tiene sobrecarga mínima comparado con un Map regular:
- Extiende `DelegatingMap` (de package:collection)
- Añade mecanismo de notificación de `ChangeNotifier`
- Pequeña sobrecarga para modo de notificación y flags de transacción

### Notificaciones

Cada mutación dispara una notificación (a menos que esté en transacción o modo manual):
- **Costo:** O(n) donde n = número de listeners
- **Optimización:** Usa transacciones para operaciones masivas
- **Mejor práctica:** Mantén el conteo de listeners razonable (< 50)

### Maps Grandes

Para maps muy grandes (1000+ entradas):
- Considera dividir en múltiples maps más pequeños por categoría
- Usa transacciones al añadir/eliminar muchas entradas
- Considera modo `normal` si tienes muchas operaciones sin efecto

```dart
// ❌️ Malo: 1000 notificaciones
for (final entry in entries) {
  map[entry.key] = entry.value;
}

// ✅ Bueno: 1 notificación
map.startTransAction();
for (final entry in entries) {
  map[entry.key] = entry.value;
}
map.endTransAction();

// ✅ Aún mejor: addAll
map.startTransAction();
map.addAll(Map.fromEntries(entries));
map.endTransAction();
```

## Combinando con Operators

Puedes encadenar operators de listen_it en un MapNotifier:

```dart
final settings = MapNotifier<String, dynamic>();

// Reaccionar solo cuando cambia una clave específica
final themeOnly = settings.select<String?>((map) => map['theme']);

// Filtrar a maps no vacíos
final hasSettings = settings.where((map) => map.isNotEmpty);

// Debounce cambios rápidos
final debouncedSettings = settings.debounce(Duration(milliseconds: 300));

// Usar en widget
ValueListenableBuilder<String?>(
  valueListenable: themeOnly,
  builder: (context, theme, _) => Text('Theme: $theme'),
);
```

[Aprende más sobre operators →](/documentation/listen_it/operators/overview)

## Referencia de API

### Constructor

```dart
MapNotifier({
  Map<K, V>? data,
  CustomNotifierMode notificationMode = CustomNotifierMode.always,
  bool Function(V?, V?)? customEquality,
})
```

### Propiedades

| Propiedad | Tipo | Descripción |
|----------|------|-------------|
| `value` | `Map<K, V>` | Vista no modificable del map actual |
| `length` | `int` | Número de entradas |
| `keys` | `Iterable<K>` | Todas las claves |
| `values` | `Iterable<V>` | Todos los valores |
| `entries` | `Iterable<MapEntry<K, V>>` | Todas las entradas |
| `isEmpty` | `bool` | Si el map está vacío |
| `isNotEmpty` | `bool` | Si el map tiene entradas |

### Métodos

Todos los métodos estándar de `Map<K, V>` más:

| Método | Descripción |
|--------|-------------|
| `startTransAction()` | Comenzar transacción |
| `endTransAction()` | Terminar transacción y notificar |
| `notifyListeners()` | Notificar manualmente (útil con modo manual) |

## Errores Comunes

### 1. Modificar la Vista .value

```dart
// ❌️ No intentes modificar el getter .value
final view = map.value;
view['key'] = 'value';  // ¡Lanza UnsupportedError!

// ✅ Modificar a través del notifier
map['key'] = 'value';
```

### 2. Olvidar Transacciones

```dart
// ❌️ Muchas notificaciones
for (final entry in entries) {
  map[entry.key] = entry.value;
}

// ✅ Una sola notificación
map.startTransAction();
for (final entry in entries) {
  map[entry.key] = entry.value;
}
map.endTransAction();
```

### 3. No Manejar Valores Null

```dart
// ❌️ Puede lanzar error si el valor es null
final value = map['key'].toString();

// ✅ Manejar null de forma segura
final value = map['key']?.toString() ?? 'default';
```

## Próximos Pasos

- [ListNotifier →](/documentation/listen_it/collections/list_notifier)
- [SetNotifier →](/documentation/listen_it/collections/set_notifier)
- [Modos de Notificación →](/documentation/listen_it/collections/notification_modes)
- [Transacciones →](/documentation/listen_it/collections/transactions)
- [Volver a Colecciones →](/documentation/listen_it/collections/introduction)
