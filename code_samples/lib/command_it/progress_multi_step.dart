import 'package:command_it/command_it.dart';
import '_shared/stubs.dart';

// #region example
final multiStepCommand = Command.createAsyncWithProgress<void, String>(
  (_, handle) async {
    // Step 1: Download (0-40%)
    handle.updateStatusMessage('Downloading data...');
    await downloadData();
    handle.updateProgress(0.4);

    // Step 2: Process (40-80%)
    handle.updateStatusMessage('Processing data...');
    await processData();
    handle.updateProgress(0.8);

    // Step 3: Save (80-100%)
    handle.updateStatusMessage('Saving results...');
    await saveResults();
    handle.updateProgress(1.0);

    return 'Complete';
  },
  initialValue: '',
);
// #endregion example

void main() {
  // Example usage
  multiStepCommand.run();
}
