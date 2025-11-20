# Time Operators

Time-based operators control when values are propagated, helping you handle rapid changes and timing-sensitive operations.

## debounce()

Delays propagation of values until a pause occurs. Perfect for handling rapid user input like search fields.

::: tip Available on Both Types
`debounce()` works on both `ValueListenable<T>` (returns debounced values) and regular `Listenable` (just debounces notifications without values).
:::

### Basic Usage (ValueListenable)

<<< @/../code_samples/lib/listen_it/debounce_search.dart#example

### How It Works

`debounce()` creates a timer that resets on each value change. The value is only propagated when the timer completes without being reset:

```dart
final input = ValueNotifier<String>('');

final debounced = input.debounce(Duration(milliseconds: 500));

debounced.listen((value, _) => print('Debounced: $value'));

input.value = 'a';  // Timer starts
input.value = 'ab'; // Timer resets
input.value = 'abc'; // Timer resets
// ... 500ms pause ...
// Prints: "Debounced: abc" (only after pause)
```

### Common Use Cases

::: details Search Input

The most common use case - avoid excessive API calls while typing:

```dart
final searchTerm = ValueNotifier<String>('');

searchTerm
    .debounce(const Duration(milliseconds: 300))
    .where((term) => term.length >= 3)
    .listen((term, _) => performSearch(term));
```
:::

::: details Auto-Save

Save user input after they stop typing:

```dart
final documentContent = ValueNotifier<String>('');

documentContent
    .debounce(const Duration(seconds: 2))
    .listen((content, _) => autoSave(content));
```
:::

::: details Form Validation

Validate input after user stops typing:

```dart
final emailInput = ValueNotifier<String>('');

emailInput
    .debounce(const Duration(milliseconds: 500))
    .listen((email, _) => validateEmail(email));
```
:::

::: details Resize Handling

Handle window resize events without overwhelming the system:

```dart
final windowSize = ValueNotifier<Size>(Size.zero);

windowSize
    .debounce(const Duration(milliseconds: 200))
    .listen((size, _) => recalculateLayout(size));
```
:::

### Choosing the Right Duration

| Duration | Use Case |
|----------|----------|
| **100-200ms** | Fast feedback (e.g., live preview, instant search) |
| **300-500ms** | Standard user input (e.g., search, validation) |
| **1-2s** | Auto-save, background operations |
| **3-5s** | Heavy operations, network calls |

### Performance Benefits

Without debounce:
```dart
// User types "flutter" (7 keystrokes)
// Without debounce: 7 API calls!
searchInput.listen((term, _) => searchApi(term));

// Calls: 'f', 'fl', 'flu', 'flut', 'flutt', 'flutte', 'flutter'
```

With debounce:
```dart
// User types "flutter" (7 keystrokes)
// With debounce: 1 API call!
searchInput
    .debounce(Duration(milliseconds: 300))
    .listen((term, _) => searchApi(term));

// Only calls once with: 'flutter'
```

### Using with Regular Listenable

For regular `Listenable` (not `ValueListenable`), `debounce()` delays notifications without tracking values:

```dart
final notifier = ChangeNotifier();

final debounced = notifier.debounce(Duration(milliseconds: 500));

debounced.listen((_) {
  print('Debounced notification!');
});

// Rapid notifications
notifier.notifyListeners();
notifier.notifyListeners();
notifier.notifyListeners();

// Only one notification after 500ms pause
```

This is useful when you have a `ChangeNotifier` or custom `Listenable` and want to reduce the frequency of notifications without needing to track specific values.

### Chaining with Other Operators

Debounce works great in operator chains:

```dart
final searchInput = ValueNotifier<String>('');

searchInput
    .debounce(Duration(milliseconds: 300))  // Wait for typing pause
    .where((term) => term.length >= 3)       // Minimum length
    .map((term) => term.trim())              // Clean up
    .listen((term, _) => performSearch(term));
```

### Caveats

::: warning setState and debounce
Using `debounce()` inside a widget's build method with `setState` can cause issues because the debounce creates a new chain object on each rebuild, losing the timer state.

**❌️ DON'T:**
```dart
Widget build(BuildContext context) {
  return ValueListenableBuilder(
    valueListenable: input.debounce(Duration(milliseconds: 300)), // NEW DEBOUNCE EACH BUILD!
    builder: (context, value, _) => Text(value),
  );
}
```

**✅ BETTER: Create chain outside build**
```dart
// Create debounced chain as field
late final debounced = input.debounce(Duration(milliseconds: 300));

Widget build(BuildContext context) {
  return ValueListenableBuilder(
    valueListenable: debounced, // Same debounce every build
    builder: (context, value, _) => Text(value),
  );
}
```

**✅ BEST: Use watch_it with get_it**
```dart
class SearchWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // watch_it caches the chain automatically when using watchValue
    final debouncedTerm = watchValue(
      (SearchModel m) => m.searchTerm
          .debounce(Duration(milliseconds: 300))
          .where((term) => term.length >= 3)
    );

    return Text('Search: $debouncedTerm');
  }
}

// Register SearchModel in get_it
class SearchModel {
  final searchTerm = ValueNotifier<String>('');
}
```
:::

### When to Use debounce()

Use `debounce()` when:
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ You have rapid value changes (user typing, scrolling, resizing)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ You want to reduce API calls or expensive operations</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ You only care about the "final" value after changes stop</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ You're implementing search, auto-save, or validation</li>
</ul>

## async()

Defers updates to the next frame, preventing "setState called during build" errors.

### Basic Usage

```dart
final source = ValueNotifier<int>(0);

final asyncSource = source.async();

// Updates are deferred to next frame
asyncSource.listen((value, _) => setState(() => _data = value));
```

### How It Works

`async()` uses `scheduleMicrotask()` to defer the notification until after the current frame completes. This prevents issues when setting state during widget builds.

### When to Use async()

Use `async()` when:
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ You need to call `setState()` from a listener</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ You're getting "setState called during build" errors</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ You want to batch multiple synchronous changes</li>
</ul>

::: tip
In most cases, using watch_it is a better solution than `async()`. watch_it handles state updates automatically without requiring async deferral.
:::

## Real-World Example

Complete search implementation with debounce:

```dart
class SearchViewModel {
  final searchTerm = ValueNotifier<String>('');
  final results = ListNotifier<SearchResult>();
  final isSearching = ValueNotifier<bool>(false);

  SearchViewModel() {
    searchTerm
        .debounce(Duration(milliseconds: 300))
        .where((term) => term.length >= 3)
        .listen((term, _) => _performSearch(term));
  }

  Future<void> _performSearch(String term) async {
    isSearching.value = true;
    try {
      final apiResults = await searchApi(term);
      results.startTransAction();
      results.clear();
      results.addAll(apiResults);
      results.endTransAction();
    } finally {
      isSearching.value = false;
    }
  }
}
```

## Next Steps

- [Learn about transformation operators →](/documentation/listen_it/operators/transform)
- [Learn about filtering operators →](/documentation/listen_it/operators/filter)
- [Learn about combining operators →](/documentation/listen_it/operators/combine)
- [Read best practices guide →](/documentation/listen_it/best_practices)
