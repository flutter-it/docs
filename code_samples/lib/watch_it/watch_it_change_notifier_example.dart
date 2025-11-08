import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
// Manager that IS a ChangeNotifier
class TodoManagerChangeNotifier extends ChangeNotifier {
  List<String> _todos = [];
  List<String> get todos => _todos;

  void addTodo(String todo) {
    _todos.add(todo);
    notifyListeners(); // Notify on changes
  }
}

// Watch the whole manager
class TodoList extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final manager = watchIt<TodoManagerChangeNotifier>();

    return ListView.builder(
      itemCount: manager.todos.length,
      itemBuilder: (context, index) => Text(manager.todos[index]),
    );
  }
}
// #endregion example

void main() {
  di.registerLazySingleton<TodoManagerChangeNotifier>(
      () => TodoManagerChangeNotifier());
  runApp(MaterialApp(home: TodoList()));
}
