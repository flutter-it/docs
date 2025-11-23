import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import '_shared/stubs.dart';

// #region example
class TodoManager {
  final todos = ValueNotifier<List<Todo>>([]);

  late final deleteCommand = Command.createUndoableNoResult<String, List<Todo>>(
    (id, stack) async {
      // Save state before changes
      stack.push(List<Todo>.from(todos.value));

      // Optimistic delete
      todos.value = todos.value.where((t) => t.id != id).toList();

      await getIt<ApiClient>().deleteTodo(id);
      // If this throws, state is automatically restored
    },
    undo: (stack, reason) async {
      // Restore previous state
      todos.value = stack.pop();
    },
  )..errors.listen((error, _) {
      if (error != null) {
        // State already rolled back automatically
        // Just show error message
        showSnackBar('Failed to delete: ${error.error}');
      }
    });
}
// #endregion example

void main() {
  setupDependencyInjection();

  final manager = TodoManager();
  manager.todos.value = [Todo('1', 'Test Todo', false)];

  // Test the delete with error handling
  manager.deleteCommand('1');
}
