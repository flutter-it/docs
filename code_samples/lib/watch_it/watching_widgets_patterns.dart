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

// Helper class for settings example
class SettingsManager {
  final notificationsEnabled = ValueNotifier<bool>(true);
  final itemCount = ValueNotifier<int>(0);

  void toggleNotifications(bool enabled) {
    notificationsEnabled.value = enabled;
  }
}

// #region watching_stateful_widget
class NotificationToggle extends WatchingStatefulWidget {
  @override
  State createState() => _NotificationToggleState();
}

class _NotificationToggleState extends State<NotificationToggle> {
  bool _isAnimating = false; // Local UI state for animation

  @override
  Widget build(BuildContext context) {
    // Reactive state - automatically rebuilds when manager changes
    final enabled = watchValue((SettingsManager m) => m.notificationsEnabled);

    return SwitchListTile(
      title: Text('Notifications'),
      subtitle: _isAnimating ? Text('Updating...') : null,
      value: enabled,
      onChanged: (value) async {
        // Update local state for immediate UI feedback
        setState(() => _isAnimating = true);

        // Update manager (business logic)
        di<SettingsManager>().toggleNotifications(value);

        // Simulate async operation (API call, etc.)
        await Future.delayed(Duration(milliseconds: 500));

        // Clear local animation state
        if (mounted) {
          setState(() => _isAnimating = false);
        }
      },
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
class NotificationToggleWithMixin extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const NotificationToggleWithMixin({super.key});

  @override
  State createState() => _NotificationToggleWithMixinState();
}

class _NotificationToggleWithMixinState
    extends State<NotificationToggleWithMixin> {
  bool _isAnimating = false;

  @override
  Widget build(BuildContext context) {
    final enabled = watchValue((SettingsManager m) => m.notificationsEnabled);

    return SwitchListTile(
      title: Text('Notifications'),
      subtitle: _isAnimating ? Text('Updating...') : null,
      value: enabled,
      onChanged: (value) async {
        setState(() => _isAnimating = true);
        di<SettingsManager>().toggleNotifications(value);
        await Future.delayed(Duration(milliseconds: 500));
        if (mounted) {
          setState(() => _isAnimating = false);
        }
      },
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
