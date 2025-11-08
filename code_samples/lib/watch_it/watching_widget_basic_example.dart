import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
// WatchingWidget is the simplest way to use watch_it
// It replaces StatelessWidget and provides all watch_it functionality
// No need for StatefulWidget or initState for most cases!

class TodoListBasic extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Watch reactive state - widget rebuilds when it changes
    final todos = watchValue((TodoManager m) => m.todos);
    final isLoading =
        watchValue((TodoManager m) => m.fetchTodosCommand.isExecuting);

    // callOnce replaces initState - runs once on first build
    callOnce((_) {
      debugPrint('Loading todos...');
      di<TodoManager>().fetchTodosCommand.execute();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('WatchingWidget Basic')),
      body: Column(
        children: [
          if (isLoading)
            const LinearProgressIndicator()
          else
            const SizedBox(height: 4),
          Expanded(
            child: isLoading && todos.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : todos.isEmpty
                    ? const Center(child: Text('No todos'))
                    : ListView.builder(
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          final todo = todos[index];
                          return ListTile(
                            title: Text(todo.title),
                            subtitle: Text(todo.description),
                            leading: Checkbox(
                              value: todo.completed,
                              onChanged: (value) {
                                final updated =
                                    todo.copyWith(completed: value ?? false);
                                di<TodoManager>()
                                    .updateTodoCommand
                                    .execute(updated);
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final params = CreateTodoParams(
            title: 'New Todo ${todos.length + 1}',
            description: 'Created at ${DateTime.now()}',
          );
          di<TodoManager>().createTodoCommand.execute(params);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();

  runApp(MaterialApp(
    home: TodoListBasic(),
  ));
}
