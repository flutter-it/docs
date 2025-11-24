import 'package:command_it/command_it.dart';
import 'dart:io';

// #region example
void testProgressUpdates() {
  final mockCommand = MockCommand<File, String>(
    initialValue: '',
    withProgressHandle: true, // Enable progress simulation
  );

  // Simulate progress updates
  mockCommand.updateMockProgress(0.0);
  mockCommand.updateMockStatusMessage('Starting upload...');
  assert(mockCommand.progress.value == 0.0);
  assert(mockCommand.statusMessage.value == 'Starting upload...');

  mockCommand.updateMockProgress(0.5);
  mockCommand.updateMockStatusMessage('Uploading...');
  assert(mockCommand.progress.value == 0.5);

  mockCommand.mockCancel();
  assert(mockCommand.isCanceled.value == true);

  mockCommand.dispose();
}
// #endregion example

void main() {
  testProgressUpdates();
}
