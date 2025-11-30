import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import '_shared/stubs.dart';

final api = ApiClient();

// #region basic
class DataManager {
  late final refreshCommand = Command.createAsyncNoParam<List<Data>>(
    () => api.fetchData(),
    initialValue: [],
  );

  // When saveCommand completes, automatically refresh
  late final saveCommand = Command.createAsyncNoResult<Data>(
    (data) => api.save(data),
  )..pipeToCommand(refreshCommand);

  void dispose() {
    saveCommand.dispose();
    refreshCommand.dispose();
  }
}
// #endregion basic

// #region from_isrunning
class SpinnerManager {
  // Command that controls a global spinner
  late final showSpinnerCommand = Command.createSync<bool, bool>(
    (show) => show,
    initialValue: false,
  );

  // When long command starts/stops, update spinner
  late final longRunningCommand = Command.createAsyncNoParam<Data>(
    () async {
      await Future.delayed(Duration(seconds: 5));
      return Data();
    },
    initialValue: Data.empty(),
  )..isRunning.pipeToCommand(showSpinnerCommand);
}
// #endregion from_isrunning

// #region from_results
class LoggingManager {
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

  // Pipe all results (success/error) to logging
  late final saveCommand = Command.createAsync<Data, Data>(
    (data) async {
      await api.save(data);
      return data;
    },
    initialValue: Data.empty(),
  )..results.pipeToCommand(logCommand);
}
// #endregion from_results

// #region from_valuenotifier
class FormManager {
  late final loadUserCommand = Command.createAsync<String, User>(
    (userId) => api.login(userId, ''),
    initialValue: User.empty(),
  );

  // When user ID changes, load user details
  late final selectedUserId = ValueNotifier<String>('')
    ..pipeToCommand(loadUserCommand);

  void dispose() {
    selectedUserId.dispose();
    loadUserCommand.dispose();
  }
}
// #endregion from_valuenotifier

void main() {
  // Examples compile but don't run
}
