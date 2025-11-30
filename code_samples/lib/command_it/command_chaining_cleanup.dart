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

// #region cleanup_multiple
class MultiPipeManager {
  late final inputCommand = Command.createSync<String, String>(
    (s) => s,
    initialValue: '',
  );

  late final saveCommand = Command.createAsyncNoResult<String>(
    (s) async => api.saveContent(s),
  );

  late final logCommand = Command.createSync<String, void>(
    (s) => print('Logged: $s'),
    initialValue: null,
  );

  late final analyticsCommand = Command.createSync<String, void>(
    (s) => print('Analytics: $s'),
    initialValue: null,
  );

  // Multiple subscriptions
  final List<ListenableSubscription> _subscriptions = [];

  MultiPipeManager() {
    _subscriptions.addAll([
      inputCommand.pipeToCommand(saveCommand),
      inputCommand.pipeToCommand(logCommand),
      inputCommand.pipeToCommand(analyticsCommand),
    ]);
  }

  void dispose() {
    // Cancel all subscriptions
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();

    inputCommand.dispose();
    saveCommand.dispose();
    logCommand.dispose();
    analyticsCommand.dispose();
  }
}
// #endregion cleanup_multiple

// #region cleanup_conditional
class ConditionalPipeManager {
  late final sourceCommand = Command.createSync<String, String>(
    (s) => s,
    initialValue: '',
  );

  late final targetCommand = Command.createAsyncNoResult<String>(
    (s) async => api.saveContent(s),
  );

  ListenableSubscription? _subscription;

  void enablePipe() {
    // Only create if not already active
    _subscription ??= sourceCommand.pipeToCommand(targetCommand);
  }

  void disablePipe() {
    _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    _subscription?.cancel();
    sourceCommand.dispose();
    targetCommand.dispose();
  }
}
// #endregion cleanup_conditional

void main() {
  // Examples compile but don't run
}
