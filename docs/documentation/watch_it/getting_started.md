---
next:
  text: 'Your First Watch Functions'
  link: '/documentation/watch_it/your_first_watch_functions'
---

<div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 2rem;">
  <img src="/images/watch_it.svg" alt="watch_it logo" width="100" />
  <h1 style="margin: 0;">Getting Started</h1>
</div>

<strong>`watch_it`</strong> makes your Flutter widgets automatically rebuild when data changes. No <code>setState</code>, no <code>StreamBuilder</code>, just simple reactive programming built on top of get_it.

<strong>Key benefits:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong><a href="/documentation/watch_it/your_first_watch_functions.md">Automatic rebuilds</a></strong> - Widgets rebuild when data changes, no <code>setState</code> needed</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong><a href="/documentation/watch_it/how_it_works.md">No manual listeners</a></strong> - Automatic subscription & cleanup, prevent memory leaks</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong><a href="/documentation/watch_it/watching_streams_and_futures.md">Simpler async</a></strong> - Replace <code>StreamBuilder</code>/<code>FutureBuilder</code> with <code>watchStream()</code>/<code>watchFuture()</code></li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong><a href="/documentation/watch_it/handlers.md">Side effects</a></strong> - Navigation, dialogs, toasts without rebuilding</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong><a href="/documentation/watch_it/lifecycle.md">Lifecycle helpers</a></strong> - <code>callOnce()</code> for initialization, <code>createOnce()</code> for controllers</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong><a href="/documentation/watch_it/observing_commands.md">Command integration</a></strong> - Observe <code>command_it</code> commands reactively</li>
</ul>

<strong>Common use cases:</strong>
- Display live data from managers (todos, user profiles, settings) without <code>setState</code>
- Show real-time updates from streams (chat messages, notifications, sensor data)
- Navigate or show dialogs in response to data changes
- Display command progress (loading spinners, error messages, success states)

![watch_it Data Flow](/images/watch-it-flow.svg)

> Join our support Discord server: [https://discord.com/invite/Nn6GkYjzW](https://discord.com/invite/Nn6GkYjzW)

---

## Installation

Add watch_it to your `pubspec.yaml`:

```yaml
dependencies:
  watch_it: ^2.0.0
  get_it: ^8.0.0  # watch_it builds on get_it
```

---

## Quick Example

<strong>Step 1:</strong> Register your reactive objects with get_it:

<<< @/../code_samples/lib/watch_it/counter_simple_example.dart#example

<strong>Step 2:</strong> Use `WatchingWidget` and watch your data:

The widget automatically rebuilds when the counter value changes - no `setState` needed!

<strong>How it works:</strong>
1. **`WatchingWidget`** - Like `StatelessWidget`, but with reactive superpowers
2. **`watchValue()`** - Watches data from get_it and rebuilds when it changes
3. **Automatic subscriptions** - No manual listeners, no cleanup needed

The widget automatically subscribes to changes when it builds and cleans up when disposed.

---

## Adding to Existing Apps

Already have an app? Just add a mixin to your existing widgets:

<<< @/../code_samples/lib/watch_it/mixin_simple_example.dart#example

No need to change your widget hierarchy - just add `with WatchItMixin` and start using watch functions.

## What's Next?

Now that you've seen the basics, there's so much more `watch_it` can do:

→ **[Your First Watch Functions](/documentation/watch_it/your_first_watch_functions.md)** - Deep dive into `watchValue()` and other watch functions

→ **[WatchingWidgets](/documentation/watch_it/watching_widgets.md)** - Learn which widget type to use (WatchingWidget, WatchingStatefulWidget, or mixins)

→ **[Watching Streams & Futures](/documentation/watch_it/watching_streams_and_futures.md)** - Replace `StreamBuilder` and `FutureBuilder` with one-line `watchStream()` and `watchFuture()`

→ **[Lifecycle Functions](/documentation/watch_it/lifecycle.md)** - Run code once with `callOnce()`, create local objects with `createOnce()`, and manage disposal

The documentation will guide you step-by-step from there!

## Need Help?

- **Documentation:** [flutter-it.dev](https://flutter-it.dev)
- **Discord:** [Join our community](https://discord.com/invite/Nn6GkYjzW)
- **GitHub:** [Report issues](https://github.com/escamoteur/watch_it/issues)
