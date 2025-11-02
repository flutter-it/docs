---
title: Best Practices
---

# Best Practices

Guidelines for using listen_it effectively and avoiding common pitfalls.

## Chain Lifecycle

### The Hot Subscription Model

Operator chains use a "hot" subscription model:

1. Chains don't subscribe to their source until a listener is added (lazy initialization)
2. **Once subscribed, chains stay subscribed** even when they have zero listeners
3. Chains maintain their subscription until explicitly disposed

::: danger Memory Leak Risk
Creating chains inline in build methods creates a **new chain on every rebuild**, each staying subscribed forever. This causes memory leaks!
:::

### ❌ WRONG: Chains in Build Methods

Never create chains inline in build methods:

#### ValueListenableBuilder Inline

<<< @/../code_samples/lib/listen_it/chain_incorrect_pattern.dart#valueListenableBuilder_inline

#### Builder Function Inline

<<< @/../code_samples/lib/listen_it/chain_incorrect_pattern.dart#builder_inline

#### StatefulWidget Build

<<< @/../code_samples/lib/listen_it/chain_incorrect_pattern.dart#stateful_build

**Why this is wrong:**
- New chain created on **every rebuild**
- Each chain subscribes to source and **never unsubscribes**
- Multiple rebuilds = multiple leaked chains
- Memory usage grows indefinitely

### ✅ CORRECT: Create Chains Once

Create chains outside build methods, ensuring they're created only once:

<<< @/../code_samples/lib/listen_it/chain_correct_pattern.dart#example

**Why this works:**
- Chain created **once** (in constructor or as late final field)
- Same chain object reused on every rebuild
- No memory leaks
- Proper lifecycle management

### ✅ RECOMMENDED: Use watch_it

The safest approach is using watch_it v2.0+, which provides automatic selector caching:

<<< @/../code_samples/lib/listen_it/chain_watch_it_safe.dart#watchValue_safe

**Why watch_it is best:**
- Default `allowObservableChange: false` caches the selector
- Chain created only once, even though it's inline
- No manual lifecycle management needed
- Clean, concise code

[Learn more about watch_it →](/documentation/watch_it/getting_started)

## Disposal

### When to Dispose Chains

Operator chains implement `ChangeNotifier` and **must be disposed** when no longer needed:

- ✅ **StatefulWidget**: Dispose in `dispose()` method
- ✅ **Model classes**: Dispose in model's `dispose()` method
- ✅ **Manual subscriptions**: Cancel subscription and dispose chain
- ❌ **StatelessWidget**: Can't dispose (use watch_it or move chain outside widget)
- ❌ **watch_it**: Automatic disposal (don't manually dispose)

### StatefulWidget Disposal

<<< @/../code_samples/lib/listen_it/chain_disposal.dart#stateful_disposal

### Model Class Disposal

<<< @/../code_samples/lib/listen_it/chain_disposal.dart#model_disposal

### Subscription Disposal

<<< @/../code_samples/lib/listen_it/chain_disposal.dart#subscription_disposal

## Reactive Collections Best Practices

### Choose the Right Notification Mode

**CustomNotifierMode.always** (default):
- Notifies on every operation, even if value doesn't change
- Use when you haven't overridden `==` operator
- Prevents UI confusion when setting "same" value

**CustomNotifierMode.normal**:
- Only notifies when value actually changes (uses `==` comparison)
- Use when you've implemented proper equality (`==` operator)
- More efficient (fewer notifications)

**CustomNotifierMode.manual**:
- No automatic notifications
- You must call `notifyListeners()` manually
- Use for complex update scenarios

```dart
// Default: always mode (safest)
final items = ListNotifier<String>(data: []);

// Normal mode: only on changes
final items = ListNotifier<String>(
  data: [],
  notificationMode: CustomNotifierMode.normal,
);

// Manual mode: explicit control
final items = ListNotifier<String>(
  data: [],
  notificationMode: CustomNotifierMode.manual,
);
items.add('item');
items.notifyListeners(); // Explicit notification
```

### Use Transactions for Bulk Operations

Batch multiple operations into a single notification:

```dart
final items = ListNotifier<String>(data: []);

// ❌ WITHOUT transaction: 3 notifications
items.add('item1');
items.add('item2');
items.add('item3');

// ✅ WITH transaction: 1 notification
items.startTransAction();
items.add('item1');
items.add('item2');
items.add('item3');
items.endTransAction();
```

### Access Immutable Values

The `.value` getter returns an **unmodifiable view**:

```dart
final items = ListNotifier<String>(data: ['one']);

// ✅ CORRECT: Use collection methods
items.add('two');
items.removeAt(0);

// ❌ WRONG: Don't modify .value directly
items.value.add('three'); // Throws UnsupportedError!
```

## Operator Chain Best Practices

### Keep Chains Readable

Long chains are powerful but can become hard to read. Consider breaking them up:

```dart
// ❌ Hard to read
final result = source
  .where((x) => x.isNotEmpty)
  .map((x) => x.trim())
  .select<int>((x) => x.length)
  .debounce(Duration(milliseconds: 300))
  .where((len) => len > 3)
  .map((len) => len.toString());

// ✅ Better: Break into logical steps with descriptive names
final nonEmpty = source.where((x) => x.isNotEmpty);
final trimmed = nonEmpty.map((x) => x.trim());
final length = trimmed.select<int>((x) => x.length);
final debounced = length.debounce(Duration(milliseconds: 300));
final filtered = debounced.where((len) => len > 3);
final display = filtered.map((len) => len.toString());
```

### Use select() for Object Properties

When working with objects, use `select()` to react only when specific properties change:

```dart
final user = ValueNotifier(User(name: 'John', age: 25));

// ❌ INEFFICIENT: Notifies on ANY user change
final name = user.map((u) => u.name);

// ✅ BETTER: Only notifies when name actually changes
final name = user.select<String>((u) => u.name);
```

### Prefer where() Over Conditional Logic

Filter at the source rather than in the handler:

```dart
final input = ValueNotifier<String>('');

// ❌ Less efficient: All updates reach handler
input.listen((value, _) {
  if (value.length >= 3) {
    search(value);
  }
});

// ✅ Better: Filter updates before they reach handler
input
  .where((term) => term.length >= 3)
  .listen((value, _) => search(value));
```

## Testing Best Practices

### Test Operator Chains

```dart
test('map operator transforms values', () {
  final source = ValueNotifier<int>(5);
  final chain = source.map((x) => x * 2);

  expect(chain.value, 10);

  source.value = 3;
  expect(chain.value, 6);

  // Clean up
  (chain as ChangeNotifier).dispose();
});
```

### Test Reactive Collections

```dart
test('ListNotifier notifies on add', () {
  final items = ListNotifier<String>(data: []);
  final notifications = <List<String>>[];

  items.listen((list, _) => notifications.add(List.from(list)));

  items.add('item1');
  items.add('item2');

  expect(notifications, [
    ['item1'],
    ['item1', 'item2'],
  ]);
});
```

### Clean Up in Tests

Always dispose chains in tests to prevent memory leaks:

```dart
test('example test', () {
  final source = ValueNotifier<int>(0);
  final chain = source.map((x) => x * 2);

  // ... test code ...

  // Clean up
  (chain as ChangeNotifier).dispose();
  source.dispose();
});
```

## Performance Tips

### Avoid Excessive Debouncing

Only debounce when necessary (user input, rapid changes):

```dart
// ✅ GOOD: Debounce user input
searchTerm
  .debounce(Duration(milliseconds: 300))
  .listen((term, _) => search(term));

// ❌ UNNECESSARY: Debouncing infrequent updates
userProfile
  .debounce(Duration(seconds: 1)) // Profile changes rarely
  .listen((profile, _) => updateUI(profile));
```

### Use Transactions for Collections

Batch operations to reduce notification overhead:

```dart
// ❌ INEFFICIENT: 1000 notifications
for (var i = 0; i < 1000; i++) {
  items.add(i);
}

// ✅ EFFICIENT: 1 notification
items.startTransAction();
for (var i = 0; i < 1000; i++) {
  items.add(i);
}
items.endTransAction();
```

### Profile Your Chains

If performance is critical, measure:

```dart
final stopwatch = Stopwatch()..start();
chain.listen((value, _) {
  print('Update took: ${stopwatch.elapsedMicroseconds}μs');
  stopwatch.reset();
});
```

## Common Pitfalls

### 1. Forgetting to Dispose

```dart
// ❌ WRONG: Chain never disposed
class MyWidget extends StatefulWidget {
  // ... chain created in initState but never disposed
}

// ✅ CORRECT: Always dispose
@override
void dispose() {
  if (chain is ChangeNotifier) {
    (chain as ChangeNotifier).dispose();
  }
  super.dispose();
}
```

### 2. Creating Chains in Build

```dart
// ❌ WRONG: New chain every build
Widget build(BuildContext context) {
  return ValueListenableBuilder(
    valueListenable: source.map((x) => x * 2), // LEAK!
    builder: (context, value, _) => Text('$value'),
  );
}

// ✅ CORRECT: Use watch_it or create chain once
late final chain = source.map((x) => x * 2);
```

### 3. Modifying Collection .value Directly

```dart
// ❌ WRONG: Throws error
items.value.add('new'); // UnsupportedError!

// ✅ CORRECT: Use collection methods
items.add('new');
```

### 4. Not Using select() for Objects

```dart
final user = ValueNotifier(User(name: 'John', age: 25));

// ❌ INEFFICIENT: Notifies even when name doesn't change
user.map((u) => u.name).listen((name, _) => print(name));

// ✅ EFFICIENT: Only notifies when name changes
user.select<String>((u) => u.name).listen((name, _) => print(name));
```

## Summary

**Key takeaways:**

1. ✅ **Never create chains in build methods** (or use watch_it for automatic caching)
2. ✅ **Always dispose chains** when done (except with watch_it)
3. ✅ **Use transactions** for bulk collection operations
4. ✅ **Use select()** when reacting to object properties
5. ✅ **Prefer where()** over conditional logic in handlers
6. ✅ **Choose the right notification mode** for collections
7. ✅ **Test your chains** and clean up in tests

**Recommended approach:**
- Use **watch_it** for widgets (automatic lifecycle management)
- Use **model classes** for business logic (manual disposal)
- Use **transactions** for bulk updates
- Use **select()** for object properties

## Next Steps

- [Learn about operator details →](/documentation/listen_it/operators/overview)
- [Learn about collections →](/documentation/listen_it/collections/introduction)
- [See examples →](/examples/listen_it/listen_it)
- [Join Discord for help →](https://discord.gg/ZHYHYCM38h)
