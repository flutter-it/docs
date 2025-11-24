import 'package:command_it/command_it.dart';
import '_shared/stubs.dart';

// #region example
// Full signature: parameter + result
final processCommand = Command.createAsyncWithProgress<int, String>(
  (count, handle) async {
    for (int i = 0; i < count; i++) {
      if (handle.isCanceled.value) return 'Canceled';

      await processItem(Item());
      handle.updateProgress((i + 1) / count);
      handle.updateStatusMessage('Processing item ${i + 1} of $count');
    }
    return 'Processed $count items';
  },
  initialValue: '',
);

// No parameter
final syncCommand = Command.createAsyncNoParamWithProgress<String>(
  (handle) async {
    handle.updateStatusMessage('Syncing...');
    handle.updateProgress(0.5);
    await simulateDelay(100);
    handle.updateProgress(1.0);
    return 'Synced';
  },
  initialValue: '',
);

// No result (void)
final deleteCommand = Command.createAsyncNoResultWithProgress<int>(
  (itemId, handle) async {
    handle.updateStatusMessage('Deleting item $itemId...');
    await simulateDelay(100);
    handle.updateProgress(1.0);
  },
);

// No parameter, no result
final refreshCommand = Command.createAsyncNoParamNoResultWithProgress(
  (handle) async {
    handle.updateStatusMessage('Refreshing...');
    await simulateDelay(100);
    handle.updateProgress(1.0);
  },
);
// #endregion example

void main() {
  // Example usage
  processCommand.run(5);
  syncCommand.run();
  deleteCommand.run(123);
  refreshCommand.run();
}
