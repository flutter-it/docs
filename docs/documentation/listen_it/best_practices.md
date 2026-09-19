---
title: Best Practices
---

# Best Practices

Guidelines for using listen_it effectively and avoiding common pitfalls.

## Chain Lifecycle

### Attach, Detach and Derived Values (v6.0.0+)

An operator chain (`source.map(...)`, `a.combineLatest(b, ...)`, ...) follows this lifecycle:

1. **Attach** - the chain subscribes to its source(s) when it is created (default) or, with `lazy: true`, when it gets its first listener
2. **Detach** - when the *last* listener is removed, the chain unsubscribes from its source(s). In a longer chain this cascades down to the original source
3. **Re-attach** - the next `addListener` subscribes again and refreshes the stored value *before* the new listener is registered, so nothing is missed and no spurious notification is sent

While a chain is detached its `.value` is **derived from the current source value on read**, so it is never stale:

```dart
final source = ValueNotifier<int>(1);
final doubled = source.map((x) => x * 2);

void listener() {}
doubled.addListener(listener);
doubled.removeListener(listener); // last listener gone -> detached

source.value = 5;
print(doubled.value); // 10 ✅ derived on read, no subscription needed

doubled.addListener(listener); // re-attached, value already fresh
```

| Operator | `.value` while detached |
|---|---|
| `map`, `select` | transform / selector applied to the current source value |
| `where` | current source value if it passes the filter, otherwise the last passing value |
| `debounce`, `async` | current source value |
| `combineLatest` | combiner applied to the current source values |
| `mergeWith` | last received value (it can't know which source changed last) |

::: warning Keep Transformations Pure
Because the transformation may run on read while detached, transformation functions must be pure - no side effects, same input → same output.
:::

### lazy: true

`lazy: true` only changes step 1: the first subscription happens on the first listener instead of on creation. Before that, `.value` is derived on read exactly as for a detached chain, so `lazy: true` is a pure memory optimisation with no stale-value trade-off. Mixing lazy and eager operators in one chain is fine.

```dart
final source = ValueNotifier<int>(5);
final eager = source.map((x) => x * 2);           // attached on creation
final lazy = eager.map((x) => x + 1, lazy: true); // attaches on first listener

source.value = 7;
print(eager.value); // 14 ✅
print(lazy.value);  // 15 ✅ derived on read
```

### ❌️️ WRONG: Chains in Build Methods

Don't create chains inline in build methods:

#### Build Method Inline

<<< @/../code_samples/lib/listen_it/chain_incorrect_pattern.dart#build_inline

#### ValueListenableBuilder Inline

<<< @/../code_samples/lib/listen_it/chain_incorrect_pattern.dart#valueListenableBuilder_inline

**Why this is wrong:**
- A new chain object is created on **every rebuild**
- Each chain attaches to the source and does work until it is discarded
- It is wasteful and makes the widget's behaviour depend on rebuild timing

Since v6.0.0 this is no longer a memory *leak* - a discarded chain detaches from the source as soon as its listeners are gone (or, if nobody ever listened to it, on the first notification it receives). It is still the wrong pattern.

### ✅ CORRECT: Create Chains Once

Create chains ensuring they're created only once. Here are three safe approaches:

<<< @/../code_samples/lib/listen_it/chain_correct_pattern.dart#example

**Why these work:**
- **Option 1**: Chain created once in `initState()` (not in constructor, which runs on every rebuild!)
- **Option 2**: `createOnce()` ensures chain is only created once even though it's in build
- **Option 3**: Chain lives in your data layer (recommended for larger apps)
- All options reuse the same chain object on every rebuild

::: warning Don't Create in Constructor
Never create chains in a StatelessWidget constructor or as field initializers - the constructor runs on **every rebuild**, which is the same problem as creating in build!
:::

### ✅ RECOMMENDED: Use watch_it

The safest approach is using watch_it, which caches the selector and unsubscribes when the widget is disposed:

<<< @/../code_samples/lib/listen_it/chain_watch_it_safe.dart#watchValue_safe

**Why watch_it is best:**
- Default `allowObservableChange: false` caches the selector, so the chain is created only once per widget instance
- When the widget is disposed, watch_it removes its listener and the chain detaches from `m.source`
- No manual lifecycle management needed
- Clean, concise code

[Learn more about watch_it →](/documentation/watch_it/getting_started)

## Disposal

### Chains Usually Don't Need Disposal

A chain without listeners holds no subscription on its source, so it is garbage collected as soon as nothing references it any more. And when the whole graph (source + chain) becomes unreachable, Dart's GC collects it regardless of subscriptions.

**✅ You DON'T need to dispose chains when:**

1. **The source is owned by the same object as the chain**
   ```dart
   class CounterService {
     final source = ValueNotifier<int>(0);
     late final doubled = source.map((x) => x * 2);

     void dispose() {
       source.dispose(); // Only dispose source
       // Chain is GC'd automatically when service becomes unreachable
     }
   }
   ```

2. **The source outlives the chain** (e.g. it is registered in get_it) - once the chain's listeners are gone it detaches from the source, so a discarded chain doesn't keep the source busy
   ```dart
   class TemporaryViewModel {
     final globalSource = getIt<ValueNotifier<int>>(); // Long-lived source
     late final chain = globalSource.map((x) => x * 2);

     // No chain disposal needed: when the widget that watched `chain`
     // is disposed, the chain loses its last listener and detaches
   }
   ```

3. **Using watch_it** - automatic lifecycle management

### When You SHOULD Dispose the Source

**✅ Always dispose the source ValueNotifier to:**
- Stop handlers from being called
- Free resources held by the source
- Follow proper resource management

```dart
class MyService {
  final counter = ValueNotifier<int>(0);
  late final doubled = counter.map((x) => x * 2);

  void dispose() {
    counter.dispose(); // Stops notifications and frees resources
  }
}
```

### When to Dispose a Chain Explicitly

Call `dispose()` on a chain only when:
- You want to end it explicitly **while it still has listeners**
- You want to be sure a pending `debounce` timer or `async` update is cancelled

```dart
(chain as ChangeNotifier).dispose();
```

### Subscription Disposal

Always cancel subscriptions created with `.listen()`:

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

// ❌️ WITHOUT transaction: 3 notifications
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

// ❌️ WRONG: Don't modify .value directly
items.value.add('three'); // Throws UnsupportedError!
```

## Operator Chain Best Practices

### Keep Chains Readable

Long chains are powerful but can become hard to read. Consider breaking them up:

```dart
// ❌️ Hard to read
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

// ❌️ INEFFICIENT: Notifies on ANY user change
final name = user.map((u) => u.name);

// ✅ BETTER: Only notifies when name actually changes
final name = user.select<String>((u) => u.name);
```

### Prefer where() Over Conditional Logic

Filter at the source rather than in the handler:

```dart
final input = ValueNotifier<String>('');

// ❌️ Less efficient: All updates reach handler
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

Dispose the source in tests; dispose the chain too if it uses `debounce()` or `async()` so no timer outlives the test:

```dart
test('example test', () {
  final source = ValueNotifier<int>(0);
  final chain = source.debounce(Duration(milliseconds: 100));

  // ... test code ...

  // Clean up
  (chain as ChangeNotifier).dispose(); // cancels the pending timer
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

// ❌️ UNNECESSARY: Debouncing infrequent updates
userProfile
  .debounce(Duration(seconds: 1)) // Profile changes rarely
  .listen((profile, _) => updateUI(profile));
```

### Use Transactions for Collections

Batch operations to reduce notification overhead:

```dart
// ❌️ INEFFICIENT: 1000 notifications
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

### 1. Creating Chains in Build

```dart
// ❌️ WRONG: New chain every build
Widget build(BuildContext context) {
  return ValueListenableBuilder(
    valueListenable: source.map((x) => x * 2), // NEW CHAIN EVERY REBUILD!
    builder: (context, value, _) => Text('$value'),
  );
}

// ✅ CORRECT: Use watch_it or create chain once
late final chain = source.map((x) => x * 2);
```

### 2. Side Effects in Transformations

```dart
// ❌️ WRONG: The transform may run on read while the chain is detached
final logged = source.map((x) {
  analytics.track('value', x); // side effect!
  return x * 2;
});

// ✅ CORRECT: Keep transforms pure, do side effects in listen()
final doubled = source.map((x) => x * 2);
doubled.listen((x, _) => analytics.track('value', x));
```

### 3. Modifying Collection .value Directly

```dart
// ❌️ WRONG: Throws error
items.value.add('new'); // UnsupportedError!

// ✅ CORRECT: Use collection methods
items.add('new');
```

### 4. Not Using select() for Objects

```dart
final user = ValueNotifier(User(name: 'John', age: 25));

// ❌️ INEFFICIENT: Notifies even when name doesn't change
user.map((u) => u.name).listen((name, _) => print(name));

// ✅ EFFICIENT: Only notifies when name changes
user.select<String>((u) => u.name).listen((name, _) => print(name));
```

## Summary

**Key takeaways:**

1. ✅ **Never create chains in build methods** (or use watch_it for automatic caching)
2. ✅ **Keep transformation functions pure** - they may run on read while a chain is detached
3. ✅ **Use transactions** for bulk collection operations
4. ✅ **Use select()** when reacting to object properties
5. ✅ **Prefer where()** over conditional logic in handlers
6. ✅ **Choose the right notification mode** for collections
7. ✅ **Test your chains** and clean up in tests

**Recommended approach:**
- Use **watch_it** for widgets (automatic lifecycle management)
- Use **model classes** for business logic (dispose the source, not the chains)
- Use **transactions** for bulk updates
- Use **select()** for object properties

## Next Steps

- [Learn about operator details →](/documentation/listen_it/operators/overview)
- [Learn about collections →](/documentation/listen_it/collections/introduction)
- [See examples →](/examples/listen_it/listen_it)
- [Join Discord for help →](https://discord.com/invite/Nn6GkYjzW)
