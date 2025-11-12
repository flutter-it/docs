# Watching Streams & Futures

You've learned to watch synchronous data. Now let's handle async data with Streams and Futures.

## Why Special Functions?

Streams and Futures are different from `Listenable`:
- **Stream** - Emits multiple values over time
- **Future** - Completes once with a value
- Both have loading/error states

watch_it provides `watchStream()` and `watchFuture()` - like `StreamBuilder` and `FutureBuilder`, but in one line.

## watchStream - Reactive Streams

Replace `StreamBuilder` with `watchStream()`:

<<< @/../code_samples/lib/watch_it/chat_watch_stream_example.dart#example

### Handling Stream States

<<< @/../code_samples/lib/watch_it/user_activity_stream_example.dart#example

::: tip AsyncSnapshot and Null Safety
When you provide a **non-null** `initialValue` and use a **non-nullable stream type** (like `Stream<String>`), `AsyncSnapshot.data` won't be null. It starts with your initial value and updates with stream events:

<<< @/../code_samples/lib/watch_it/async_snapshot_always_has_value.dart#example

**Note:** If your stream type is nullable (like `Stream<String?>`), then stream events can emit null values, making `snapshot.data` null even with a non-null `initialValue`.
:::

### Compare with StreamBuilder

**Without watch_it:**

<<< @/../code_samples/lib/watch_it/stream_builder_comparison.dart#example

Much more nested and verbose!

### Advanced watchStream Usage

#### Watching Local Streams (target parameter)

If your stream isn't registered in get_it, use the `target` parameter:

<<< @/../code_samples/lib/watch_it/watch_stream_with_target.dart#example

**When to use:**
- Stream passed as widget parameter
- Locally created streams
- Streams from external packages

#### Allowing Stream Changes (allowStreamChange)

By default, `watchStream` throws an error if the stream instance changes between rebuilds (to prevent infinite loops). Set `allowStreamChange: true` to allow dynamic streams:

<<< @/../code_samples/lib/watch_it/watch_stream_allow_change.dart#example

**When to use:**
- Stream depends on reactive parameters (like selected room ID)
- Switching between different streams
- **Warning:** Make sure the stream instance actually changes, not recreated each build

#### Full Method Signature

```dart
AsyncSnapshot<R> watchStream<T extends Object, R>(
  Stream<R> Function(T)? select, {
  T? target,
  R? initialValue,
  bool preserveState = true,
  bool allowStreamChange = false,
  String? instanceName,
  GetIt? getIt,
})
```

**All parameters:**
- `select` - Function to get Stream from registered object (optional if using `target`)
- `target` - Direct stream to watch (optional, not from get_it)
- `initialValue` - Value shown before first stream event (makes `data` never null)
- `preserveState` - Keep last value when stream changes (default: `true`)
- `allowStreamChange` - Allow stream instance to change (default: `false`)
- `instanceName` - For named registrations
- `getIt` - Custom GetIt instance (rarely needed)

## watchFuture - Reactive Futures

Replace `FutureBuilder` with `watchFuture()`:

<<< @/../code_samples/lib/watch_it/data_watch_future_example.dart#example

::: tip AsyncSnapshot and Null Safety
Just like `watchStream`, when you provide a **non-null** `initialValue` to `watchFuture` with a **non-nullable future type** (like `Future<String>`), `AsyncSnapshot.data` won't be null. See the [AsyncSnapshot tip above](#handling-stream-states) for details.
:::

### Common Pattern: App Initialization

<<< @/../code_samples/lib/watch_it/splash_screen_initialization_example.dart#example

::: tip Advanced: Wait for Multiple Dependencies
If you need to wait for multiple async services to initialize (like database, auth, config), use `allReady()` instead of individual futures. See [Async Initialization with allReady](/documentation/watch_it/advanced_integration.md#async-initialization-with-isready-and-allready) for more details.
:::

### Advanced watchFuture Usage

#### Allowing Future Changes (allowFutureChange)

By default, `watchFuture` throws an error if the future instance changes between rebuilds (to prevent infinite loops). Set `allowFutureChange: true` for retriable operations:

<<< @/../code_samples/lib/watch_it/watch_future_allow_change.dart#example

**When to use:**
- Retry functionality for failed requests
- Future depends on reactive parameters
- **Warning:** Make sure the future instance actually changes, not recreated each build

#### Full Method Signature

```dart
AsyncSnapshot<R> watchFuture<T extends Object, R>(
  Future<R> Function(T)? select, {
  T? target,
  required R initialValue,
  bool preserveState = true,
  bool allowFutureChange = false,
  String? instanceName,
  GetIt? getIt,
})
```

**All parameters:**
- `select` - Function to get Future from registered object (optional if using `target`)
- `target` - Direct future to watch (optional, not from get_it)
- `initialValue` - **Required**. Value shown before future completes (makes `data` never null)
- `preserveState` - Keep last value when future changes (default: `true`)
- `allowFutureChange` - Allow future instance to change (default: `false`)
- `instanceName` - For named registrations
- `getIt` - Custom GetIt instance (rarely needed)

## Multiple Async Sources

Watch multiple streams or futures:

<<< @/../code_samples/lib/watch_it/dashboard_multiple_async_example.dart#example

## Mix Sync and Async

Combine synchronous and asynchronous data:

<<< @/../code_samples/lib/watch_it/user_profile_sync_async_example.dart#example

## AsyncSnapshot Quick Guide

Both `watchStream()` and `watchFuture()` return `AsyncSnapshot<T>`:

<<< @/../code_samples/lib/watch_it/async_patterns.dart#async_snapshot_guide

## Common Patterns

### Pattern 1: Simple Loading

<<< @/../code_samples/lib/watch_it/async_patterns.dart#pattern1_simple_loading

### Pattern 2: Error Handling

<<< @/../code_samples/lib/watch_it/async_patterns.dart#pattern2_error_handling

## No More Nested Builders!

**Before:**

<<< @/../code_samples/lib/watch_it/async_patterns.dart#nested_builders_before

**After:**

<<< @/../code_samples/lib/watch_it/async_patterns.dart#nested_builders_after

Flat, readable code!

## Key Takeaways

✅ `watchStream()` replaces `StreamBuilder` - no nesting
✅ `watchFuture()` replaces `FutureBuilder` - same benefit
✅ Both return `AsyncSnapshot<T>` - same API you know
✅ Automatic subscription and cleanup
✅ Combine sync and async data easily

**Next:** Learn about [side effects with handlers](/documentation/watch_it/handlers.md).

## See Also

- [Your First Watch Functions](/documentation/watch_it/your_first_watch_functions.md) - Sync data
- [Side Effects with Handlers](/documentation/watch_it/handlers.md) - Navigation, toasts
- [Watch Functions Reference](/documentation/watch_it/watch_functions.md) - Complete API
