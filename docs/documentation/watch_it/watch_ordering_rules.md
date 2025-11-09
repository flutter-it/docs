# Watch Ordering Rules

## The Golden Rule

**All watch function calls must occur in the SAME ORDER on every build.**

This is the most important rule in watch_it. Violating it will cause errors or unexpected behavior.

## Why Does Order Matter?

watch_it uses a global state mechanism similar to React Hooks. Each watch call is assigned an index based on its position in the build sequence. When the widget rebuilds, watch_it expects to find the same watches in the same order.

**What happens if order changes:**
- ❌ Runtime errors
- ❌ Wrong data displayed
- ❌ Unexpected rebuilds
- ❌ Memory leaks

## Correct Pattern

✓ All watch calls happen in the same order every time:

<<< @/../code_samples/lib/watch_it/watch_ordering_good_example.dart#example

**Why this is correct:**
- Line 17: Always watches `todos`
- Line 20: Always watches `isLoading`
- Line 23-24: Always creates and watches `counter`
- Order never changes, even when data updates

## Common Violations

### ❌ Conditional Watch Calls

The most common mistake is putting watch calls inside conditional statements:

<<< @/../code_samples/lib/watch_it/watch_ordering_bad_example.dart#example

**Why this breaks:**
-When `show` is false: watches [showDetails, isLoading]
- When `show` is true: watches [showDetails, todos]
- Order changes = error!

### ❌ Watch Inside Loops

<<< @/../code_samples/lib/watch_it/watch_ordering_patterns.dart#watch_inside_loops_wrong

### ❌ Watch After Early Returns

<<< @/../code_samples/lib/watch_it/watch_ordering_patterns.dart#watch_after_early_return_wrong

### ❌ Watch in Callbacks

<<< @/../code_samples/lib/watch_it/watch_ordering_patterns.dart#watch_in_callbacks_wrong

## Safe Conditional Patterns

✓ Call ALL watches first, THEN use conditions:

<<< @/../code_samples/lib/watch_it/conditional_watch_safe_example.dart#example

**Pattern:**
1. Call all watch functions at the top of `build()`
2. THEN use conditional logic with the values
3. Order stays consistent

### Safe Pattern Examples

<<< @/../code_samples/lib/watch_it/watch_ordering_patterns.dart#safe_pattern_conditional

<<< @/../code_samples/lib/watch_it/watch_ordering_patterns.dart#safe_pattern_list_iteration

## Troubleshooting

### Error: "watch call order changed"

**Cause:** You have conditional watch calls or watches in different branches.

**Solution:**
1. Move all watch calls to the top of `build()`
2. Ensure they run unconditionally
3. Use the values conditionally, not the watches

### Error: "More/fewer watches than last build"

**Cause:** Number of watch calls changed between builds.

**Solution:**
- Check for watches inside `if` statements
- Check for watches inside loops
- Check for watches after early returns

### Unexpected Data

**Symptom:** Widget shows data from wrong source.

**Cause:** Watch order changed, so watch #2 is now receiving data meant for watch #3.

**Solution:** Fix the ordering to be consistent.

## Best Practices Checklist

✅ **DO:**
- Call all watches at the top of `build()`
- Use unconditional watch calls
- Store values in variables, use variables conditionally
- Watch the full list, iterate over values

❌ **DON'T:**
- Put watches in `if` statements
- Put watches in loops
- Put watches in callbacks
- Return early before all watches
- Change number of watches based on state

## Advanced: Why This Happens

watch_it uses a global `_watchItState` variable that tracks:
- Current widget being built
- Index of current watch call
- List of previous watch subscriptions

When you call `watch()`:
1. watch_it increments the index
2. Checks if subscription at that index exists
3. If yes, reuses it
4. If no, creates new subscription

If order changes:
- Index 0 expects subscription A, gets subscription B
- Subscriptions leak or get mixed up
- Everything breaks

This is similar to React Hooks rules for the same reason.

## See Also

- [Getting Started](/documentation/watch_it/getting_started.md) - Basic watch_it usage
- [Watch Functions](/documentation/watch_it/watch_functions.md) - All watch functions
- [Best Practices](/documentation/watch_it/best_practices.md) - General patterns
- [Debugging & Troubleshooting](/documentation/watch_it/debugging_tracing.md) - Common issues
