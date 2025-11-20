import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '_shared/stubs.dart';

// #region example
class TodoService {
  final api = ApiClient();

  late final loadTodosCommand = Command.createAsyncNoParam<List<Todo>>(
    () => api.fetchTodos(),
    initialValue: [],
  );

  late final addTodoCommand = Command.createAsyncNoResult<Todo>(
    (todo) async {
      await simulateDelay();
      // After adding, reload the list
      loadTodosCommand.run();
    },
  );
}

// Register with get_it
void setupDependencies() {
  GetIt.instance.registerLazySingleton<TodoService>(() => TodoService());
}

// Using watch_it to observe commands without builders
class TodoListWidget extends WatchingWidget {
  const TodoListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the command result directly
    final todos = watchValue((TodoService s) => s.loadTodosCommand);

    // Watch loading state
    final isLoading =
        watchValue((TodoService s) => s.loadTodosCommand.isRunning);

    // Watch canRun for the add command
    final canAdd = watchValue((TodoService s) => s.addTodoCommand.canRun);

    final service = GetIt.instance<TodoService>();

    return Scaffold(
      appBar: AppBar(title: Text('Todos')),
      body: Column(
        children: [
          if (isLoading) LinearProgressIndicator() else SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  title: Text(todo.title),
                  leading: Checkbox(
                    value: todo.completed,
                    onChanged: null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: canAdd
            ? () => service
                .addTodoCommand(Todo('${todos.length + 1}', 'New Todo', false))
            : null,
        child: Icon(Icons.add),
      ),
    );
  }
}

// Alternative: Watch CommandResult for comprehensive state
class TodoListWithResultWidget extends WatchingWidget {
  const TodoListWithResultWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the complete result object
    final result = watchValue(
      (TodoService s) => s.loadTodosCommand.results,
    );

    final service = GetIt.instance<TodoService>();

    return Scaffold(
      appBar: AppBar(title: Text('Todos')),
      body: () {
        // Use result to handle all states
        if (result.isRunning) {
          return Center(child: CircularProgressIndicator());
        }

        if (result.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 48),
                SizedBox(height: 16),
                Text('Error: ${result.error}'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: service.loadTodosCommand.run,
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (result.hasData && result.data!.isNotEmpty) {
          return ListView.builder(
            itemCount: result.data!.length,
            itemBuilder: (context, index) {
              final todo = result.data![index];
              return ListTile(
                title: Text(todo.title),
                leading: Checkbox(
                  value: todo.completed,
                  onChanged: null,
                ),
              );
            },
          );
        }

        return Center(child: Text('No todos'));
      }(),
    );
  }
}
// #endregion example

void main() {
  setupDependencies();
  runApp(MaterialApp(home: TodoListWidget()));
}
