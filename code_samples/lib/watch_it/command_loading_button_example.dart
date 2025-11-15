import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class LoadingButtonWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final manager = di<TodoManager>();

    // Watch command execution to show inline loading state in button
    final isRunning = watch(manager.fetchTodosCommand.isRunning).value;
    final todos = watchValue((TodoManager m) => m.todos);

    return Scaffold(
      appBar: AppBar(title: const Text('Command Loading Button')),
      body: Column(
        children: [
          Expanded(
            child: todos.isEmpty
                ? const Center(child: Text('No todos - click button to load'))
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
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // Disable button while executing
                onPressed: isRunning
                    ? null
                    : () => manager.fetchTodosCommand.run(),
                child: isRunning
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Loading...'),
                        ],
                      )
                    : const Text('Load Todos'),
              ),
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
    home: LoadingButtonWidget(),
  ));
}
