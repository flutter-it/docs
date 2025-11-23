import 'package:command_it/command_it.dart';
import 'package:listen_it/listen_it.dart';
import '_shared/stubs.dart';

// #region example
class TodoManager {
  // MapNotifier is a reactive map - widgets watching it will automatically rebuild on any data change
  final todos = MapNotifier<String, Todo>();

  late final toggleCompleteCommand =
      Command.createUndoableNoResult<String, Todo>(
    (id, stack) async {
      // Capture the todo before modification
      final todo = todos[id]!;
      stack.push(todo);

      // Optimistic toggle
      todos[id] = todo.copyWith(completed: !todo.completed);

      // Sync to server
      await getIt<ApiClient>().toggleTodo(id, todos[id]!.completed);
    },
    undo: (stack, reason) async {
      // Restore the previous todo state
      final previousTodo = stack.pop();
      todos[previousTodo.id] = previousTodo;
    },
  );
}
// #endregion example

void main() {
  setupDependencyInjection();

  final manager = TodoManager();
  final todo = Todo('1', 'Test Todo', false);
  manager.todos[todo.id] = todo;

  // Test the toggle
  manager.toggleCompleteCommand('1');
}
