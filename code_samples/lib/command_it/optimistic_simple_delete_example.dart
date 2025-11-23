import 'package:command_it/command_it.dart';
import 'package:listen_it/listen_it.dart';
import '_shared/stubs.dart';

// #region example
class TodoManager {
  // MapNotifier is a reactive map - widgets watching it will automatically rebuild on any data change
  final todos = MapNotifier<String, Todo>();

  late final deleteCommand = Command.createAsyncNoResult<Todo>(
    (todo) async {
      // Optimistic delete
      todos.remove(todo.id);

      // Sync to server
      await getIt<ApiClient>().deleteTodo(todo.id);
    },
  )..errors.listen((error, _) {
      if (error != null) {
        // Restore the deleted todo
        final todo = error.paramData as Todo;
        todos[todo.id] = todo;

        showSnackBar('Failed to delete: ${error.error}');
      }
    });
}
// #endregion example

void main() {
  setupDependencyInjection();

  final manager = TodoManager();
  final todo = Todo('1', 'Test Todo', false);
  manager.todos[todo.id] = todo;

  // Test the delete
  manager.deleteCommand(todo);
}
