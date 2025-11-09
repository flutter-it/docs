// ignore_for_file: unused_local_variable, unreachable_from_main, undefined_class, unused_element
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region watching_widget_basic
class TodoList extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) => Text(todos[index].title),
    );
  }
}
// #endregion watching_widget_basic

// Helper class for searchable examples
class Item {
  final String name;
  Item(this.name);
}

class Manager {
  final items = ValueNotifier<List<Item>>([
    Item('Apple'),
    Item('Banana'),
    Item('Cherry'),
  ]);
}

// #region watching_stateful_widget
class SearchableList extends WatchingStatefulWidget {
  @override
  State createState() => _SearchableListState();
}

class _SearchableListState extends State<SearchableList> {
  String _query = ''; // Local state

  @override
  Widget build(BuildContext context) {
    // Reactive state - automatically rebuilds
    final items = watchValue((Manager m) => m.items);

    // Filter using local state
    final filtered = items.where((item) => item.name.contains(_query)).toList();

    return Column(
      children: [
        TextField(
          onChanged: (value) => setState(() => _query = value),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) => Text(filtered[index].name),
          ),
        ),
      ],
    );
  }
}
// #endregion watching_stateful_widget

// #region mixin_stateless
class TodoListWithMixin extends StatelessWidget with WatchItMixin {
  const TodoListWithMixin({super.key}); // Can use const!

  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) => Text(todos[index].title),
    );
  }
}
// #endregion mixin_stateless

// #region mixin_stateful
class SearchableListWithMixin extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const SearchableListWithMixin({super.key});

  @override
  State createState() => _SearchableListWithMixinState();
}

class _SearchableListWithMixinState extends State<SearchableListWithMixin> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final items = watchValue((Manager m) => m.items);
    final filtered = items.where((item) => item.name.contains(_query)).toList();

    return Column(
      children: [
        TextField(
          onChanged: (value) => setState(() => _query = value),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) => Text(filtered[index].name),
          ),
        ),
      ],
    );
  }
}
// #endregion mixin_stateful

// #region combining_mixins
class AnimatedCard extends WatchingStatefulWidget {
  @override
  State createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  // Mix with other mixins!

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final data = watchValue((DataManager m) => m.data);

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
// #endregion combining_mixins

void main() {}
