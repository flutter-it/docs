---
title: Documentation Overview
---

# Documentation Overview

Welcome to the flutter_it documentation! Here you'll find comprehensive guides for all the packages in the flutter_it ecosystem.

## Available Packages

### <img src="/images/get_it.svg" alt="get_it" width="50" style="vertical-align: middle; margin-right: 0.5rem; display: inline-block;" />get_it
Simple service locator for dependency injection in Flutter applications.

**Documentation:**
- [Getting Started](/documentation/get_it/getting_started.md) - Learn the basics of get_it
- [Object Registration](/documentation/get_it/object_registration.md) - Different ways to register objects
- [Scopes](/documentation/get_it/scopes.md) - Managing object lifecycles with scopes
- [Async Objects](/documentation/get_it/async_objects.md) - Working with asynchronous objects
- [Multiple Registrations](/documentation/get_it/multiple_registrations.md) - Multiple instances of same type
- [Advanced](/documentation/get_it/advanced.md) - Advanced techniques and patterns
- [Testing](/documentation/get_it/testing.md) - How to test with get_it
- [Flutter Previews](/documentation/get_it/flutter_previews.md) - Using get_it with Flutter previews
- [FAQ](/documentation/get_it/faq.md) - Frequently asked questions

### <img src="/images/watch_it.svg" alt="watch_it" width="50" style="vertical-align: middle; margin-right: 0.5rem; display: inline-block;" />watch_it
Reactive state management with automatic dependency tracking.

**Documentation:**
- [Getting Started](/documentation/watch_it/getting_started.md) - Introduction to watch_it
- [Your First Watch Functions](/documentation/watch_it/your_first_watch_functions.md) - Basic watch patterns
- [More Watch Functions](/documentation/watch_it/more_watch_functions.md) - Advanced watch functions
- [Watching Multiple Values](/documentation/watch_it/watching_multiple_values.md) - Combining multiple sources
- [Watching Streams & Futures](/documentation/watch_it/watching_streams_and_futures.md) - Async data sources
- [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) - Critical ordering constraints
- [Side Effects with Handlers](/documentation/watch_it/handlers.md) - Navigation, toasts, logging
- [Lifecycle Functions](/documentation/watch_it/lifecycle.md) - callOnce, createOnce, onDispose
- [WatchingWidgets](/documentation/watch_it/watching_widgets.md) - Widget base classes
- [Observing Commands](/documentation/watch_it/observing_commands.md) - Integration with command_it
- [Advanced Integration](/documentation/watch_it/advanced_integration.md) - Scopes and complex patterns
- [Best Practices](/documentation/watch_it/best_practices.md) - Production-ready patterns
- [Debugging & Troubleshooting](/documentation/watch_it/debugging_tracing.md) - Common errors and solutions
- [How watch_it Works](/documentation/watch_it/how_it_works.md) - Internal architecture
- [Watch Functions Reference](/documentation/watch_it/watch_functions.md) - Complete API reference

### <img src="/images/command_it.svg" alt="command_it" width="67" style="vertical-align: middle; margin-right: 0.5rem; display: inline-block;" />command_it
Command pattern implementation for Flutter applications.

**Documentation:**
- [Getting Started](/documentation/command_it/getting_started.md) - Introduction to command_it
- [Command Types](/documentation/command_it/command_types.md) - Sync, async, parameterized commands
- [Command Builders](/documentation/command_it/command_builders.md) - Building commands for widgets
- [Error Handling](/documentation/command_it/error_handling.md) - Managing errors and failures

### <img src="/images/listen_it.svg" alt="listen_it" width="50" style="vertical-align: middle; margin-right: 0.5rem; display: inline-block;" />listen_it
Event-driven architecture with easy event listening and dispatching.

**Documentation:**
- [Listen](/documentation/listen_it/listen_it.md) - Introduction to listen_it
- **Operators:**
  - [Overview](/documentation/listen_it/operators/overview.md) - All available operators
  - [Transform](/documentation/listen_it/operators/transform.md) - map, select
  - [Filter](/documentation/listen_it/operators/filter.md) - where
  - [Combine](/documentation/listen_it/operators/combine.md) - combineLatest, mergeWith
  - [Time](/documentation/listen_it/operators/time.md) - debounce
- **Collections:**
  - [Introduction](/documentation/listen_it/collections/introduction.md) - Reactive collections overview
  - [ListNotifier](/documentation/listen_it/collections/list_notifier.md) - Observable lists
  - [MapNotifier](/documentation/listen_it/collections/map_notifier.md) - Observable maps
  - [SetNotifier](/documentation/listen_it/collections/set_notifier.md) - Observable sets
  - [Notification Modes](/documentation/listen_it/collections/notification_modes.md) - Control when to notify
  - [Transactions](/documentation/listen_it/collections/transactions.md) - Batch updates
- [Best Practices](/documentation/listen_it/best_practices.md) - Production patterns and tips

## Getting Started

If you're new to flutter_it, we recommend starting with:

1. **[What to do with which package?](/getting_started/what_to_do_with_which_package.md)** - Understand which package to use for what
2. **[get_it Getting Started](/documentation/get_it/getting_started.md)** - Learn the fundamentals of dependency injection
3. **[`watch_it` Getting Started](/documentation/watch_it/getting_started.md)** - Learn reactive state management

## Examples

Check out our [examples](/examples/overview.md) to see these packages in action with real-world code samples.

## Community

- [GitHub](https://github.com/flutter-it)
- [Discord](https://discord.com/invite/Nn6GkYjzW)
- [Twitter](https://x.com/ThomasBurkhartB) 