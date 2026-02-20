---
title: Welcome to flutter_it
---

<div class="header-with-logo">
  <div class="header-content">

# Build reactive Flutter apps the easy way

**No codegen, no boilerplate, just code.**

flutter_it is a **modular construction set** of reactive tools for Flutter. Pick what you need, combine as you grow, or use them all together. Each package works independently and integrates seamlessly with the others.

  </div>
  <img src="/images/main-logo.svg" alt="flutter_it" width="225" class="header-logo" />
</div>

::: tip 🤖 AI-Assisted Development
Every flutter_it package ships with **AI skill files** that help Claude Code, Cursor, GitHub Copilot, and other AI tools generate correct code. [Learn more →](/misc/ai_skills)
:::

## Why flutter_it?

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Zero build_runner</strong> - No code generation, no waiting for builds</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Pure Dart</strong> - Works with standard Flutter, no magic</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Modular by design</strong> - Use one package or combine several—you choose</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Built on ChangeNotifier and ValueNotifier</strong> - Seamless Flutter integration with familiar primitives</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Type-safe</strong> - Full compile-time type checking</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Battle-tested</strong> - Trusted by thousands of Flutter developers</li>
</ul>

## See it in action

```dart
// 1. Register services anywhere in your app (get_it)
final getIt = GetIt.instance;
getIt.registerSingleton(CounterModel());

// 2. Watch and react to changes automatically (watch_it)
class CounterWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final count = watchValue((CounterModel m) => m.count);
    return Text('Count: $count'); // Your widget automatically rebuilds on every change
  }
}

// 3. Use reactive collections (listen_it)
final items = ListNotifier<String>();
items.add('New item'); // Automatically notifies listeners

// 4. Encapsulate actions with commands (command_it)
final saveCommand = Command.createAsyncNoResult<UserData>(
  (userData) async => await api.save(userData),
);
// Access loading state, errors - all built-in
```

No setState(), no Provider boilerplate, no code generation. Just reactive Flutter.

## The Construction Set

> 💡 **Each package works standalone** - start with one, add others as needed.

### <img src="/images/get_it.svg" alt="get_it" width="50" style="vertical-align: middle; margin-right: 0.5rem; display: inline-block;" />get_it

**Dependency injection without the framework**

Simple service locator that works anywhere in your app—no BuildContext, no InheritedWidget trees, just clean dependency access.

[Get started →](/documentation/get_it/getting_started) | [Examples →](/examples/get_it/get_it)

---

### <img src="/images/watch_it.svg" alt="watch_it" width="50" style="vertical-align: middle; margin-right: 0.5rem; display: inline-block;" />`watch_it`

**Reactive UI updates, automatically**

React to state changes without setState()—watch values and rebuild only what's needed. You'll almost never need a StatefulWidget anymore. Depends on get_it for service location.

[Get started →](/documentation/watch_it/getting_started) | [Examples →](/examples/watch_it/watch_it)

---

### <img src="/images/command_it.svg" alt="command_it" width="67" style="vertical-align: middle; margin-right: 0.5rem; display: inline-block;" />command_it

**Encapsulate actions with built-in state**

Commands that track execution, handle errors, and provide loading states automatically. Handle exceptions the smart way. Perfect for async operations.

[Get started →](/documentation/command_it/getting_started) | [Examples →](/examples/command_it/command_it)

---

### <img src="/images/listen_it.svg" alt="listen_it" width="50" style="vertical-align: middle; margin-right: 0.5rem; display: inline-block;" />listen_it

**Combine reactive state in an RxDart-like style that's easy to understand**

Transform, filter, combine, and debounce operators for ValueNotifier—plus reactive collections (ListNotifier, MapNotifier, SetNotifier) that automatically notify on changes.

[Get started →](/documentation/listen_it/listen_it) | [Examples →](/examples/listen_it/listen_it)

---

## Getting Started

**New to flutter_it?** Start here:

1. **[What to do with which package](/getting_started/what_to_do_with_which_package)** - Find the right tool for your needs
2. **[Complete Documentation](/documentation/overview)** - Deep dive into each package
3. **[Real-world Examples](/examples/overview)** - See patterns in action

## Community

Join the flutter_it community:

- **[GitHub](https://github.com/flutter-it)** - Source code and issues
- **[Discord](https://discord.com/invite/Nn6GkYjzW)** - Chat and support
- **[Twitter](https://x.com/ThomasBurkhartB)** - Updates and news

