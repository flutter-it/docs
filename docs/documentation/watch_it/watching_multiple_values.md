# Watching Multiple Values

When your widget needs data from multiple `ValueListenables`, you have several strategies to choose from. Each approach has different trade-offs in terms of code clarity, rebuild frequency, and performance.

## The Two Main Approaches

### Approach 1: Separate Watch Calls

Watch each value separately - widget rebuilds when **ANY** value changes:

<<< @/../code_samples/lib/watch_it/multiple_values_separate_watches.dart#example

**When to use:**
- ✅️️ Values are unrelated
- ✅️️ Simple UI logic
- ✅️️ All values are needed for rendering

**Rebuild behavior:** Widget rebuilds whenever **any** of the three values changes.

### Approach 2: Combining in Data Layer

Combine multiple values using `listen_it` operators in your manager - widget rebuilds only when the **combined result** changes:

<<< @/../code_samples/lib/watch_it/multiple_values_combine_latest_form.dart#manager

<<< @/../code_samples/lib/watch_it/multiple_values_combine_latest_form.dart#widget

**When to use:**
- ✅️️ Values are related/dependent
- ✅️️ Need computed result
- ✅️️ Want to reduce rebuilds
- ✅️️ Complex validation logic

**Rebuild behavior:** Widget rebuilds only when `isValid` changes, not when individual email or password values change (unless it affects validity).

## Pattern: Form Validation with combineLatest

One of the most common use cases for combining values is form validation:

**The Problem:** You want to enable a submit button only when ALL form fields are valid.

**Without combining:** Widget rebuilds on every keystroke in any field, even if validation state doesn't change.

**With combining:** Widget rebuilds only when the overall validation state changes (invalid → valid or vice versa).

See the form example above for the complete pattern.

## Pattern: Combining 3+ Values

For more than 2 values, use `combineLatest3`, `combineLatest4`, up to `combineLatest6`:

<<< @/../code_samples/lib/watch_it/multiple_values_combine_latest3_user.dart#manager

<<< @/../code_samples/lib/watch_it/multiple_values_combine_latest3_user.dart#widget

**Key benefit:** All three values (firstName, lastName, avatarUrl) can change independently, but the widget only rebuilds when the computed `UserDisplayData` object changes.

## Pattern: Using mergeWith for Event Sources

When you have multiple event sources of the **same type** that should trigger the same action, use `mergeWith`:

<<< @/../code_samples/lib/watch_it/multiple_values_merge_with_events.dart#manager

<<< @/../code_samples/lib/watch_it/multiple_values_merge_with_events.dart#widget

**Difference from combineLatest:**
- `combineLatest`: Combines **different types** into a new computed value
- `mergeWith`: Merges **same type** sources into one stream of events

## Comparison: When to Use Each Approach

Let's see both approaches side by side with the same Manager class:

<<< @/../code_samples/lib/watch_it/multiple_values_comparison_example.dart#manager

<<< @/../code_samples/lib/watch_it/multiple_values_comparison_example.dart#separate_watches

<<< @/../code_samples/lib/watch_it/multiple_values_comparison_example.dart#combined_watch

**Test it:** When you increment value1 from -1 to 0:
- `SeparateWatchesWidget` rebuilds (value changed)
- `CombinedWatchWidget` **doesn't rebuild** (both still not positive)

### Decision Table

| Scenario | Use Separate Watches | Use Combining |
|----------|---------------------|---------------|
| Unrelated values (name, email, avatar) | ✅️️ Simpler | ❌️️ Overkill |
| Computed result (firstName + lastName) | ❌️️ Rebuilds unnecessarily | ✅️️ Better |
| Form validation (all fields valid?) | ❌️️ Rebuilds on every keystroke | ✅️️ Much better |
| Independent values all needed in UI | ✅️️ Natural | ❌️️ More complex |
| Performance-sensitive with frequent changes | ❌️️ More rebuilds | ✅️️ Fewer rebuilds |

## watchIt() vs Multiple watchValue()

The choice between `watchIt()` on a `ChangeNotifier` and multiple `watchValue()` calls depends on your update patterns.

### Approach 1: watchIt() - Watch Entire ChangeNotifier

<<< @/../code_samples/lib/watch_it/multiple_values_watch_it_vs_watch_value.dart#watch_it_approach

**When to use:**
- ✅️️ You need **most/all** properties in your UI
- ✅️️ Properties are **updated together** (batched updates)
- ✅️️ Simple design - one notifyListeners() call updates everything

**Trade-off:** Widget rebuilds even if only one property changes.

### Approach 2: Multiple ValueNotifiers

<<< @/../code_samples/lib/watch_it/multiple_values_watch_it_vs_watch_value.dart#better_design

**When to use:**
- ✅️️ Properties update **independently** and **frequently**
- ✅️️ You only display a **subset** of properties in each widget
- ✅️️ Want granular control over rebuilds

**Trade-off:** If multiple properties update together, you get multiple rebuilds. In such cases:
- **Better: Use ChangeNotifier instead** and call `notifyListeners()` once after all updates
- **Alternative: Use `watchPropertyValue()`** to rebuild only when the specific property VALUE changes, not on every notifyListeners call

### Approach 3: watchPropertyValue() - Selective Updates

If you need to watch a ChangeNotifier but only care about specific property value changes:

```dart
class SettingsWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Only rebuilds when darkMode VALUE changes
    // (not on every notifyListeners call)
    final darkMode = watchPropertyValue((UserSettings s) => s.darkMode);

    return Switch(
      value: darkMode,
      onChanged: (value) => di<UserSettings>().setDarkMode(value),
    );
  }
}
```

**When to use:**
- ✅️️ ChangeNotifier has many properties
- ✅️️ You only need one or few properties
- ✅️️ Other properties change frequently but you don't care

**Key benefit:** Rebuilds only when `s.darkMode` **value** changes, ignoring notifications about other property changes.

## Safety: Automatic Caching in Selector Functions

::: tip Safe to Use Operators in Selectors
You can safely use `listen_it` operators like `combineLatest()` inside selector functions of `watchValue()`, `watchStream()`, `watchFuture()`, and other watch functions. The default `allowObservableChange: false` ensures the operator chain is created once and cached.
:::

<<< @/../code_samples/lib/watch_it/multiple_values_inline_combine_safe.dart#safe_inline_combine

**How it works (default `allowObservableChange: false`):**
1. First build: Selector runs, creates the `combineLatest()` chain
2. Result is cached automatically
3. Subsequent builds: Cached chain is reused
4. Exception thrown if observable identity changes
5. No memory leaks, no repeated chain creation

**When to set `allowObservableChange: true`:**
Only when the observable genuinely needs to change between builds:

<<< @/../code_samples/lib/watch_it/multiple_values_inline_combine_safe.dart#when_to_use_allow_change

**Important:** Setting `allowObservableChange: true` unnecessarily causes the selector to run on **every** build, creating new operator chains each time - a memory leak!

## Performance Considerations

### Rebuild Frequency

**Separate watches:**
```dart
final value1 = watchValue((M m) => m.value1);  // Rebuild on value1 change
final value2 = watchValue((M m) => m.value2);  // Rebuild on value2 change
final sum = value1 + value2;                    // Computed in build
```
- Rebuilds: 2 (one for each value change)
- Even if `sum` doesn't change!

**Combined watch:**
```dart
final sum = watchValue(
  (M m) => m.value1.combineLatest(m.value2, (v1, v2) => v1 + v2),
);
```
- Rebuilds: Only when `sum` actually changes
- Fewer rebuilds = better performance

### When Combining Actually Helps

Combining provides real benefits when:
1. **Values change frequently** but result changes rarely
2. **Complex computation** from multiple sources
3. **Validation** - many fields, binary result (valid/invalid)

Combining provides minimal benefit when:
1. All values are always needed in UI
2. Values rarely change
3. UI updates are cheap

## Common Mistakes

### ❌️️ Creating Operators Outside Selector

<<< @/../code_samples/lib/watch_it/multiple_values_antipatterns.dart#antipattern_create_outside_selector

**Problem:** Creates new chain on **every build** - memory leak!

**Solution:** Create inside selector:

<<< @/../code_samples/lib/watch_it/multiple_values_antipatterns.dart#correct_create_in_selector

### ❌️️ Using allowObservableChange Unnecessarily

<<< @/../code_samples/lib/watch_it/multiple_values_antipatterns.dart#antipattern_unnecessary_allow_change

**Problem:** Selector runs on every build, creating new chains.

**Solution:** Remove `allowObservableChange: true` unless actually needed.

### ❌️️ Using Getter for Combined Values

<<< @/../code_samples/lib/watch_it/multiple_values_antipatterns.dart#antipattern_create_in_data_layer

**Problem:** Getter creates new chain every access.

**Solution:** Use `late final` to create once.

## Key Takeaways

✅️️ **Separate watches** are simple and fine for unrelated values all needed in UI

✅️️ **Combining in data layer** reduces rebuilds when computing from multiple sources

✅️️ Use **`combineLatest()`** for dependent values with computed results

✅️️ Use **`mergeWith()`** for multiple event sources of same type

✅️️ **Safe to use operators in selectors** - automatic caching with default `allowObservableChange: false`

✅️️ **Never set `allowObservableChange: true`** unless observable genuinely changes

✅️️ **Create combined observables with `late final`** in managers, not getters

**Next:** Learn about [watching streams and futures](/documentation/watch_it/watching_streams_and_futures.md).

## See Also

- [More Watch Functions](/documentation/watch_it/more_watch_functions.md) - Individual watch function details
- [listen_it Operators](/documentation/listen_it/operators/overview.md) - Complete guide to combining operators
- [combineLatest Documentation](/documentation/listen_it/operators/combine.md) - Detailed combineLatest usage
- [Best Practices](/documentation/watch_it/best_practices.md) - Performance optimization patterns
