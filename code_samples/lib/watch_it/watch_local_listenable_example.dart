import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class CounterWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Create a local notifier
    final counter = createOnce(() => ValueNotifier<int>(0));

    // Watch it directly (not from get_it)
    final count = watch(counter).value;

    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          onPressed: () => counter.value++,
          child: Text('Increment'),
        ),
      ],
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: CounterWidget()));
}
