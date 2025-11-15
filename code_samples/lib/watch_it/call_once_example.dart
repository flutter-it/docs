import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class CallOnceWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // callOnce executes a function only once on the first build
    // Perfect replacement for initState in stateless widgets
    // Can trigger commands, initialize state, register listeners, etc.
    callOnce((_) {
      debugPrint('This runs once on first build');
      // Trigger initial data load
      di<TodoManager>().fetchTodosCommand.run();
    });

    final isLoading =
        watchValue((TodoManager m) => m.fetchTodosCommand.isRunning);
    final todos = watchValue((TodoManager m) => m.todos);

    return Scaffold(
      appBar: AppBar(title: const Text('callOnce Example')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: const Text(
              'callOnce triggered data load on first build',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          if (isLoading && todos.isEmpty)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (todos.isEmpty)
            const Expanded(
              child: Center(child: Text('No todos')),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return ListTile(
                    title: Text(todo.title),
                    subtitle: Text(todo.description),
                    leading: Checkbox(
                      value: todo.completed,
                      onChanged: (value) {},
                    ),
                  );
                },
              ),
            ),
          if (isLoading)
            const LinearProgressIndicator()
          else
            const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => di<TodoManager>().fetchTodosCommand.run(),
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
    home: CallOnceWidget(),
  ));
}
