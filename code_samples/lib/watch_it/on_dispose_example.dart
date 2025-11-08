import 'dart:async';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class OnDisposeWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final counter = createOnce(() => SimpleCounter());
    final count = watch(counter).value;

    // onDispose registers a callback that runs when widget is disposed
    // Perfect for cleanup: closing streams, canceling timers, etc.
    // Note: createOnce auto-disposes, but onDispose is useful for custom cleanup

    // Create a timer that we need to manually cancel
    final timer = createOnce(() {
      return Timer.periodic(const Duration(seconds: 1), (_) {
        debugPrint('Timer tick: ${DateTime.now()}');
        counter.increment();
      });
    });

    // Register disposal callback for the timer
    onDispose(() {
      debugPrint('Disposing widget - canceling timer');
      timer.cancel();
    });

    // Can register multiple dispose callbacks
    onDispose(() {
      debugPrint('Widget disposed - count was: $count');
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('onDispose Example'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'onDispose cleans up the timer when you navigate back',
                style: TextStyle(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Counter: $count',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            const Text('(Auto-incrementing every second)'),
            const SizedBox(height: 32),
            const Text(
              'Press back button to see dispose logs',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
// #endregion example

void main() {
  runApp(MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Navigate to OnDispose Demo')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => OnDisposeWidget()),
              );
            },
            child: const Text('Open OnDispose Example'),
          ),
        ),
      ),
    ),
  ));
}
