---
title: Scopes
---

# Scopes

With V5.0 of GetIt, it now supports hierarchical scoping of registration. What does this mean?
You can push a new registration scope like you push a new page on the Navigator. Any registration after that will be registered in this new scope. When accessing an object with `get` GetIt first checks the topmost scope for registration and then the ones below. This means you can register the same type that was already registered in a lower scope again in the scope above and you will always get the latest registered object.

Imagine an app that can be used with or without a login. On App start-up, a `DefaultUser` object is registered with the abstract type `User` as a singleton. As soon as the user logs in, a new scope is pushed and a new `LoggedInUser` object again with the `User` type is registered that allows more functions. For the rest of the App, nothing has changed as it still accesses `User` objects through GetIt.
As soon as the user Logs off all you have to do is pop the Scope and automatically the `DefaultUser` is used again.

Another example could be a shopping basket where you want to ensure that not a cart from a previous session is used again. So at the beginning of a new session, you push a new scope and register a new cart object. At the end of the session, you pop this scope again.

### Scope functions

```dart
  /// Creates a new registration scope. If you register types after creating
  /// a new scope they will hide any previous registration of the same type.
  /// Scopes allow you to manage different live times of your Objects.
  /// [scopeName] if you name a scope you can pop all scopes above the named one
  /// by using the name.
  /// [dispose] function that will be called when you pop this scope. The scope
  /// is still valid while it is executed
  /// [init] optional function to register Objects immediately after the new scope is
  /// pushed. This ensures that [onScopeChanged] will be called after their registration
  /// if [isFinal] is set to true, you can't register any new objects in this scope after
  /// this call. In Other words you have to register the objects for this scope inside
  /// [init] if you set [isFinal] to true. This is useful if you want to ensure that
  /// no new objects are registered in this scope by accident which could lead to race conditions
  void pushNewScope({void Function(GetIt getIt)? init,String scopeName, ScopeDisposeFunc dispose});

  /// Disposes all factories/Singletons that have been registered in this scope
  /// and pops (destroys) the scope so that the previous scope gets active again.
  /// if you provided dispose functions on registration, they will be called.
  /// if you passed a dispose function when you pushed this scope it will be
  /// called before the scope is popped.
  /// As dispose functions can be async, you should await this function.
  Future<void> popScope();

  /// if you have a lot of scopes with names you can pop (see [popScope]) all
  /// scopes above the scope with [name] including that scope unless [inclusive]= false
  /// Scopes are popped in order from the top
  /// As dispose functions can be async, you should await this function.
  /// If no scope with [name] exists, nothing is popped and `false` is returned
  Future<bool> popScopesTill(String name, {bool inclusive = true});

  /// Clears all registered factories and singletons in the provided scope,
  /// then destroys (drops) the scope. If the dropped scope was the last one,
  /// the previous scope becomes active again.
  /// if you provided dispose functions on registration, they will be called.
  /// if you passed a dispose function when you pushed this scope it will be
  /// called before the scope is dropped.
  /// As dispose functions can be async, you should await this function.
  Future<void> dropScope(String scopeName);

  /// Tests if the scope by name [scopeName] is registered in GetIt
  bool hasScope(String scopeName);

  /// Clears all registered types for the current scope in the reverse order in which they were registered.
  /// If you provided dispose function when registering they will be called
  /// [dispose] if `false` it only resets without calling any dispose
  /// functions
  /// As dispose funcions can be async, you should await this function.
  Future<void> resetScope({bool dispose = true});
```

#### Getting notified about the shadowing state of an object

In some cases, it might be helpful to know if an Object gets shadowed by another one e.g. if it has some Stream subscriptions that it wants to cancel before the shadowing object creates a new subscription. Also, the other way round so that a shadowed Object gets notified when it's "active" again meaning when a shadowing object is removed.

For this a class had to implement the `ShadowChangeHandlers` interface:

```dart
abstract class ShadowChangeHandlers {
  void onGetShadowed(Object shadowing);
  void onLeaveShadow(Object shadowing);
}
```

When the Object is shadowed its `onGetShadowed()` method is called with the object that is shadowing it. When this object is removed from GetIt `onLeaveShadow()` will be called.

#### Getting notified when a scope change happens

When using scopes with objects that shadow other objects it's important to give the UI a chance to rebuild and acquire references to the now active objects. For this, you can register a call-back function in GetIt.
The getit_mixin has a matching `rebuiltOnScopeChange` method.

```dart
  /// Optional call-back that will get called whenever a change in the current scope happens
  /// This can be very helpful to update the UI in such a case to make sure it uses
  /// the correct Objects after a scope change
  void Function(bool pushed)? onScopeChanged;
```

### Disposing Singletons and Scopes

From V5.0 on you can pass a `dispose` function when registering any Singletons. For this the registration functions have an optional parameter:

```dart
DisposingFunc<T> dispose
```

where `DisposingFunc` is defined as

```dart
typedef DisposingFunc<T> = FutureOr Function(T param);
```

So you can pass simple or async functions as this parameter. This function is called when you pop or reset the scope or when you reset GetIt completely.

When you push a new scope you can also pass a `dispose` function that is called when a scope is popped or reset but before the dispose functions of the registered objects is called which means it can still access the objects that were registered in that scope.