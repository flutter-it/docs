import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
// CORRECT: All watch calls in the SAME ORDER every build
// This is the golden rule of watch_it!

class GoodWatchOrderingWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // ALWAYS call watch functions in the same order
    // Even if you don't use the value, the order matters!

    // Order: 1. todos
    final todos = watchValue((TodoManager m) => m.todos);

    // Order: 2. isLoading
    final isLoading =
        watchValue((TodoManager m) => m.fetchTodosCommand.isRunning);

    // Order: 3. counter (local state)
    final counter = createOnce(() => SimpleCounter());
    final count = watch(counter).value;

    callOnce((_) {
      di<TodoManager>().fetchTodosCommand.run();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('✓ Good Watch Ordering')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade100,
            child: const Text(
              '✓ All watch calls in same order every build',
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text('Todos count'),
            trailing: Text('${todos.length}'),
          ),
          ListTile(
            title: const Text('Loading'),
            trailing: Text(isLoading.toString()),
          ),
          ListTile(
            title: const Text('Counter'),
            trailing: Text('$count'),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () =>
                      di<TodoManager>().fetchTodosCommand.run(),
                  child: const Text('Refresh Todos'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: counter.increment,
                  child: const Text('Increment Counter'),
                ),
              ],
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
    home: GoodWatchOrderingWidget(),
  ));
}
