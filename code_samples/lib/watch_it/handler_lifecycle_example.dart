// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '_shared/stubs.dart';

// #region bad
// ❌ BAD: Handler inside widget that gets destroyed on parent rebuild
class ParentWidget extends StatefulWidget {
  const ParentWidget({super.key});

  @override
  State<ParentWidget> createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        color: _isHovered ? Colors.blue.shade100 : Colors.white,
        child: SaveButtonWithHandler(), // ❌ Destroyed on every hover!
      ),
    );
  }
}

class SaveButtonWithHandler extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // ❌ Handler is registered here - if parent rebuilds,
    // this widget is destroyed and handler is lost!
    registerHandler(
      select: (TodoManager m) => m.createTodoCommand.results,
      handler: (context, result, cancel) {
        if (result.hasData) {
          Navigator.of(context).pop(); // May never execute!
        }
      },
    );

    return ElevatedButton(
      onPressed: () => di<TodoManager>().createTodoCommand(
        CreateTodoParams(title: 'New', description: 'Task'),
      ),
      child: const Text('Save'),
    );
  }
}
// #endregion bad

// #region good
// ✅ GOOD: Handler in stable parent widget
class StableParentWidget extends WatchingStatefulWidget {
  const StableParentWidget({super.key});

  @override
  State<StableParentWidget> createState() => _StableParentWidgetState();
}

class _StableParentWidgetState extends State<StableParentWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // ✅ Handler registered in parent - survives child rebuilds
    registerHandler(
      select: (TodoManager m) => m.createTodoCommand.results,
      handler: (context, result, cancel) {
        if (result.hasData) {
          Navigator.of(context).pop(); // Always executes!
        }
      },
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        color: _isHovered ? Colors.blue.shade100 : Colors.white,
        child: const SaveButtonOnly(), // Child can rebuild safely
      ),
    );
  }
}

class SaveButtonOnly extends StatelessWidget {
  const SaveButtonOnly({super.key});

  @override
  Widget build(BuildContext context) {
    // Just the button - no handler here
    return ElevatedButton(
      onPressed: () => di<TodoManager>().createTodoCommand(
        CreateTodoParams(title: 'New', description: 'Task'),
      ),
      child: const Text('Save'),
    );
  }
}
// #endregion good

void main() {
  setupDependencyInjection();
}
