---
title: Best Practices
---

# Best Practices

Guidelines for using listen_it effectively and avoiding common pitfalls.

## Chain Lifecycle

### Eager Initialization with Persistent Subscriptions

Operator chains use eager initialization by default with persistent subscriptions:

1. **Chains subscribe to their source immediately** by default (eager initialization)
2. For memory optimization, pass `lazy: true` to delay subscription until first listener is added
3. **Once subscribed, chains stay subscribed** for efficiency, even when they have zero listeners
4. Chains maintain their subscription until explicitly disposed

::: danger Memory Leak Risk
Creating chains inline in build methods creates a **new chain on every rebuild**, each staying subscribed forever. This causes memory leaks!
:::

### Mixing Lazy and Eager in Chains

Each operator in a chain is independent. You can mix lazy and eager, but this can lead to confusing behavior:

```dart
final source = ValueNotifier<int>(5);
final eager = source.map((x) => x * 2);           // Default: eager
final lazy = eager.map((x) => x + 1, lazy: true); // Explicit: lazy

source.value = 7;
print(eager.value); // 14 ✓ (eager subscribed, updates immediately)
print(lazy.value);  // 11 ⚠️ (STALE! lazy not subscribed yet)

lazy.addListener(() {}); // Subscribe lazy to eager
print(lazy.value);  // 11 ⚠️ (STILL STALE! Doesn't retroactively update)

source.value = 10;
print(lazy.value);  // 21 ✓ (NOW updates on next change)
```

**Key behaviors:**

- **Eager → Lazy**: Eager part updates, lazy part can be stale until listener added
- **Lazy → Eager**: Eager subscribes to lazy immediately, which triggers lazy to initialize the whole chain
- **All eager (default)**: Entire chain subscribes immediately, `.value` always correct ✓
- **All lazy**: Chain doesn't subscribe until end gets a listener

::: warning Don't Mix
**Recommendation**: Don't mix. Use all-eager (default, simple) or all-lazy (memory optimization). Mixing can cause hard-to-debug stale values.
:::

### ❌ WRONG: Chains in Build Methods

Never create chains inline in build methods:

#### Build Method Inline

<<< @/../code_samples/lib/listen_it/chain_incorrect_pattern.dart#build_inline

#### ValueListenableBuilder Inline

<<< @/../code_samples/lib/listen_it/chain_incorrect_pattern.dart#valueListenableBuilder_inline

**Why this is wrong:**
- New chain created on **every rebuild**
- Each chain subscribes to source and **never unsubscribes**
- Multiple rebuilds = multiple leaked chains
- Memory usage grows indefinitely

### ✅ CORRECT: Create Chains Once

Create chains ensuring they're created only once. Here are three safe approaches:

<<< @/../code_samples/lib/listen_it/chain_correct_pattern.dart#example

**Why these work:**
- **Option 1**: Chain created once in `initState()` (not in constructor, which runs on every rebuild!)
- **Option 2**: `createOnce()` ensures chain is only created once even though it's in build
- **Option 3**: Chain lives in your data layer (recommended for larger apps)
- All options reuse the same chain object on every rebuild
- No memory leaks

::: warning Don't Create in Constructor
Never create chains in a StatelessWidget constructor or as field initializers - the constructor runs on **every rebuild**, causing the same memory leak as creating in build!
:::

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

### Understanding Chain Garbage Collection

**Key Finding**: Chains create circular references with their source, but Dart's garbage collector handles this correctly when the entire cycle becomes unreachable from GC roots.

**How it works**:
- Chains register as listeners on their source (immediately if eager, or when first listener is added if lazy)
- This creates a circular reference: `source → listener → chain → source`
- When the containing object (widget state, service, etc.) becomes unreachable, **the entire cycle is automatically garbage collected**
- No manual chain disposal needed in most cases!

### When Chain Disposal is NOT Needed

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

2. **Chain and source in different objects that both can be GC'd**
   ```dart
   class DataSource {
     final data = ValueNotifier<int>(0);
     void dispose() => data.dispose();
   }

   class DataProcessor {
     final DataSource source;
     late final processed = source.data.map((x) => x * 2);

     DataProcessor(this.source);

     // No chain disposal needed - when both DataProcessor AND DataSource
     // become unreachable, the entire cycle is GC'd automatically
   }
   ```

   **⚠️ CAREFUL**: This only works if **both objects** (the one owning the chain AND the one owning the source) can be garbage collected together. If the source is kept alive elsewhere (like in get_it), you must manually dispose the chain!

3. **Using watch_it** - automatic lifecycle management

**Why it's safe**: When the entire object graph (containing object + source + chain) becomes unreachable from GC roots, Dart's garbage collector traces reachability and collects everything in the cycle automatically.

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

### Exception: Long-Lived Sources

**⚠️ Only dispose chains manually if:**
- The source is registered in get_it or another service locator
- The source is kept alive longer than the chain should be
- You need to break the listener connection explicitly

```dart
class TemporaryViewModel {
  final globalSource = getIt<ValueNotifier<int>>(); // Long-lived source
  late final chain = globalSource.map((x) => x * 2);

  void dispose() {
    // Source stays alive in get_it, so manually remove chain listener
    (chain as ChangeNotifier).dispose();
  }
}
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
