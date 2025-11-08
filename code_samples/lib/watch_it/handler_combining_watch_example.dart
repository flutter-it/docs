import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class TodoList extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // WATCH for rebuilding
    final todos = watchValue((TodoManager m) => m.todos);

    // HANDLER for side effects
    registerHandler(
      select: (TodoManager m) => m.todos,
      handler: (context, todoList, cancel) {
        if (todoList.length > 5) {
          // Show message when list gets long (no rebuild needed)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You have ${todoList.length} todos!')),
          );
        }
      },
    );

    // Build UI with watched data
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) => TodoCard(todo: todos[index]),
    );
  }
}
// #endregion example

class TodoCard extends StatelessWidget {
  final TodoModel todo;
  const TodoCard({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(todo.title));
  }
}

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: TodoList()));
}
