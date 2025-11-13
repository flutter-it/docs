# callOnce & createOnce

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
