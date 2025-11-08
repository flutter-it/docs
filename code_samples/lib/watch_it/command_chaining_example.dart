import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class CommandChainingWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final manager = di<TodoManager>();

    // Use registerHandler to chain commands
    // When create succeeds, automatically refresh the list
    registerHandler(
      select: (TodoManager m) => m.createTodoCommand,
      handler: (context, result, _) {
        if (result != null) {
          // Chain: after creating, fetch the updated list
          manager.fetchTodosCommand.execute();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Created "${result.title}" and refreshed list'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );

    final isCreating = watch(manager.createTodoCommand.isExecuting).value;
    final isFetching = watch(manager.fetchTodosCommand.isExecuting).value;
    final todos = watchValue((TodoManager m) => m.todos);

    callOnce((_) {
      manager.fetchTodosCommand.execute();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Command Chaining')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: const Text(
              'This example chains commands: Create → Refresh List',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          if (isFetching)
            const LinearProgressIndicator()
          else
            const SizedBox(height: 4),
          Expanded(
            child: todos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isFetching)
                          const CircularProgressIndicator()
                        else
                          const Text('No todos'),
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
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            manager.deleteTodoCommand.execute(todo.id);
                            // Chain: after deleting, refresh
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () => manager.fetchTodosCommand.execute(),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCreating
                        ? null
                        : () {
                            final params = CreateTodoParams(
                              title: 'New Todo ${todos.length + 1}',
                              description: 'Created at ${DateTime.now()}',
                            );
                            manager.createTodoCommand.execute(params);
                          },
                    child: isCreating
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text('Creating & Refreshing...'),
                            ],
                          )
                        : const Text('Create Todo (will auto-refresh)'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: isFetching
                        ? null
                        : () => manager.fetchTodosCommand.execute(),
                    child: const Text('Manual Refresh'),
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
    home: CommandChainingWidget(),
  ));
}
