import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '_shared/stubs.dart';

// #region manager
/// Manager that holds commands - provided via ChangeNotifierProvider
class TodoManager extends ChangeNotifier {
  final ApiClient _api;

  TodoManager(this._api);

  late final loadCommand = Command.createAsyncNoParam<List<Todo>>(
    () => _api.fetchTodos(),
    initialValue: [],
  );

  late final toggleCommand = Command.createAsync<String, void>(
    (id) async {
      final todo = loadCommand.value.firstWhere((t) => t.id == id);
      _api.toggleTodo(id, !todo.completed);
      loadCommand.run(); // Refresh list
    },
    initialValue: null,
  );

  @override
  void dispose() {
    loadCommand.dispose();
    toggleCommand.dispose();
    super.dispose();
  }
}
// #endregion manager

// #region setup
/// App setup with Provider
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoManager(ApiClient()),
      child: const MaterialApp(home: TodoScreen()),
    );
  }
}
// #endregion setup

// #region granular
/// Watch specific command properties for granular rebuilds
class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get manager without listening (we'll watch specific properties)
    final manager = context.read<TodoManager>();

    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: Column(
        children: [
          // Watch just isRunning for loading indicator
          ListenableProvider<ValueListenable<bool>>.value(
            value: manager.loadCommand.isRunning,
            child: Consumer<ValueListenable<bool>>(
              builder: (context, isRunning, _) {
                if (isRunning.value) {
                  return const LinearProgressIndicator();
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          // Watch command results for the list
          Expanded(
            child: ListenableProvider<
                ValueListenable<CommandResult<void, List<Todo>>>>.value(
              value: manager.loadCommand.results,
              child: Consumer<ValueListenable<CommandResult<void, List<Todo>>>>(
                builder: (context, resultsNotifier, _) {
                  final result = resultsNotifier.value;

                  if (result.hasError) {
                    return Center(child: Text('Error: ${result.error}'));
                  }

                  final todos = result.data!;
                  if (todos.isEmpty) {
                    return const Center(child: Text('No todos'));
                  }

                  return ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return ListTile(
                        title: Text(todo.title),
                        leading: Checkbox(
                          value: todo.completed,
                          onChanged: (_) => manager.toggleCommand.run(todo.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: manager.loadCommand.run,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
// #endregion granular

// #region simple
/// Simpler approach: watch entire manager (rebuilds on any command change)
class SimpleTodoScreen extends StatelessWidget {
  const SimpleTodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<TodoManager>();
    final result = manager.loadCommand.results.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: Builder(
        builder: (context) {
          if (result.isRunning) {
            return const Center(child: CircularProgressIndicator());
          }
          if (result.hasError) {
            return Center(child: Text('Error: ${result.error}'));
          }
          return ListView.builder(
            itemCount: result.data!.length,
            itemBuilder: (context, index) {
              final todo = result.data![index];
              return ListTile(
                title: Text(todo.title),
                leading: Checkbox(
                  value: todo.completed,
                  onChanged: (_) => manager.toggleCommand.run(todo.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
// #endregion simple

void main() {
  runApp(const MyApp());
}
