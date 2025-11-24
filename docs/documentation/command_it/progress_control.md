# Progress Control

Commands support built-in **progress tracking**, **status messages**, and **cooperative cancellation** through the `ProgressHandle` class. This enables you to provide rich feedback to users during long-running operations like file uploads, data synchronization, or batch processing.

## Overview

Progress Control provides three key capabilities:

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Progress tracking</strong> - Report operation progress from 0.0 (0%) to 1.0 (100%)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Status messages</strong> - Provide human-readable status updates during execution</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Cooperative cancellation</strong> - Allow operations to be canceled gracefully</li>
</ul>

**Key benefits:**

- **Zero overhead** - Commands without progress use static default notifiers (no memory cost)
- **Non-nullable API** - All progress properties available on every command
- **Type-safe** - Full type inference and compile-time checking
- **Reactive** - All properties are <code>ValueListenable</code> for UI observation
- **Test-friendly** - MockCommand supports full progress simulation

## Quick Example

<<< @/../code_samples/lib/command_it/progress_upload_basic.dart#example

```dart
// In UI (with watch_it):
final progress = watchValue((MyService s) => s.uploadCommand.progress);
final status = watchValue((MyService s) => s.uploadCommand.statusMessage);

LinearProgressIndicator(value: progress)  // 0.0 to 1.0
Text(status ?? '')  // 'Uploading: 50%'
IconButton(
  onPressed: uploadCommand.cancel,  // Request cancellation
  icon: Icon(Icons.cancel),
)
```

## Creating Commands with Progress

Use the `WithProgress` factory variants to create commands that receive a `ProgressHandle`:

### Async Commands with Progress

```dart
// Full signature: parameter + result
final processCommand = Command.createAsyncWithProgress<int, String>(
  (count, handle) async {
    for (int i = 0; i < count; i++) {
      if (handle.isCanceled.value) return 'Canceled';

      await processItem(i);
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
    await syncData();
    handle.updateProgress(1.0);
    return 'Synced';
  },
  initialValue: '',
);

// No result (void)
final deleteCommand = Command.createAsyncNoResultWithProgress<int>(
  (itemId, handle) async {
    handle.updateStatusMessage('Deleting item $itemId...');
    await api.delete(itemId);
    handle.updateProgress(1.0);
  },
);

// No parameter, no result
final refreshCommand = Command.createAsyncNoParamNoResultWithProgress(
  (handle) async {
    handle.updateStatusMessage('Refreshing...');
    await api.refresh();
    handle.updateProgress(1.0);
  },
);
```

### Undoable Commands with Progress

Combine undo capability with progress tracking:

```dart
final uploadCommand = Command.createUndoableWithProgress<File, String, UploadState>(
  (file, handle, undoStack) async {
    handle.updateStatusMessage('Starting upload...');
    final uploadId = await api.startUpload(file);
    undoStack.push(UploadState(uploadId));

    final chunks = calculateChunks(file);
    for (int i = 0; i < chunks; i++) {
      if (handle.isCanceled.value) {
        await api.cancelUpload(uploadId);
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
    await api.deleteUpload(state.uploadId);
    return 'Upload deleted';
  },
  initialValue: '',
);
```

All four undoable variants are available:
- `createUndoableWithProgress<TParam, TResult, TUndoState>()`
- `createUndoableNoParamWithProgress<TResult, TUndoState>()`
- `createUndoableNoResultWithProgress<TParam, TUndoState>()`
- `createUndoableNoParamNoResultWithProgress<TUndoState>()`

## Progress Properties

All commands (even those without progress) expose these properties:

### progress

Observable progress value from 0.0 (0%) to 1.0 (100%):

```dart
final command = Command.createAsyncWithProgress<void, String>(
  (_, handle) async {
    handle.updateProgress(0.0);   // Start
    await step1();
    handle.updateProgress(0.33);  // 33%
    await step2();
    handle.updateProgress(0.66);  // 66%
    await step3();
    handle.updateProgress(1.0);   // Complete
    return 'Done';
  },
  initialValue: '',
);

// In UI:
final progress = watchValue((MyService s) => s.command.progress);
LinearProgressIndicator(value: progress)  // Flutter progress bar
```

**Type:** <code>ValueListenable&lt;double&gt;</code>
**Range:** 0.0 to 1.0 (inclusive)
**Default:** 0.0 for commands without `ProgressHandle`

### statusMessage

Observable status message providing human-readable operation status:

```dart
handle.updateStatusMessage('Downloading...');
handle.updateStatusMessage('Processing...');
handle.updateStatusMessage(null);  // Clear message

// In UI:
final status = watchValue((MyService s) => s.command.statusMessage);
Text(status ?? 'Idle')
```

**Type:** <code>ValueListenable&lt;String?&gt;</code>
**Default:** `null` for commands without `ProgressHandle`

### isCanceled

Observable cancellation flag. The wrapped function should check this periodically and handle cancellation cooperatively:

```dart
final command = Command.createAsyncWithProgress<void, String>(
  (_, handle) async {
    for (int i = 0; i < 100; i++) {
      // Check cancellation before each iteration
      if (handle.isCanceled.value) {
        return 'Canceled at step $i';
      }

      await processStep(i);
      handle.updateProgress((i + 1) / 100);
    }
    return 'Complete';
  },
  initialValue: '',
);

// In UI:
final isCanceled = watchValue((MyService s) => s.command.isCanceled);
if (isCanceled) Text('Operation canceled')
```

**Type:** <code>ValueListenable&lt;bool&gt;</code>
**Default:** `false` for commands without `ProgressHandle`

### cancel()

Request cooperative cancellation of the operation:

```dart
// In UI:
IconButton(
  onPressed: command.cancel,
  icon: Icon(Icons.cancel),
)

// Or programmatically:
if (userNavigatedAway) {
  command.cancel();
}
```

**Important:** This does **not** forcibly stop execution. The wrapped function must check `isCanceled.value` and respond appropriately (e.g., return early, throw exception, clean up resources).

### resetProgress()

Manually reset or initialize progress state:

```dart
// Reset to defaults (0.0, null, false)
command.resetProgress();

// Initialize to specific values (e.g., resuming an operation)
command.resetProgress(
  progress: 0.5,
  statusMessage: 'Resuming upload...',
);

// Clear 100% progress after completion
if (command.progress.value == 1.0) {
  await Future.delayed(Duration(seconds: 2));
  command.resetProgress();
}
```

**Parameters:**
- `progress` - Optional initial progress value (0.0-1.0), defaults to 0.0
- `statusMessage` - Optional initial status message, defaults to null

**Use cases:**
- Clear 100% progress from UI after successful completion
- Initialize commands to resume from a specific point
- Reset progress between manual executions
- Prepare command state for testing

**Note:** Progress is automatically reset at the start of each `run()` execution, so manual resets are typically only needed for UI cleanup or resuming operations.

## Integration Patterns

### With Flutter Progress Indicators

```dart
// Linear progress bar
final progress = watchValue((MyService s) => s.uploadCommand.progress);
LinearProgressIndicator(value: progress)

// Circular progress indicator
CircularProgressIndicator(value: progress)

// Custom progress display
Text('${(progress * 100).toInt()}% complete')
```

### With External Cancellation Tokens

The `isCanceled` property is a `ValueListenable`, allowing you to forward cancellation to external libraries like Dio:

```dart
final downloadCommand = Command.createAsyncWithProgress<String, File>(
  (url, handle) async {
    final dio = Dio();
    final cancelToken = CancelToken();

    // Forward command cancellation to Dio
    handle.isCanceled.listen((canceled, _) {
      if (canceled) cancelToken.cancel('User canceled');
    });

    try {
      final response = await dio.download(
        url,
        '/downloads/file.zip',
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            handle.updateProgress(received / total);
            handle.updateStatusMessage(
              'Downloaded ${(received / 1024 / 1024).toStringAsFixed(1)} MB '
              'of ${(total / 1024 / 1024).toStringAsFixed(1)} MB'
            );
          }
        },
      );
      return File('/downloads/file.zip');
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return File('');  // Handle cancellation
      }
      rethrow;
    }
  },
  initialValue: File(''),
);
```

### With CommandBuilder

CommandBuilder automatically exposes progress properties for easy UI integration:

```dart
CommandBuilder<File, String>(
  command: uploadCommand,
  whileRunning: (context, lastResult, param) {
    final progress = uploadCommand.progress.value;
    final status = uploadCommand.statusMessage.value;

    return Column(
      children: [
        LinearProgressIndicator(value: progress),
        SizedBox(height: 8),
        Text(status ?? 'Processing...'),
        TextButton(
          onPressed: uploadCommand.cancel,
          child: Text('Cancel'),
        ),
      ],
    );
  },
  onData: (context, result, param) => Text('Result: $result'),
)
```

## Commands Without Progress

Commands created with regular factories (without `WithProgress`) still have progress properties, but they return default values:

```dart
final command = Command.createAsync<void, String>(
  (_) async => 'Done',
  initialValue: '',
);

// These properties exist but return defaults:
command.progress.value        // Always 0.0
command.statusMessage.value   // Always null
command.isCanceled.value      // Always false
command.cancel()              // Does nothing
```

This zero-overhead design means:
- <ul style="list-style: none; padding-left: 0;"><li style="padding-left: 1.5em; text-indent: -1.5em;">✅ UI code can always access progress properties without null checks</li></ul>
- <ul style="list-style: none; padding-left: 0;"><li style="padding-left: 1.5em; text-indent: -1.5em;">✅ No memory cost for commands that don't need progress</li></ul>
- <ul style="list-style: none; padding-left: 0;"><li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Easy to add progress to existing commands later (just change factory)</li></ul>

## Testing with MockCommand

MockCommand supports full progress simulation for testing:

<<< @/../code_samples/lib/command_it/progress_mock_testing.dart#example

**MockCommand progress methods:**
- `updateMockProgress(double value)` - Simulate progress updates
- `updateMockStatusMessage(String? message)` - Simulate status updates
- `mockCancel()` - Simulate cancellation

All require `withProgressHandle: true` in the constructor.

See [Testing](testing.md) for more details.

## Best Practices

### DO: Check cancellation frequently

```dart
// ✅ Good - check before each expensive operation
for (final item in items) {
  if (handle.isCanceled.value) return 'Canceled';
  await processItem(item);
  handle.updateProgress(progress);
}
```

### DON'T: Check cancellation too infrequently

```dart
// ❌ Bad - only checks once at start
if (handle.isCanceled.value) return 'Canceled';
for (final item in items) {
  await processItem(item);  // Can't cancel during processing
}
```

### DO: Provide meaningful status messages

```dart
// ✅ Good - specific, actionable information
handle.updateStatusMessage('Uploading file 3 of 10...');
handle.updateStatusMessage('Processing image (1.2 MB)...');
handle.updateStatusMessage('Verifying upload integrity...');
```

### DON'T: Use vague status messages

```dart
// ❌ Bad - not helpful to users
handle.updateStatusMessage('Working...');
handle.updateStatusMessage('Please wait...');
```

### DO: Update progress accurately

```dart
// ✅ Good - progress matches actual work done
final total = items.length;
for (int i = 0; i < total; i++) {
  await processItem(items[i]);
  handle.updateProgress((i + 1) / total);  // Accurate progress
}
```

### DON'T: Set progress to 1.0 prematurely

```dart
// ❌ Bad - progress at 100% but still working
handle.updateProgress(1.0);
await finalizeOperation();  // Still working after "100%"
```

### DO: Clean up on cancellation

```dart
// ✅ Good - cleanup resources on cancel
if (handle.isCanceled.value) {
  await cleanupPartialUpload(uploadId);
  await deleteTemporaryFiles();
  return 'Canceled';
}
```

## Performance Considerations

**Progress updates are lightweight** - each update is just a ValueNotifier assignment. However, avoid excessive updates:

```dart
// ❌ Potentially excessive - updates every byte
for (int i = 0; i < 1000000; i++) {
  process(i);
  handle.updateProgress(i / 1000000);  // 1M UI updates!
}

// ✅ Better - throttle updates
final updateInterval = 1000000 ~/ 100;  // Update every 1%
for (int i = 0; i < 1000000; i++) {
  process(i);
  if (i % updateInterval == 0) {
    handle.updateProgress(i / 1000000);  // 100 UI updates
  }
}
```

For very high-frequency operations, consider updating every N iterations or using a timer to throttle updates.

## Common Patterns

### Multi-Step Operations

<<< @/../code_samples/lib/command_it/progress_multi_step.dart#example

### Batch Processing with Progress

<<< @/../code_samples/lib/command_it/progress_batch_processing.dart#example

### Indeterminate Progress

For operations where progress can't be calculated:

```dart
final command = Command.createAsyncWithProgress<void, String>(
  (_, handle) async {
    handle.updateStatusMessage('Connecting to server...');
    await connect();

    handle.updateStatusMessage('Authenticating...');
    await authenticate();

    handle.updateStatusMessage('Loading data...');
    await loadData();

    // Don't update progress - UI can show indeterminate indicator
    return 'Complete';
  },
  initialValue: '',
);

// In UI:
final status = watchValue((MyService s) => s.command.statusMessage);
Column(
  children: [
    CircularProgressIndicator(),  // Indeterminate (no value)
    Text(status ?? ''),
  ],
)
```

## See Also

- [Command Basics](command_basics.md) - All command factory methods
- [Command Properties](command_properties.md) - Other observable properties
- [Testing](testing.md) - Testing commands with MockCommand
- [Command Builders](command_builders.md) - UI integration patterns
