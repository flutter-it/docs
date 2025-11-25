import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region manager
/// Manager that holds commands - can be registered in get_it or any DI
class TodoManager {
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
      loadCommand.run();
    },
    initialValue: null,
  );

  void dispose() {
    loadCommand.dispose();
    toggleCommand.dispose();
  }
}
// #endregion manager

// #region setup
void setupDependencies() {
  getIt.registerSingleton<TodoManager>(TodoManager(ApiClient()));
}
// #endregion setup

// #region widget
/// Widget using flutter_hooks - similar to watch_it pattern!
class TodoScreen extends HookWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = getIt<TodoManager>();

    // Direct watch-style calls - like watch_it!
    final isLoading = useValueListenable(manager.loadCommand.isRunning);
    final result = useValueListenable(manager.loadCommand.results);

    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: Builder(
        builder: (context) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
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
      floatingActionButton: FloatingActionButton(
        onPressed: manager.loadCommand.run,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
// #endregion widget

// #region app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: TodoScreen());
  }
}
// #endregion app

void main() {
  setupDependencies();
  runApp(const MyApp());
}
