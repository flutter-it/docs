import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class TodoListWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // watchValue selects a specific ValueListenable from a get_it registered object
    // Widget rebuilds only when that specific ValueListenable changes
    final todos = watchValue((TodoManager m) => m.todos);
    final isLoading =
        watchValue((TodoManager m) => m.fetchTodosCommand.isRunning);

    // Load todos on first build
    callOnce((_) {
      di<TodoManager>().fetchTodosCommand.run();
    });

    if (isLoading && todos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (todos.isEmpty) {
      return const Center(child: Text('No todos yet'));
    }

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return ListTile(
          title: Text(todo.title),
          subtitle: Text(todo.description),
          leading: Checkbox(
            value: todo.completed,
            onChanged: (value) {
              final updated = todo.copyWith(completed: value ?? false);
              di<TodoManager>().updateTodoCommand.run(updated);
            },
          ),
        );
      },
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();

  runApp(MaterialApp(
    home: Scaffold(
      body: TodoListWidget(),
    ),
  ));
}
