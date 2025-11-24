import 'package:command_it/command_it.dart';
import 'dart:io';
import '_shared/stubs.dart';

// #region example
final uploadCommand = Command.createAsyncWithProgress<File, String>(
  (file, handle) async {
    for (int i = 0; i <= 100; i += 10) {
      if (handle.isCanceled.value) return 'Canceled';

      await uploadChunk(file, i);
      handle.updateProgress(i / 100.0);
      handle.updateStatusMessage('Uploading: $i%');
    }
    return 'Complete';
  },
  initialValue: '',
);
// #endregion example

void main() {
  // Example usage
  uploadCommand.run(File('example.txt'));
}
