# callOnce & createOnce

## callOnce() and onDispose()

If you want to execute a function  only on the first built (even in in a StatelessWidget), you can use the `callOnce` function anywhere in your build function. It has an optional `dispose` handler which will be called when the widget is disposed.

To dispose anything when the widget is disposed you can use call `onDispose` anywhere in your build function

## createOnce and createOnceAsync

If you need an object that is created on the first build of your stateless widget that is automatically disposed when the widget is destroyed you can use `createOnce`:

<<< @/../code_samples/lib/watch_it/lifecycle_create_once_example.dart#example

On the first build, the controller gets created. On all following builds the same controller instance is returned. When the widget is disposed the controller gets disposed by either:

* if the object contains a `dispose()` method it will be called automatically
* if you need to call a different function to dispose the object, like `cancel()` on a StreamSubscription you can pass a custom dispose function as a second parameter to `createOnce`.

If the object you need requires an async creation function you can use:

```dart
/// [createOnceAsync] creates an  object with the async factory function
/// [factoryFunc] at the time of the first build and disposes it when the widget
/// is disposed if the object implements the Disposable interface.
/// [initialValue] is the value that will be returned until the factory function
/// completes.
/// When the [factoryFunc] completes the value will be updated with the new value
/// and the widget will be rebuilt.
/// [dispose] allows you to pass a custom dispose function to dispose of the
/// object.
/// if provided it will override the default dispose behavior.
AsyncSnapshot<T> createOnceAsync<T>(Future<T> Function() factoryFunc,
    {required T initialValue, void Function(T)? dispose});
```
