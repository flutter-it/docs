import 'package:command_it/command_it.dart';
import '_shared/stubs.dart';

final api = ApiClient();

// #region cleanup_basic
class CleanupManager {
  late final sourceCommand = Command.createSync<String, String>(
    (s) => s,
    initialValue: '',
  );

  late final targetCommand = Command.createAsyncNoResult<String>(
    (s) async => api.saveContent(s),
  );

  // Store subscription for cleanup
  late final ListenableSubscription _subscription;

  CleanupManager() {
    _subscription = sourceCommand.pipeToCommand(targetCommand);
  }

  void dispose() {
    // Cancel subscription first
    _subscription.cancel();
    // Then dispose commands
    sourceCommand.dispose();
    targetCommand.dispose();
  }
}
// #endregion cleanup_basic

void main() {
  // Examples compile but don't run
}
