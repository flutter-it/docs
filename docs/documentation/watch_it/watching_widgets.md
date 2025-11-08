# WatchingWidgets

## Why Do You Need Special Widgets?

You might wonder: "Why can't I just use `watchValue()` in a regular `StatelessWidget`?"

**The problem:** watch_it needs to hook into your widget's lifecycle to:
1. **Subscribe** to changes when the widget builds
2. **Unsubscribe** when the widget is disposed (prevent memory leaks)
3. **Rebuild** the widget when data changes

Regular `StatelessWidget` doesn't give watch_it access to these lifecycle events. You need a widget that watch_it can hook into.

## WatchingWidget - For Widgets Without Local State

Replace `StatelessWidget` with `WatchingWidget`:

```dart
class TodoList extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) => Text(todos[index]),
    );
  }
}
```

**Use this when:**
- Writing new widgets
- You don't need local state (`setState`)
- Simple reactive UI

## WatchingStatefulWidget - For Widgets With Local State

Use when you need both `setState` AND reactive state:

```dart
class SearchableList extends WatchingStatefulWidget {
  @override
  State createState() => _SearchableListState();
}

class _SearchableListState extends State<SearchableList> {
  String _query = '';  // Local state

  @override
  Widget build(BuildContext context) {
    // Reactive state - automatically rebuilds
    final items = watchValue((Manager m) => m.items);

    // Filter using local state
    final filtered = items.where((item) =>
      item.name.contains(_query)
    ).toList();

    return Column(
      children: [
        TextField(
          onChanged: (value) => setState(() => _query = value),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) => Text(filtered[index]),
          ),
        ),
      ],
    );
  }
}
```

**Use this when:**
- You need local UI state (search queries, form input, expansion state)
- You need animation controllers
- Mix `setState` with reactive updates

**Note:** Your State class automatically gets all watch functions - no mixin needed!

## Alternative: Using Mixins

If you have **existing widgets** you don't want to change, use mixins instead:

### For Existing StatelessWidget

```dart
class TodoList extends StatelessWidget with WatchItMixin {
  const TodoList({super.key});  // Can use const!

  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);
    return ListView(...);
  }
}
```

### For Existing StatefulWidget

```dart
class SearchableList extends StatefulWidget with WatchItStatefulWidgetMixin {
  const SearchableList({super.key});

  @override
  State createState() => _SearchableListState();
}

class _SearchableListState extends State<SearchableList> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final items = watchValue((Manager m) => m.items);
    // ... rest of your code
  }
}
```

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

```dart
class AnimatedCard extends WatchingStatefulWidget {
  @override
  State createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {  // Mix with other mixins!

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final data = watchValue((Manager m) => m.data);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: _controller.value,
        child: Text(data),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

## See Also

- [Getting Started](/documentation/watch_it/getting_started.md) - Basic watch_it usage
- [Your First Watch Functions](/documentation/watch_it/your_first_watch_functions.md) - Learn `watchValue()`
- [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) - CRITICAL rules
