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

// #region watching_stateful_widget
class TodoListWithFilter extends WatchingStatefulWidget {
  @override
  State createState() => _TodoListWithFilterState();
}

class _TodoListWithFilterState extends State<TodoListWithFilter> {
  bool _showCompleted = true; // Local UI state

  @override
  Widget build(BuildContext context) {
    // Reactive state - rebuilds when todos change
    final todos = watchValue((TodoManager m) => m.todos);

    // Filter based on local state
    final filtered = _showCompleted
        ? todos
        : todos.where((todo) => !todo.completed).toList();

    return Column(
      children: [
        SwitchListTile(
          title: Text('Show completed'),
          value: _showCompleted,
          onChanged: (value) => setState(() => _showCompleted = value),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) => CheckboxListTile(
              title: Text(filtered[index].title),
              value: filtered[index].completed,
              onChanged: (_) => di<TodoManager>().updateTodoCommand.execute(
                  filtered[index]
                      .copyWith(completed: !filtered[index].completed)),
            ),
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
class TodoListWithFilterMixin extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const TodoListWithFilterMixin({super.key});

  @override
  State createState() => _TodoListWithFilterMixinState();
}

class _TodoListWithFilterMixinState extends State<TodoListWithFilterMixin> {
  bool _showCompleted = true;

  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);
    final filtered = _showCompleted
        ? todos
        : todos.where((todo) => !todo.completed).toList();

    return Column(
      children: [
        SwitchListTile(
          title: Text('Show completed'),
          value: _showCompleted,
          onChanged: (value) => setState(() => _showCompleted = value),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) => CheckboxListTile(
              title: Text(filtered[index].title),
              value: filtered[index].completed,
              onChanged: (_) => di<TodoManager>().updateTodoCommand.execute(
                  filtered[index]
                      .copyWith(completed: !filtered[index].completed)),
            ),
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
