# WatchingWidgets

## Why Do You Need Special Widgets?

You might wonder: "Why can't I just use `watchValue()` in a regular `StatelessWidget`?"

**The problem:** `watch_it` needs to hook into your widget's lifecycle to:
1. **Subscribe** to changes when the widget builds
2. **Unsubscribe** when the widget is disposed (prevent memory leaks)
3. **Rebuild** the widget when data changes

Regular `StatelessWidget` doesn't give `watch_it` access to these lifecycle events. You need a widget that `watch_it` can hook into.

## WatchingWidget - For Widgets Without Local State

Replace `StatelessWidget` with `WatchingWidget`:

<<< @/../code_samples/lib/watch_it/watching_widgets_patterns.dart#watching_widget_basic

**Use this when:**
- Writing new widgets
- You don't need local state (`setState`)
- Simple reactive UI

## WatchingStatefulWidget - For Widgets With Local State

Use when you need both `setState` AND reactive state:

<<< @/../code_samples/lib/watch_it/watching_widgets_patterns.dart#watching_stateful_widget

**Use this when:**
- You need local UI state (filter toggles, expansion state)
- Mix `setState` with reactive updates

**Note:** Your State class automatically gets all watch functions - no mixin needed!

**Pattern:** Local state (`_showCompleted`) for UI-only preferences, reactive state (`todos`) from manager, and checkboxes call back into the manager to update data.

> **💡 Important:** With `watch_it`, you'll **rarely need StatefulWidget anymore**. Most state belongs in your managers and is accessed reactively. Even `TextEditingController` and `AnimationController` can be created with `createOnce()` in `WatchingWidget` - no StatefulWidget needed! Only use StatefulWidget for truly local UI state that requires `setState`.

## Alternative: Using Mixins

If you have **existing widgets** you don't want to change, use mixins instead:

### For Existing StatelessWidget

<<< @/../code_samples/lib/watch_it/watching_widgets_patterns.dart#mixin_stateless

### For Existing StatefulWidget

<<< @/../code_samples/lib/watch_it/watching_widgets_patterns.dart#mixin_stateful

**Why use mixins?**
- Keep existing class hierarchy
- Can use `const` constructors with `WatchItMixin`
- Minimal changes to existing code
- Perfect for gradual migration

## Quick Decision Guide

**New widget, no local state?**
→ Use `WatchingWidget`

**New widget WITH local state?**
→ Use `WatchingStatefulWidget`

**Migrating existing StatelessWidget?**
→ Add `with WatchItMixin`

**Migrating existing StatefulWidget?**
→ Add `with WatchItStatefulWidgetMixin` to the StatefulWidget (not the State!)

## Common Patterns

### Combining with Other Mixins

<<< @/../code_samples/lib/watch_it/watching_widgets_patterns.dart#combining_mixins

## See Also

- [Getting Started](/documentation/watch_it/getting_started.md) - Basic `watch_it` usage
- [Your First Watch Functions](/documentation/watch_it/your_first_watch_functions.md) - Learn `watchValue()`
- [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) - CRITICAL rules
