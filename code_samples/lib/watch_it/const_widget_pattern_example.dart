import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
// You can use const constructors with WatchItMixin
// The widget itself is const for performance, but watch_it handles reactivity internally

class TodoHeader extends StatelessWidget with WatchItMixin {
  const TodoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);
    final completedCount = todos.where((t) => t.completed).length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Row(
        children: [
          Text(
            'Total: ${todos.length}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: 16),
          Text(
            'Completed: $completedCount',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.green,
                ),
          ),
        ],
      ),
    );
  }
}

class TodoItem extends StatelessWidget with WatchItMixin {
  // Const constructor - great for performance
  const TodoItem({super.key, required this.todoId});

  final String todoId;

  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);
    final todo = todos.firstWhere((t) => t.id == todoId);

    return ListTile(
      title: Text(
        todo.title,
        style: todo.completed
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Text(todo.description),
      leading: Checkbox(
        value: todo.completed,
        onChanged: (value) {
          final updated = todo.copyWith(completed: value ?? false);
          di<TodoManager>().updateTodoCommand.execute(updated);
        },
      ),
    );
  }
}

class ConstWidgetExample extends StatelessWidget with WatchItMixin {
  const ConstWidgetExample({super.key});

  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);

    callOnce((_) {
      di<TodoManager>().fetchTodosCommand.execute();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Const Widget Pattern')),
      body: Column(
        children: [
          // Const widget with watch_it
          const TodoHeader(),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                // Each item is const - Flutter can optimize rebuilds
                return TodoItem(todoId: todos[index].id);
              },
            ),
          ),
        ],
      ),
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();

  runApp(const MaterialApp(
    home: ConstWidgetExample(),
  ));
}
