# How Does It Work?

## Lifting the magic curtain

*It's not necessary to understand the following chapter to use `WatchIt` successfully.

You might be wondering how on earth is this possible, that you can watch multiple objects at the same time without passing some identifier to any of the `watch` functions. The reality might feel a bit like a hack but the advantages that you get from it justify it absolutely.

When applying the `WatchItMixin` to a Widget you add a handler into the build mechanism of Flutter that makes sure that before the `build` function is called a `_watchItState` object that contains a reference to the `Element` of this widget plus a list of `WatchEntry`s is assigned to a private global variable. Over this global variable the `watch*` functions can access the `Element` to trigger a rebuild.

With each `watch*` function call a new `WatchEntry` is added to that list and a counter is incremented.

When a rebuild is triggered the counter is reset and incremented again with each `watch*` call so that it can access the data it stored during the last build.

Now it should be clear why the `watch*` functions always have to happen in the same order and no conditionals are allowed that would change the order between two builds because then the relation between `watch*` call and its `WatchEntry` would be messed up.

If you think that all sounds very familiar to you then probably because the exact same mechanism is used by `flutter_hooks` or React Hooks.
