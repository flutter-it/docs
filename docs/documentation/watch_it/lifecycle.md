# Lifecycle Functions

## callOnce() and onDispose()

Execute a function only on the first build (even in a StatelessWidget), with optional dispose handler.

**Method signatures:**

```dart
void callOnce(
  void Function(BuildContext context) init,
  {void Function()? dispose}
);

void onDispose(void Function() dispose);
```

**Typical use case:** Trigger data loading on first build, then display results with `watchValue`:

<<< @/../code_samples/lib/watch_it/lifecycle_call_once_example.dart#example

## callOnceAfterThisBuild()

Execute a callback once after the current build completes. Unlike `callOnce()` which runs immediately during build, this runs in a post-frame callback.

**Method signature:**

```dart
void callOnceAfterThisBuild(
  void Function(BuildContext context) callback
);
```

**Perfect for:**
- Navigation after async dependencies are ready
- Showing dialogs or snackbars after initial render
- Accessing RenderBox dimensions
- Operations that should not run during build

**Key behavior:**
- Executes once after the first build where this function is called
- Runs in a post-frame callback (after layout and paint)
- Safe to use inside conditionals - will execute once when the condition first becomes true
- Won't execute again on subsequent builds, even if called again

**Example - Navigate when dependencies are ready:**

<<< @/../code_samples/lib/watch_it/lifecycle_call_once_after_this_build_example.dart#example

**Contrast with callOnce:**
- `callOnce()`: Runs immediately during build (synchronous)
- `callOnceAfterThisBuild()`: Runs after build completes (post-frame callback)

## callAfterEveryBuild()

Execute a callback after every build. The callback receives a `cancel()` function to stop future invocations.

**Method signature:**

```dart
void callAfterEveryBuild(
  void Function(BuildContext context, void Function() cancel) callback
);
```

**Use cases:**
- Update scroll position after rebuilds
- Reposition overlays or tooltips
- Perform measurements after layout changes
- Sync animations with rebuild state

**Example - Scroll to top with cancel:**

<<< @/../code_samples/lib/watch_it/lifecycle_call_after_every_build_example.dart#example

**Important:**
- Callback executes after EVERY rebuild
- Use `cancel()` to stop when no longer needed
- Runs in post-frame callback (after layout completes)

## createOnce and createOnceAsync

Create an object on the first build that is automatically disposed when the widget is destroyed. Ideal for all types of controllers (`TextEditingController`, `AnimationController`, `ScrollController`, etc.) or reactive local state (`ValueNotifier`, `ChangeNotifier`).

**Method signatures:**

```dart
T createOnce<T extends Object>(
  T Function() factoryFunc,
  {void Function(T)? dispose}
);

AsyncSnapshot<T> createOnceAsync<T>(
  Future<T> Function() factoryFunc,
  {required T initialValue, void Function(T)? dispose}
);
```

<<< @/../code_samples/lib/watch_it/lifecycle_create_once_example.dart#example

**How it works:**
- On first build, the object is created with `factoryFunc`
- On subsequent builds, the same instance is returned
- When the widget is disposed:
  - If the object has a `dispose()` method, it's called automatically
  - If you need a different dispose function (like `cancel()` on StreamSubscription), pass it as the `dispose` parameter

**Creating local state with ValueNotifier:**

<<< @/../code_samples/lib/watch_it/watch_create_once_local_state.dart#example

## createOnceAsync

Ideal for one-time async function calls to display data, for instance from some backend endpoint.

**Full signature:**

```dart
AsyncSnapshot<T> createOnceAsync<T>(
  Future<T> Function() factoryFunc,
  {required T initialValue, void Function(T)? dispose}
);
```

**How it works:**
- Returns `AsyncSnapshot<T>` immediately with `initialValue`
- Executes `factoryFunc` asynchronously on first build
- Widget rebuilds automatically when the future completes
- `AsyncSnapshot` contains the state (loading, data, error)
- Object is disposed when widget is destroyed

<<< @/../code_samples/lib/watch_it/lifecycle_create_once_async_example.dart#example
