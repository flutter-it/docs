import 'package:command_it/command_it.dart';
import '_shared/stubs.dart';

// #region example
// Register with get_it
// di.registerLazySingleton(() => TodoManager());

// Use commands in your managers
class TodoManager {
  final api = ApiClient();

  late final loadTodosCommand = Command.createAsyncNoParam<List<Todo>>(
    () => api.fetchTodos(),
    initialValue: [],
  );

  // Debounce search with listen_it operators
  late final searchCommand = Command.createSync<String, String>(
    (s) => s,
    initialValue: '',
  );

  TodoManager() {
    searchCommand.debounce(Duration(milliseconds: 500)).listen((term, _) {
      loadTodosCommand.run();
    });
  }
}
// #endregion example

void main() {
  final manager = TodoManager();
  manager.searchCommand('test');
}
