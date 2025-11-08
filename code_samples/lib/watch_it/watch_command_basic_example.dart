import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class TodoLoadingWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Watch command's isExecuting property to show loading state
    // This is the most common pattern for reactive loading indicators
    final isLoading =
        watchValue((TodoManager m) => m.fetchTodosCommand.isExecuting);
    final todos = watchValue((TodoManager m) => m.todos);

    // Load data on first build
    callOnce((_) {
      di<TodoManager>().fetchTodosCommand.execute();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Watch Command - Loading State')),
      body: Column(
        children: [
          // Show loading indicator when command is executing
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
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              // Disable button while loading
              onPressed: isLoading
                  ? null
                  : () => di<TodoManager>().fetchTodosCommand.execute(),
              child: const Text('Refresh'),
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

  runApp(MaterialApp(
    home: TodoLoadingWidget(),
  ));
}
