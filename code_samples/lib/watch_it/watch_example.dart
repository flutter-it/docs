import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '_shared/stubs.dart';

// #region example
class CounterWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Create a local counter that this widget watches
    final counter = createOnce(() => SimpleCounter());

    // Watch the counter - widget rebuilds whenever counter changes
    final count = watch(counter).value;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Count: $count',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: counter.decrement,
              child: const Text('-'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: counter.increment,
              child: const Text('+'),
            ),
          ],
        ),
      ],
    );
  }
}
// #endregion example

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: CounterWidget(),
      ),
    ),
  ));
}
