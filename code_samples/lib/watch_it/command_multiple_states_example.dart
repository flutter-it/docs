import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class MultipleCommandStatesWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final manager = di<TodoManager>();

    // Watch multiple aspects of the same command
    final isCreating = watch(manager.createTodoCommand.isExecuting).value;
    final createResult = watch(manager.createTodoCommand).value;
    final createError = watch(manager.createTodoCommand.errors).value;

    // Watch another command's states
    final isFetching = watch(manager.fetchTodosCommand.isExecuting).value;
    final todos = watchValue((TodoManager m) => m.todos);

    callOnce((_) {
      manager.fetchTodosCommand.execute();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Multiple Command States')),
      body: Column(
        children: [
          // Status indicators for multiple commands
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Fetch Status: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    if (isFetching)
                      const Row(
                        children: [
                          SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Loading...'),
                        ],
                      )
                    else
                      Text('${todos.length} todos loaded'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Create Status: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    if (isCreating)
                      const Row(
                        children: [
                          SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Creating...'),
                        ],
                      )
                    else if (createError != null)
                      const Text('Error', style: TextStyle(color: Colors.red))
                    else if (createResult != null)
                      const Text('Success',
                          style: TextStyle(color: Colors.green))
                    else
                      const Text('Idle'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: todos.isEmpty
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
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isFetching
                        ? null
                        : () => manager.fetchTodosCommand.execute(),
                    child: const Text('Refresh'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isCreating
                        ? null
                        : () {
                            final params = CreateTodoParams(
                              title: 'Quick Todo ${todos.length + 1}',
                              description: 'Created at ${DateTime.now()}',
                            );
                            manager.createTodoCommand.execute(params);
                          },
                    child: const Text('Create'),
                  ),
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
    home: MultipleCommandStatesWidget(),
  ));
}
