import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import '_shared/stubs.dart';

final api = ApiClient();

// #region transform_basic
class UserManager {
  final selectedUserId = ValueNotifier<int>(0);

  // Command expects String, but we have int
  late final fetchUserCommand = Command.createAsync<String, User>(
    (userId) => api.login(userId, ''),
    initialValue: User.empty(),
  );

  UserManager() {
    // Transform int to String
    selectedUserId.pipeToCommand(
      fetchUserCommand,
      transform: (id) => id.toString(),
    );
  }
}
// #endregion transform_basic

// #region transform_complex
class FetchParams {
  final String userId;
  final bool includeDetails;

  FetchParams(this.userId, {this.includeDetails = true});
}

class DetailedUserManager {
  final selectedUserId = ValueNotifier<String>('');

  late final fetchUserCommand = Command.createAsync<FetchParams, User>(
    (params) => api.login(params.userId, ''),
    initialValue: User.empty(),
  );

  DetailedUserManager() {
    // Transform simple ID to complex params object
    selectedUserId.pipeToCommand(
      fetchUserCommand,
      transform: (id) => FetchParams(id, includeDetails: true),
    );
  }
}
// #endregion transform_complex

// #region transform_result
class ResultTransformManager {
  late final saveCommand = Command.createAsync<Data, Data>(
    (data) async {
      await api.save(data);
      return data;
    },
    initialValue: Data.empty(),
  );

  // Notification command only needs a message
  late final notifyCommand = Command.createSync<String, void>(
    (message) => debugPrint('Notification: $message'),
    initialValue: null,
  );

  ResultTransformManager() {
    // Transform Data result to notification message
    saveCommand.pipeToCommand(
      notifyCommand,
      transform: (data) => 'Saved item: ${data.id}',
    );
  }
}
// #endregion transform_result

void main() {
  // Examples compile but don't run
}
