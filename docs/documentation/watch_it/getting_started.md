---
next:
  text: 'Your First Watch Functions'
  link: '/documentation/watch_it/your_first_watch_functions'
---

<div class="header-with-logo">
  <div class="header-content">

# Getting Started with watch_it

  </div>
  <img src="/images/watch_it.svg" alt="watch_it logo" width="100" class="header-logo" />
</div>

:::warning 🚧 WORK IN PROGRESS
This documentation is currently being reviewed and updated. Content may change based on feedback.
:::

watch_it makes your Flutter widgets automatically rebuild when data changes. No `setState`, no `StreamBuilder`, just simple reactive programming.

> Join our support Discord server: [https://discord.gg/ZHYHYCM38h](https://discord.gg/ZHYHYCM38h)

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  watch_it: ^2.0.0
  get_it: ^8.0.0  # watch_it builds on get_it
```

## Why watch_it? (Compared to get_it alone)

get_it gives you dependency injection. watch_it adds **reactive UI** on top:

- ✅ **Automatic rebuilds** - Widgets rebuild when data changes, no `setState` needed → [Your First Watch Functions](/documentation/watch_it/your_first_watch_functions.md)
- ✅ **No manual listeners** - Automatic subscription & cleanup, prevent memory leaks → [How watch_it Works](/documentation/watch_it/how_it_works.md)
- ✅ **Simpler async** - Replace `StreamBuilder`/`FutureBuilder` with `watchStream()`/`watchFuture()` → [Watching Streams & Futures](/documentation/watch_it/watching_streams_and_futures.md)
- ✅ **Side effects** - Navigation, dialogs, toasts without rebuilding → [Side Effects with Handlers](/documentation/watch_it/handlers.md)
- ✅ **Lifecycle helpers** - `callOnce()` for initialization, `createOnce()` for controllers → [Lifecycle Functions](/documentation/watch_it/lifecycle.md)
- ✅ **Command integration** - Observe `command_it` commands reactively → [Observing Commands](/documentation/watch_it/observing_commands.md)

**Bottom line:** get_it manages dependencies, watch_it makes them **reactive** in your UI.

## Your First Reactive Widget

Here's a simple counter that rebuilds automatically when the count changes:

<<< @/../code_samples/lib/watch_it/counter_simple_example.dart#example

That's it! When you press the button, the widget automatically rebuilds with the new count.

## How It Works

1. **`WatchingWidget`** - Like `StatelessWidget`, but with reactive superpowers
2. **`watchValue()`** - Watches data from get_it and rebuilds when it changes
3. **Automatic subscriptions** - No manual listeners, no cleanup needed

The widget automatically subscribes to changes when it builds and cleans up when disposed.

## Adding to Your Existing App

Already have an app? Just add a mixin to your existing widgets:

<<< @/../code_samples/lib/watch_it/mixin_simple_example.dart#example

No need to change your widget hierarchy - just add `with WatchItMixin` and start using watch functions.

## What's Next?

Now that you've seen the basics, there's so much more watch_it can do:

→ **[Your First Watch Functions](/documentation/watch_it/your_first_watch_functions.md)** - Deep dive into `watchValue()` and other watch functions

→ **[WatchingWidgets](/documentation/watch_it/watching_widgets.md)** - Learn which widget type to use (WatchingWidget, WatchingStatefulWidget, or mixins)

→ **[Watching Streams & Futures](/documentation/watch_it/watching_streams_and_futures.md)** - Replace `StreamBuilder` and `FutureBuilder` with one-line `watchStream()` and `watchFuture()`

→ **[Lifecycle Functions](/documentation/watch_it/lifecycle.md)** - Run code once with `callOnce()`, create local objects with `createOnce()`, and manage disposal

The documentation will guide you step-by-step from there!

## Need Help?

- **Documentation:** [flutter-it.dev](https://flutter-it.dev)
- **Discord:** [Join our community](https://discord.gg/ZHYHYCM38h)
- **GitHub:** [Report issues](https://github.com/escamoteur/watch_it/issues)
