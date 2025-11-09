import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class CounterWidget extends WatchingWidget {
  const CounterWidget({super.key, required this.counter});

  final ValueNotifier<int> counter;

  @override
  Widget build(BuildContext context) {
    // Watch the counter passed as parameter (not from get_it)
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
  final counter = ValueNotifier<int>(0);
  runApp(MaterialApp(home: CounterWidget(counter: counter)));
}
