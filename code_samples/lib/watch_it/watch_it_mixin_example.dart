import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
// WatchItMixin allows you to add watch_it capabilities to existing StatelessWidget
// WITHOUT changing the class hierarchy
// Perfect for gradual migration of existing codebases!

class TodoCard extends StatelessWidget with WatchItMixin {
  const TodoCard({super.key, required this.todoId});

  final String todoId;

  @override
  Widget build(BuildContext context) {
    // Now you can use all watch_it functions!
    final todos = watchValue((TodoManager m) => m.todos);
    final todo = todos.firstWhere((t) => t.id == todoId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              todo.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(todo.description),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: todo.completed,
                  onChanged: (value) {
                    final updated = todo.copyWith(completed: value ?? false);
                    di<TodoManager>().updateTodoCommand.execute(updated);
                  },
                ),
                const Text('Completed'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    di<TodoManager>().deleteTodoCommand.execute(todo.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// You can use const constructors with WatchItMixin
// The widget itself is const, but watch_it handles reactivity internally
class TodoList extends StatelessWidget with WatchItMixin {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);
    final isLoading =
        watchValue((TodoManager m) => m.fetchTodosCommand.isExecuting);

    callOnce((_) {
      di<TodoManager>().fetchTodosCommand.execute();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('WatchItMixin Example')),
      body: isLoading && todos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return TodoCard(todoId: todos[index].id);
              },
            ),
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();

  runApp(const MaterialApp(
    home: TodoList(),
  ));
}
