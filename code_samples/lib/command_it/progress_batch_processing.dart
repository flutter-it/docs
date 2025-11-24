import 'package:command_it/command_it.dart';
import '_shared/stubs.dart';

// #region example
final batchCommand = Command.createAsyncWithProgress<List<Item>, String>(
  (items, handle) async {
    final total = items.length;
    int processed = 0;

    for (final item in items) {
      if (handle.isCanceled.value) {
        return 'Canceled ($processed/$total processed)';
      }

      await processItem(item);
      processed++;

      handle.updateProgress(processed / total);
      handle.updateStatusMessage('Processed $processed of $total items');
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
