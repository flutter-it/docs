---
title: Different ways of registration
---

# Different ways of registration

`GetIt` offers different ways how objects are registered that affect the lifetime of these objects.

#### Factory

```dart
void registerFactory<T>(FactoryFunc<T> func)
```

You have to pass a factory function `func` that returns a NEW instance of an implementation of `T`. Each time you call `get<T>()` you will get a new instance returned. How to pass parameters to a factory you can find [here](#passing-parameters-to-factories).

###### Passing Parameters to factories

In some cases, it's handy if you could pass changing values to factories when calling `get()`. For that there are two variants for registering factories:

```dart
/// registers a type so that a new instance will be created on each call of [get] on that type based on
/// up to two parameters provided to [get()]
/// [T] type to register
/// [P1] type of param1
/// [P2] type of param2
/// if you use only one parameter pass void here
/// [factoryfunc] factory function for this type that accepts two parameters
/// [instanceName] if you provide a value here your factory gets registered with that
/// name instead of a type. This should only be necessary if you need to register more
/// than one instance of one type.
///
/// example:
///    getIt.registerFactoryParam<TestClassParam,String,int>((s,i)
///        => TestClassParam(param1:s, param2: i));
///
/// if you only use one parameter:
///
///    getIt.registerFactoryParam<TestClassParam,String,void>((s,_)
///        => TestClassParam(param1:s);
void registerFactoryParam<T,P1,P2>(FactoryFuncParam<T,P1,P2> factoryfunc, {String instanceName});

```

and

```dart
  void registerFactoryParamAsync<T,P1,P2>(FactoryFuncParamAsync<T,P1,P2> factoryfunc, {String instanceName});
```

The reason why I settled to use two parameters is that I can imagine some scenarios where you might want to register a builder function for Flutter Widgets that need to get a `BuildContext` and some data object.

When accessing these factories you pass the parameters a optional arguments to `get()`:

```dart
  var instance = getIt<TestClassParam>(param1: 'abc',param2:3);
```

These parameters are passed as `dynamics` (otherwise I would have had to add more generic parameters to `get()`), but they are checked at runtime to be the correct types.

#### Singleton & LazySingleton

> Although I always would recommend using an abstract base class as a registration type so that you can vary the implementations you don't have to do this. You can also register concrete types.

```dart
T registerSingleton<T>(T instance)
```

You have to pass an instance of `T` or a derived class of `T` that you will always get returned on a call to `get<T>()`. The newly registered instance is also returned which can be sometimes convenient.

As creating this instance can be time-consuming at app start-up you can shift the creation to the time the object is the first time requested with:

```dart
void registerLazySingleton<T>(FactoryFunc<T> func)
```

You have to pass a factory function `func` that returns an instance of an implementation of `T`. Only the first time you call `get<T>()` this factory function will be called to create a new instance. After that, you will always get the same instance returned.

### Registering multiple implementations

There are certain circumstances where you might wish to register multiple implementations of the same interface and then get a list of all of the relevant implementations later on. For instance, you might have a modular design where each module registers an interface defining a page and then all of these get injected into your navigation bar in your main layout without your layout needing to know about each module.

> [!NOTE]  
> To avoid this being a breaking change and to prevent you from erroneously re-registering a type without expecting this behaviour, to enable this you need to call:
>
>```dart
>getIt.enableRegisteringMultipleInstancesOfOneType();
>```

Then, you just register your classes as you normally would:

```dart
getIt.registerLazySingleton<MyBase>(
  () => ImplA(),
);
getIt.registerLazySingleton<MyBase>(
  () => ImplB(),
);
```

Then, later on you can fetch all instances of this interface by calling:

```dart
final Iterable<MyBase> instances = getIt.getAll<MyBase>();
```
The returned `Iterable` will then contain all registered instances of the requested interface with or without an instance name.
There is also an `async` implementation available for this:

```dart
final Iterable<MyBase> instances = await getIt.getAllAsync<MyBase>();
```

### Overwriting registrations

If you try to register a type more than once you will fail with an assertion in debug mode because normally this is not needed and probably a bug.
If you really have to overwrite a registration, then you can by setting the property `allowReassignment = true`.

### Skip Double registrations while testing

If you try to register a type more than once and when `allowReassignment = false`  you will fail with an assertion in debug mode.
If you want to just skip this double registration silently without an error, then you can by setting the property `skipDoubleRegistration = true`.
This is only available inside tests where is can be handy.

### Testing if a Singleton is already registered

You can check if a certain Type or instance is already registered in GetIt with:

```dart
 /// Tests if an [instance] of an object or aType [T] or a name [instanceName]
 /// is registered inside GetIt
 bool isRegistered<T>({Object instance, String instanceName});
```

### Unregistering Singletons or Factories

If you need to you can also unregister your registered singletons and factories and pass an optional `disposingFunction` for clean-up.

```dart
/// Unregister an [instance] of an object or a factory/singleton by Type [T] or by name [instanceName]
/// if you need to dispose some resources before the reset, you can
/// provide a [disposingFunction]. This function overrides the disposing
/// you might have provided when registering.
void unregister<T>({Object instance,String instanceName, void Function(T) disposingFunction})
```

### Resetting LazySingletons

In some cases, you might not want to unregister a LazySingleton but instead, reset its instance so that it gets newly created on the next access to it.

```dart
  /// Clears the instance of a lazy singleton,
  /// being able to call the factory function on the next call
  /// of [get] on that type again.
  /// you select the lazy Singleton you want to reset by either providing
  /// an [instance], its registered type [T] or its registration name.
  /// if you need to dispose some resources before the reset, you can
  /// provide a [disposingFunction]. This function overrides the disposing
  /// you might have provided when registering.
void resetLazySingleton<T>({Object instance,
                            String instanceName,
                            void Function(T) disposingFunction})
```

### Resetting GetIt completely

```dart
/// Clears all registered types in the reverse order in which they were registered.
/// Handy when writing unit tests or before quitting your application.
/// If you provided dispose function when registering they will be called
/// [dispose] if `false` it only resets without calling any dispose
/// functions
/// As dispose funcions can be async, you should await this function.
Future<void> reset({bool dispose = true});
```