import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '_shared/stubs.dart';

part 'riverpod_integration.g.dart';

// #region manager
/// Manager that holds commands
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

// #region providers
/// Manager provider with cleanup
@riverpod
TodoManager todoManager(Ref ref) {
  final manager = TodoManager(ApiClient());
  ref.onDispose(() => manager.dispose());
  return manager;
}

/// Granular provider for isRunning - only rebuilds when loading state changes
@riverpod
Raw<ValueListenable<bool>> isLoading(Ref ref) {
  return ref.watch(todoManagerProvider).loadCommand.isRunning;
}

/// Granular provider for results - only rebuilds when results change
@riverpod
Raw<ValueListenable<CommandResult<void, List<Todo>>>> loadResults(Ref ref) {
  return ref.watch(todoManagerProvider).loadCommand.results;
}
// #endregion providers

// #region widget
/// Widget using granular providers
class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider).value;
    final result = ref.watch(loadResultsProvider).value;
    final manager = ref.read(todoManagerProvider);

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

// #region setup
/// App setup with ProviderScope
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(
      child: MaterialApp(home: TodoScreen()),
    );
  }
}
// #endregion setup

void main() {
  runApp(const MyApp());
}
