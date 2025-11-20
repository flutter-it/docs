# MapNotifier

A reactive Map that automatically notifies listeners when its contents change.

## Overview

`MapNotifier<K, V>` is a reactive map implementation that:
- Extends the standard Dart `Map<K, V>` interface
- Implements `ValueListenable<Map<K, V>>`
- Automatically notifies listeners on mutations
- Supports transactions for batching operations
- Provides configurable notification modes

## Basic Usage

```dart
final preferences = MapNotifier<String, dynamic>(
  data: {'theme': 'dark', 'fontSize': 14},
);

preferences.listen((map, _) => print('Preferences: $map'));

preferences['theme'] = 'light';  // ✅ Notifies
preferences['fontSize'] = 16;    // ✅ Notifies
```

## Creating a MapNotifier

### Empty Map

```dart
final cache = MapNotifier<String, User>();
```

### With Initial Data

```dart
final settings = MapNotifier<String, dynamic>(
  data: {
    'theme': 'dark',
    'language': 'en',
    'notifications': true,
  },
);
```

### With Notification Mode

```dart
final cache = MapNotifier<String, User>(
  notificationMode: CustomNotifierMode.normal,
);
```

### With Custom Equality

```dart
class Config {
  final String value;
  Config(this.value);
}

final configs = MapNotifier<String, Config>(
  notificationMode: CustomNotifierMode.normal,
  customEquality: (a, b) => a?.value == b?.value,  // Compare by value field
);
```

## Standard Map Operations

MapNotifier supports all standard Map operations with automatic notifications:

### Adding/Updating Entries

```dart
final map = MapNotifier<String, int>();

map['key1'] = 1;                    // Add/update single entry
map.addAll({'key2': 2, 'key3': 3}); // Add multiple entries
map.addEntries([
  MapEntry('key4', 4),
  MapEntry('key5', 5),
]);                                 // Add entries from iterable
map.putIfAbsent('key6', () => 6);   // Add if not present
```

### Removing Entries

```dart
map.remove('key1');                 // Remove by key
map.removeWhere((k, v) => v > 3);   // Remove conditionally
map.clear();                        // Remove all entries
```

### Updating Values

```dart
map.update('key1', (value) => value + 1);  // Update existing
map.update('key1', (v) => v + 1, ifAbsent: () => 1);  // Update or add
map.updateAll((k, v) => v * 2);            // Update all values
```

## Integration with Flutter

### With ValueListenableBuilder

<<< @/../code_samples/lib/listen_it/map_notifier_widget.dart#example

### With watch_it

<<< @/../code_samples/lib/listen_it/map_notifier_watch_it.dart#example

## Notification Modes

MapNotifier supports three notification modes:

### always (Default)

```dart
final map = MapNotifier<String, int>(
  data: {'count': 0},
  notificationMode: CustomNotifierMode.always,
);

map['count'] = 0;     // ✅ Notifies (even though value unchanged)
map.remove('missing'); // ✅ Notifies (even though key doesn't exist)
```

### normal

```dart
final map = MapNotifier<String, int>(
  data: {'count': 0},
  notificationMode: CustomNotifierMode.normal,
);

map['count'] = 0;     // ❌️ No notification (value unchanged)
map['count'] = 1;     // ✅ Notifies (value changed)
map.remove('missing'); // ❌️ No notification (key doesn't exist)
```

### manual

```dart
final map = MapNotifier<String, int>(
  notificationMode: CustomNotifierMode.manual,
);

map['key1'] = 1;  // No notification
map['key2'] = 2;  // No notification
map.notifyListeners();  // ✅ Manual notification
```

[Learn more about notification modes →](/documentation/listen_it/collections/notification_modes)

## Transactions

Batch multiple operations into a single notification:

```dart
final settings = MapNotifier<String, dynamic>();

settings.startTransAction();
settings['theme'] = 'dark';
settings['fontSize'] = 14;
settings['language'] = 'en';
settings.endTransAction();  // Single notification
```

[Learn more about transactions →](/documentation/listen_it/collections/transactions)

## Immutable Value

The `.value` getter returns an unmodifiable view:

```dart
final map = MapNotifier<String, int>(data: {'a': 1, 'b': 2});

final immutableView = map.value;
print(immutableView);  // {a: 1, b: 2}

// ❌️ Throws UnsupportedError
// immutableView['c'] = 3;

// ✅ Mutate through the notifier
map['c'] = 3;  // Works and notifies
```

This ensures all mutations go through the notification system.

## Bulk Operations Behavior

MapNotifier bulk operations **always notify** (even with empty input) in all modes except manual:

```dart
final map = MapNotifier<String, int>(
  notificationMode: CustomNotifierMode.normal,
);

map.addAll({});          // ✅ Notifies (even though empty)
map.addEntries([]);      // ✅ Notifies (even though empty)
```

**Why?** For performance reasons - to avoid comparing all elements. These operations are typically used for bulk loading data.

## Use Cases

::: details User Preferences

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

::: details Cache Management

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

::: details Form Data

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

::: details Configuration Manager

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

## Performance Considerations

### Memory

MapNotifier has minimal overhead compared to a regular Map:
- Extends `DelegatingMap` (from package:collection)
- Adds notification mechanism from `ChangeNotifier`
- Small overhead for notification mode and transaction flags

### Notifications

Each mutation triggers a notification (unless in transaction or manual mode):
- **Cost:** O(n) where n = number of listeners
- **Optimization:** Use transactions for bulk operations
- **Best practice:** Keep listener count reasonable (< 50)

### Large Maps

For very large maps (1000+ entries):
- Consider splitting into multiple smaller maps by category
- Use transactions when adding/removing many entries
- Consider `normal` mode if you have many no-op operations

```dart
// ❌️ Bad: 1000 notifications
for (final entry in entries) {
  map[entry.key] = entry.value;
}

// ✅ Good: 1 notification
map.startTransAction();
for (final entry in entries) {
  map[entry.key] = entry.value;
}
map.endTransAction();

// ✅ Even better: addAll
map.startTransAction();
map.addAll(Map.fromEntries(entries));
map.endTransAction();
```

## Combining with Operators

You can chain listen_it operators on a MapNotifier:

```dart
final settings = MapNotifier<String, dynamic>();

// React only when specific key changes
final themeOnly = settings.select<String?>((map) => map['theme']);

// Filter to non-empty maps
final hasSettings = settings.where((map) => map.isNotEmpty);

// Debounce rapid changes
final debouncedSettings = settings.debounce(Duration(milliseconds: 300));

// Use in widget
ValueListenableBuilder<String?>(
  valueListenable: themeOnly,
  builder: (context, theme, _) => Text('Theme: $theme'),
);
```

[Learn more about operators →](/documentation/listen_it/operators/overview)

## API Reference

### Constructor

```dart
MapNotifier({
  Map<K, V>? data,
  CustomNotifierMode notificationMode = CustomNotifierMode.always,
  bool Function(V?, V?)? customEquality,
})
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `value` | `Map<K, V>` | Unmodifiable view of current map |
| `length` | `int` | Number of entries |
| `keys` | `Iterable<K>` | All keys |
| `values` | `Iterable<V>` | All values |
| `entries` | `Iterable<MapEntry<K, V>>` | All entries |
| `isEmpty` | `bool` | Whether map is empty |
| `isNotEmpty` | `bool` | Whether map has entries |

### Methods

All standard `Map<K, V>` methods plus:

| Method | Description |
|--------|-------------|
| `startTransAction()` | Begin transaction |
| `endTransAction()` | End transaction and notify |
| `notifyListeners()` | Manually notify (useful with manual mode) |

## Common Pitfalls

### 1. Modifying the .value View

```dart
// ❌️ Don't try to modify the .value getter
final view = map.value;
view['key'] = 'value';  // Throws UnsupportedError!

// ✅ Modify through the notifier
map['key'] = 'value';
```

### 2. Forgetting Transactions

```dart
// ❌️ Many notifications
for (final entry in entries) {
  map[entry.key] = entry.value;
}

// ✅ Single notification
map.startTransAction();
for (final entry in entries) {
  map[entry.key] = entry.value;
}
map.endTransAction();
```

### 3. Not Handling Null Values

```dart
// ❌️ May throw if value is null
final value = map['key'].toString();

// ✅ Handle null safely
final value = map['key']?.toString() ?? 'default';
```

## Next Steps

- [ListNotifier →](/documentation/listen_it/collections/list_notifier)
- [SetNotifier →](/documentation/listen_it/collections/set_notifier)
- [Notification Modes →](/documentation/listen_it/collections/notification_modes)
- [Transactions →](/documentation/listen_it/collections/transactions)
- [Back to Collections →](/documentation/listen_it/collections/introduction)
