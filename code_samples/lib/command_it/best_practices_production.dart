// ignore_for_file: unused_local_variable, unused_field
import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import '_shared/stubs.dart';

final api = ApiClient();

// #region retry
class DataManagerRetry {
  int retryCount = 0;
  final maxRetries = 3;
  late final Command<void, Data> loadCommand;

  DataManagerRetry() {
    loadCommand = Command.createAsyncNoParam<Data>(
      () async {
        try {
          final data = await api.fetchData();
          retryCount = 0; // Reset on success
          return data.first;
        } catch (e) {
          if (retryCount < maxRetries && e is NetworkException) {
            retryCount++;
            await Future.delayed(Duration(seconds: retryCount * 2));
            return loadCommand.runAsync(); // Retry
          }
          rethrow;
        }
      },
      initialValue: Data.empty(),
    );
  }
}
// #endregion retry

// #region optimistic
class TodoManagerOptimistic {
  final todos = ValueNotifier<List<Todo>>([]);

  late final deleteTodoCommand = Command.createAsyncNoResult<String>(
    (id) async {
      // Optimistic update
      final oldTodos = todos.value;
      todos.value = todos.value.where((t) => t.id != id).toList();

      try {
        await api.deleteTodo(id);
      } catch (e) {
        // Rollback on error
        todos.value = oldTodos;
        rethrow;
      }
    },
  );
}
// #endregion optimistic

// #region dependent
class ProfileManager {
  late final loadUserCommand = Command.createAsyncNoParam<User>(
    () => api.login('user', 'pass'),
    initialValue: User.empty(),
  );

  late final loadSettingsCommand = Command.createAsyncNoParam<Settings>(
    () => api.loadSettings(loadUserCommand.value.id),
    initialValue: Settings.empty(),
  );

  ProfileManager() {
    // When user loads, load settings
    loadUserCommand.listen((user, _) => loadSettingsCommand.run());
  }
}
// #endregion dependent

class Settings {
  final String theme;
  Settings(this.theme);
  static Settings empty() => Settings('default');
}

// #region cancellation
class SearchManagerCancel {
  CancellationToken? _currentSearch;

  late final searchCommand = Command.createAsync<String, List<Result>>(
    (query) async {
      // Cancel previous search
      _currentSearch?.cancel();

      // Create new token
      final token = CancellationToken();
      _currentSearch = token;

      try {
        final results = await api.searchWithToken(query, token);

        if (token.isCancelled) {
          throw CancelledException();
        }

        return results;
      } finally {
        if (_currentSearch == token) {
          _currentSearch = null;
        }
      }
    },
    initialValue: [],
  );
}

class CancellationToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
}

class CancelledException implements Exception {}
// #endregion cancellation

// #region undoable
class TodoManagerUndoable {
  final todos = ValueNotifier<List<Todo>>([]);

  // Undoable command with automatic rollback on failure
  late final deleteTodoCommand =
      Command.createUndoableNoResult<String, List<Todo>>(
    (id, undoStack) async {
      // Push state BEFORE the optimistic update
      undoStack.push(todos.value);

      // Optimistic update
      todos.value = todos.value.where((t) => t.id != id).toList();

      // Try to delete on server
      await api.deleteTodo(id);
      // If this throws and undoOnExecutionFailure: true, undo is called automatically
    },
    undo: (undoStack, reason) {
      // Pop and restore the previous state
      todos.value = undoStack.pop();
    },
    undoOnExecutionFailure: true, // Auto-rollback on error
  );

  // Manual undo - cast to access undo method
  void undoLastDelete() {
    (deleteTodoCommand as UndoableCommand).undo();
  }
}
// #endregion undoable

// API extension for cancellation
extension CancellationApi on ApiClient {
  Future<List<Result>> searchWithToken(
      String query, CancellationToken token) async {
    await simulateDelay();
    if (token.isCancelled) return [];
    return [Result('1', 'Result for $query')];
  }

  Future<Settings> loadSettings(String userId) async {
    await simulateDelay();
    return Settings('dark');
  }
}

void main() {
  // Examples compile but don't run
}
