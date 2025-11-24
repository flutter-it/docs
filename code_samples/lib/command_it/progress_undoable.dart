import 'dart:io';
import 'package:command_it/command_it.dart';
import '_shared/stubs.dart';

class UploadState {
  final String uploadId;
  UploadState(this.uploadId);
}

// Mock API methods
Future<String> startUpload(File file) async {
  await simulateDelay(50);
  return 'upload_123';
}

Future<void> cancelUpload(String uploadId) async {
  await simulateDelay(50);
}

Future<void> deleteUpload(String uploadId) async {
  await simulateDelay(50);
}

int calculateChunks(File file) => 10;

// #region example
final uploadCommand =
    Command.createUndoableWithProgress<File, String, UploadState>(
  (file, handle, undoStack) async {
    handle.updateStatusMessage('Starting upload...');
    final uploadId = await startUpload(file);
    undoStack.push(UploadState(uploadId));

    final chunks = calculateChunks(file);
    for (int i = 0; i < chunks; i++) {
      if (handle.isCanceled.value) {
        await cancelUpload(uploadId);
        return 'Canceled';
      }

      await uploadChunk(file, i);
      handle.updateProgress((i + 1) / chunks);
      handle.updateStatusMessage('Uploaded ${i + 1}/$chunks chunks');
    }

    return 'Upload complete';
  },
  undo: (undoStack, reason) async {
    final state = undoStack.pop();
    await deleteUpload(state.uploadId);
    return 'Upload deleted';
  },
  initialValue: '',
);
// #endregion example

void main() {
  // Example usage
  uploadCommand.run(File('example.txt'));
}
