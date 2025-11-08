import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class TodoManager {
  final todos = ValueNotifier<List<String>>([]);

  void addTodo(String todo) {
    todos.value = [...todos.value, todo]; // New list triggers update
  }
}

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
// #endregion example

void main() {
  di.registerSingleton<TodoManager>(TodoManager());
  runApp(MaterialApp(home: TodoList()));
}
