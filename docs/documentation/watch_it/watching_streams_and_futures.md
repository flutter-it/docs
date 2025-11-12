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

**Method signature:**
```dart
AsyncSnapshot<R> watchStream<T extends Object, R>(
  Stream<R> Function(T) select,
  {required R initialValue,
   bool preserveState = true,
   String? instanceName,
   GetIt? getIt}
)
```

**Parameters:**
- `select` - Function that gets the Stream from the registered object
- `initialValue` - **Required**. The value shown before the first stream event arrives
- `preserveState` - If `true` (default), keeps the last value when the stream changes
- `instanceName` - Optional name if you registered multiple instances of the same type
- `getIt` - Optional custom GetIt instance (rarely needed)

**Returns `AsyncSnapshot<R>`:**
- `data` - The current value (starts with `initialValue`)
- `connectionState` - Current state: `waiting`, `active`, `done`
- `hasData` - `true` if data is available
- `hasError` - `true` if an error occurred
- `error` - The error object if any

### Before and After

**Compare with StreamBuilder:**

```dart
class UserActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: di<UserService>().activityStream,
      initialValue: 'No activity',
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return Text('Activity: ${snapshot.data}');
      },
    );
  }
}
```

Much more nested and verbose!

## watchFuture - Reactive Futures

Replace `FutureBuilder` with `watchFuture()`:

<<< @/../code_samples/lib/watch_it/data_watch_future_example.dart#example

**Method signature:**
```dart
AsyncSnapshot<R> watchFuture<T extends Object, R>(
  Future<R> Function(T) select,
  {required R initialValue,
   bool preserveState = true,
   String? instanceName,
   GetIt? getIt}
)
```

**Parameters:**
- `select` - Function that gets the Future from the registered object
- `initialValue` - **Required**. The value shown before the future completes
- `preserveState` - If `true` (default), keeps the last value when the future changes
- `instanceName` - Optional name if you registered multiple instances of the same type
- `getIt` - Optional custom GetIt instance (rarely needed)

**Returns `AsyncSnapshot<R>`:**
- `data` - The current value (starts with `initialValue`, updates when future completes)
- `connectionState` - Current state: `waiting`, `done`
- `hasData` - `true` if data is available
- `hasError` - `true` if the future threw an error
- `error` - The error object if any

### Common Pattern: App Initialization

<<< @/../code_samples/lib/watch_it/splash_screen_initialization_example.dart#example

::: tip Advanced: Wait for Multiple Dependencies
If you need to wait for multiple async services to initialize (like database, auth, config), use `allReady()` instead of individual futures. See [Async Initialization with allReady](/documentation/watch_it/advanced_integration.md#async-initialization-with-isready-and-allready) for more details.
:::

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
