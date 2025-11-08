import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class DataInitializationWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // registerFutureHandler executes a handler when a future completes
    // Useful for one-time initialization with side effects

    registerFutureHandler(
      select: (_) => di<DataService>().fetchTodos(),
      handler: (context, snapshot, _) {
        if (snapshot.hasData) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Loaded ${snapshot.data!.length} todos'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (snapshot.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading todos: ${snapshot.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      initialValue: const <TodoModel>[],
    );

    final todos = watchValue((TodoManager m) => m.todos);

    return Scaffold(
      appBar: AppBar(title: const Text('Future Handler Example')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'This widget uses registerFutureHandler for initialization',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          Expanded(
            child: todos.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading...'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return ListTile(
                        title: Text(todo.title),
                        subtitle: Text(todo.description),
                        trailing: Checkbox(
                          value: todo.completed,
                          onChanged: (value) {},
                        ),
                      );
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

  runApp(MaterialApp(
    home: DataInitializationWidget(),
  ));
}
