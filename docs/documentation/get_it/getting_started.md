---
title: Getting started with get_it
---

# Getting Started 

This is a simple **Service Locator** for Dart and Flutter projects with some additional goodies highly inspired by [Splat](https://github.com/reactiveui/splat). It can be used instead of `InheritedWidget` or `Provider` to access objects e.g. from your UI.

Typical usage:

- Accessing service objects like REST API clients or databases so that they easily can be mocked.
- Accessing View/AppModels/Managers/BLoCs from Flutter Views

## Why GetIt

As your App grows, at some point you will need to put your app's logic in classes that are separated from your Widgets. Keeping your widgets from having direct dependencies makes your code better organized and easier to test and maintain.
But now you need a way to access these objects from your UI code. When I came to Flutter from the .Net world, the only way to do this was the use of InheritedWidgets. I found the way to use them by wrapping them in a StatefulWidget; quite cumbersome and have problems working consistently. Also:

- I missed the ability to easily switch the implementation for a mocked version without changing the UI.
- The fact that you need a `BuildContext` to access your objects made it inaccessible from the Business layer.

Accessing an object from anywhere in an App can be done in other ways, but:

- If you use a Singleton you can't easily switch the implementation out for a mock version in tests
- IoC containers for Dependency Injections offer similar functionality, but with the cost of slow start-up time and less readability because you don't know where the magically injected object comes from. Most IoC libs rely on reflection they cannot be ported to Flutter.

As I was used to using the Service Locator _Splat_ from .Net, I decided to port it to Dart. Since then, more features have been added.

> If you are not familiar with the concept of Service Locators, it's a way to decouple the interface (abstract base class) from a concrete implementation, and at the same time allows to access the concrete implementation from everywhere in your App over the interface.
> I can only highly recommend reading this classic article by Martin Fowler [Inversion of Control Containers and the Dependency Injection pattern](https://martinfowler.com/articles/injection.html).

GetIt is:

- Extremely fast (O(1))
- Easy to learn/use
- Doesn't clutter your UI tree with special Widgets to access your data like, Provider or Redux does.


## Getting Started

At your start-up you register all the objects you want to access later like this:

```dart
final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<AppModel>(AppModel());

// Alternatively you could write it if you don't like global variables
  GetIt.I.registerSingleton<AppModel>(AppModel());
}
```

After that you can access your `AppModel` class from anywhere like this:

```dart
MaterialButton(
  child: Text("Update"),
  onPressed: getIt<AppModel>().update   // given that your AppModel has a method update
),
```

You can find here a [detailed blog post on how to use GetIt](https://blog.burkharts.net/one-to-find-them-all-how-to-use-service-locators-with-flutter)

## GetIt in Detail

As Dart supports global (or euphemistic ambient) variables I often assign my GetIt instance to a global variable to make access to it as easy as possible.

Although the approach with a global variable worked well, it has its limitations if you want to use `GetIt` across multiple packages. Therefore GetIt itself is a singleton and the default way to access an instance of `GetIt` is to call:

```dart
GetIt getIt = GetIt.instance;

//There is also a shortcut (if you don't like it just ignore it):
GetIt getIt = GetIt.I;
```

Through this, any call to `instance` in any package of a project will get the same instance of `GetIt`. I still recommend just assigning the instance to a global variable in your project as it is more convenient and doesn't harm (Also it allows you to give your service locator your own name).

```dart
GetIt getIt = GetIt.instance;
```

> You can use any name you want which makes Brian :smiley: happy like (`sl, backend, services...`) ;-)

Before you can access your objects you have to register them within `GetIt` typically direct in your start-up code.


```dart
getIt.registerSingleton<AppModel>(AppModelImplementation());
getIt.registerLazySingleton<RESTAPI>(() => RestAPIImplementation());

// if you want to work just with the singleton:
GetIt.instance.registerSingleton<AppModel>(AppModelImplementation());
GetIt.I.registerLazySingleton<RESTAPI>(() => RestAPIImplementation());

/// `AppModel` and `RESTAPI` are both abstract base classes in this example
```

To access the registered objects call `get<Type>()` on your `GetIt` instance

```dart
var myAppModel = getIt.get<AppModel>();
```

Alternatively, as `GetIt` is a [callable class](https://www.w3adda.com/dart-tutorial/dart-callable-classes) depending on the name you choose for your `GetIt` instance you can use the shorter version:

```dart
var myAppModel = getIt<AppModel>();

// as Singleton:
var myAppModel = GetIt.instance<AppModel>();
var myAppModel = GetIt.I<AppModel>();
```