import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class FormWidget extends WatchingWidget {
  const FormWidget({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    // Watch the controller just to trigger rebuild - don't need the return value
    watch(controller);

    // Now we can use the controller's current state in our widget tree
    return Column(
      children: [
        TextField(controller: controller),
        Text('Character count: ${controller.text.length}'),
        ElevatedButton(
          onPressed: controller.text.isEmpty ? null : () => print('Submit'),
          child: Text('Submit'),
        ),
      ],
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();
  final controller = TextEditingController();
  runApp(MaterialApp(home: Scaffold(body: FormWidget(controller: controller))));
}
