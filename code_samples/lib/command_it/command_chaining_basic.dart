import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import '_shared/stubs.dart';

final api = ApiClient();

// #region basic
class DataManager {
  // When saveCommand completes, automatically refresh
  late final saveCommand = Command.createAsyncNoResult<Data>(
    (data) => api.save(data),
  );

  late final refreshCommand = Command.createAsyncNoParam<List<Data>>(
    () => api.fetchData(),
    initialValue: [],
  );

  DataManager() {
    // Pipe save results to trigger refresh
    saveCommand.pipeToCommand(refreshCommand);
  }

  void dispose() {
    saveCommand.dispose();
    refreshCommand.dispose();
  }
}
// #endregion basic

// #region from_isrunning
class SpinnerManager {
  late final longRunningCommand = Command.createAsyncNoParam<Data>(
    () async {
      await Future.delayed(Duration(seconds: 5));
      return Data();
    },
    initialValue: Data.empty(),
  );

  // Command that controls a global spinner
  late final showSpinnerCommand = Command.createSync<bool, bool>(
    (show) => show,
    initialValue: false,
  );

  SpinnerManager() {
    // When long command starts/stops, update spinner
    longRunningCommand.isRunning.pipeToCommand(showSpinnerCommand);
  }
}
// #endregion from_isrunning

// #region from_results
class LoggingManager {
  late final saveCommand = Command.createAsync<Data, Data>(
    (data) async {
      await api.save(data);
      return data;
    },
    initialValue: Data.empty(),
  );

  late final logCommand = Command.createSync<CommandResult<Data, Data>, void>(
    (result) {
      if (result.hasError) {
        debugPrint('Save failed: ${result.error}');
      } else if (result.hasData) {
        debugPrint('Save succeeded: ${result.data}');
      }
    },
    initialValue: null,
  );

  LoggingManager() {
    // Pipe all results (success/error) to logging
    saveCommand.results.pipeToCommand(logCommand);
  }
}
// #endregion from_results

// #region from_valuenotifier
class FormManager {
  final selectedUserId = ValueNotifier<String>('');

  late final loadUserCommand = Command.createAsync<String, User>(
    (userId) => api.login(userId, ''),
    initialValue: User.empty(),
  );

  FormManager() {
    // When user ID changes, load user details
    selectedUserId.pipeToCommand(loadUserCommand);
  }

  void dispose() {
    selectedUserId.dispose();
    loadUserCommand.dispose();
  }
}
// #endregion from_valuenotifier

void main() {
  // Examples compile but don't run
}
