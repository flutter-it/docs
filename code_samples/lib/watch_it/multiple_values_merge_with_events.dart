import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import 'package:listen_it/listen_it.dart';
import '_shared/stubs.dart';

// #region manager
class DocumentManager {
  // Three different save triggers
  final saveButtonPressed = ValueNotifier<bool>(false);
  final autoSaveTrigger = ValueNotifier<bool>(false);
  final keyboardShortcut = ValueNotifier<bool>(false);

  // Merge all save triggers into one - fires when ANY trigger fires
  late final saveRequested = saveButtonPressed.mergeWith([
    autoSaveTrigger,
    keyboardShortcut,
  ]);

  void save() {
    print('Saving document...');
  }
}
// #endregion manager

// #region widget
class DocumentEditorWidget extends WatchingWidget {
  const DocumentEditorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Use registerHandler to react to ANY save trigger
    registerHandler(
      select: (DocumentManager m) => m.saveRequested,
      handler: (context, shouldSave, cancel) {
        if (shouldSave) {
          di<DocumentManager>().save();
        }
      },
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            di<DocumentManager>().saveButtonPressed.value = true;
          },
          child: const Text('Save'),
        ),
        const SizedBox(height: 8),
        Text(
          'Auto-save, button, or Ctrl+S all trigger the same save handler',
          style: TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
// #endregion widget

void main() {
  di.registerSingleton<DocumentManager>(DocumentManager());
  runApp(
      MaterialApp(home: Scaffold(body: Center(child: DocumentEditorWidget()))));
}
