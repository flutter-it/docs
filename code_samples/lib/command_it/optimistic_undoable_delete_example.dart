import 'package:command_it/command_it.dart';
import 'package:listen_it/listen_it.dart';
import '_shared/stubs.dart';

// #region example
class TodoManager {
  // MapNotifier is a reactive map - widgets watching it will automatically rebuild on any data change
  final todos = MapNotifier<String, Todo>();

  late final deleteTodoCommand = Command.createUndoableNoResult<Todo, Todo>(
    (todo, stack) async {
      // Capture the todo before deletion
      stack.push(todo);

      // Make optimistic update
      todos.remove(todo.id);

      // Try to delete on server
      await getIt<ApiClient>().deleteTodo(todo.id);
      // If this throws an exception, the undo handler is called automatically
    },
    undo: (stack, reason) async {
      // Restore the deleted todo
      final deletedTodo = stack.pop();
      todos[deletedTodo.id] = deletedTodo;
    },
  );
}
// #endregion example

void main() {
  setupDependencyInjection();

  final manager = TodoManager();
  final todo = Todo('1', 'Test Todo', false);
  manager.todos[todo.id] = todo;

  // Test the delete
  manager.deleteTodoCommand(todo);
}
