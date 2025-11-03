<div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 2rem;">
  <img src="/images/watch_it.svg" alt="watch_it logo" width="100" />
  <h1 style="margin: 0;">Getting Started with watch_it</h1>
</div>

::: info Work In Progress
This documentation is currently being restructured and will soon match the comprehensive style of the get_it documentation. Stay tuned for improvements!
:::

A simple state management solution powered by get_it.

> This package is the successor of the get_it_mixin, [here you can find what's new](#whats-different-from-the-get_it_mixin)

> We now have a support discord server [https://discord.gg/ZHYHYCM38h](https://discord.gg/ZHYHYCM38h)

This package offers a set of functions to `watch` data registered with `GetIt`. Widgets that watch data will rebuild automatically whenever that data changes.

Supported data types that can be watched are `Listenable / ChangeNotifier`, `ValueListenable / ValueNotifier`, `Stream` and `Future`. On top of that there are several other powerful functions to use in `StatelessWidgets` that normally would require a `StatefulWidget`.

`ChangeNotifier` based example:

```dart
 // Create a ChangeNotifier based model
 class UserModel extends ChangeNotifier {
   get name => _name;
   String _name = '';
   set name(String value){
     _name = value;
     notifyListeners();
   }
   ...
 }

 // Register it
 di.registerSingleton<UserModel>(UserModel());

 // Watch it
 class UserNameText extends WatchingWidget {
   @override
   Widget build(BuildContext context) {
     final userName = watchPropertyValue((UserModel m) => m.name);
     return Text(userName);
   }
 }
```

Whenever the name property changes the `watchPropertyValue` function will trigger a rebuild and return the latest value of `name`.

## Accessing GetIt

WatchIt exports the default instance of get_it as a global variable `di` (**d**ependency **i**njection) which lets
you access it from anywhere in your app. To access any get_it registered
object you only have to type `di<MyType>()` instead of `GetIt.I<MyType>()`.
If you prefer to use `GetIt.I` or you have your own global variable that's fine too as they all
will use the same instance of GetIt.

> Because of criticism that GetIt isn't real dependency injection, therefore `di` wouldn't be correct, you now can also use `sl` for service locator instead.

If you want to use a different instance of get_it you can pass it to
the functions of this library as an optional parameter.

## What's different from the `get_it_mixin`

Two main reasons lead me to replace the `get_it_mixin` package with `watch_it`

* The name `get_it_mixin seemed not to catch with people and only a fraction of my get_it users used it.
* The API naming wasn't as intuitive as I thought when I first wrote them.

These are the main differences:

* Widgets now can be `const`!
* a reduced API with more intuitive naming.The old package had too many functions which were only slight variations of each other. You can easily achieve the same functionality with the functions of this package.
* no `get/getX` functions anymore because you can just use the included global `get_it` instance `di<T>`.
* only one mixin for all Widgets. You only need to apply it to the widget and no mixin for `States` as now all `watch*` functions are global functions.

Please let me know if you miss anything
