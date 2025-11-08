import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class TodoScreen extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    registerHandler(
      select: (TodoManager m) => m.todos,
      handler: (context, todos, cancel) {
        if (todos.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Todo list updated!')),
          );
        }
      },
    );

    return Scaffold(
      body: Center(child: Text('Todo Screen')),
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: TodoScreen()));
}
