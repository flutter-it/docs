import 'package:command_it/command_it.dart';
import '_shared/stubs.dart';

// #region example
final batchCommand = Command.createAsyncWithProgress<List<Item>, String>(
  (items, handle) async {
    final total = items.length;
    int current = 0;

    for (final item in items) {
      if (handle.isCanceled.value) {
        return 'Canceled ($current/$total processed)';
      }

      current++;
      handle.updateStatusMessage('Processing item $current of $total');

      // Process item with per-item progress
      const steps = 10;
      for (int step = 0; step <= steps; step++) {
        if (handle.isCanceled.value) {
          return 'Canceled ($current/$total processed)';
        }

        handle.updateProgress(step / steps);
        await simulateDelay(50); // Simulate work step
      }
    }

    return 'Processed $total items';
  },
  initialValue: '',
);
// #endregion example

void main() {
  // Example usage
  final items = [Item(), Item(), Item()];
  batchCommand.run(items);
}
