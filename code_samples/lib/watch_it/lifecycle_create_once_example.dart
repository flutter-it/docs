// ignore_for_file: unused_local_variable, unreachable_from_main, undefined_class, unused_element
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;

// #region example
class TextFieldWithClear extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final controller =
        createOnce<TextEditingController>(() => TextEditingController());
    return Row(
      children: [
        TextField(
          controller: controller,
        ),
        ElevatedButton(
          onPressed: () => controller.clear(),
          child: const Text('Clear'),
        ),
      ],
    );
  }
}
// #endregion example

void main() {}
