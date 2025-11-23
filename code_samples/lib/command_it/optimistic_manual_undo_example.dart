import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import '_shared/stubs.dart';

// #region example
class TextEditorService {
  final content = ValueNotifier<String>('');

  late final editCommand = Command.createUndoableNoResult<String, String>(
    (newText, stack) async {
      // Save previous state
      stack.push(content.value);

      // Update content
      content.value = newText;
      await getIt<ApiClient>().saveContent(newText);
    },
    undo: (stack, reason) async {
      // Restore previous content
      content.value = stack.pop();
    },
    undoOnExecutionFailure: false, // Disable automatic rollback for manual undo
  );

  void undo() {
    (editCommand as UndoableCommand).undo();
  }
}
// #endregion example

void main() {
  setupDependencyInjection();

  final editor = TextEditorService();

  // Test the editor
  editor.editCommand('Hello');
  editor.editCommand('Hello World');

  // Manual undo
  editor.undo();
}
