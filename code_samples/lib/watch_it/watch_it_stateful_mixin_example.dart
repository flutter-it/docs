import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
// For StatefulWidget, use WatchingStatefulWidget as the base class
// This gives you both setState AND watch_it capabilities
// Perfect for widgets that need local state + reactive state management

class ExpandableTodoCard extends WatchingStatefulWidget {
  const ExpandableTodoCard({super.key, required this.todoId});

  final String todoId;

  @override
  State<ExpandableTodoCard> createState() => _ExpandableTodoCardState();
}

class _ExpandableTodoCardState extends State<ExpandableTodoCard> {
  // Local state with setState
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Now you can use watch_it functions alongside setState!
    final todos = watchValue((TodoManager m) => m.todos);
    final todo = todos.firstWhere((t) => t.id == widget.todoId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(todo.title),
            subtitle: _isExpanded ? Text(todo.description) : null,
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                // Mix setState with watch_it
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
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
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    onPressed: () {
                      di<TodoManager>().deleteTodoCommand.execute(todo.id);
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class TodoListWithExpandable extends StatelessWidget with WatchItMixin {
  const TodoListWithExpandable({super.key});

  @override
  Widget build(BuildContext context) {
    final todos = watchValue((TodoManager m) => m.todos);
    final isLoading =
        watchValue((TodoManager m) => m.fetchTodosCommand.isExecuting);

    callOnce((_) {
      di<TodoManager>().fetchTodosCommand.execute();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Stateful Mixin Example')),
      body: isLoading && todos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return ExpandableTodoCard(todoId: todos[index].id);
              },
            ),
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();

  runApp(const MaterialApp(
    home: TodoListWithExpandable(),
  ));
}
