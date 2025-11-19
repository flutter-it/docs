import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class CallAfterFirstBuildWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // callOnceAfterThisBuild executes after the first frame is rendered
    // Perfect for showing dialogs, snackbars, or accessing RenderBox
    // Runs after build is complete, similar to WidgetsBinding.instance.addPostFrameCallback
    callOnceAfterThisBuild((_) {
      debugPrint('First frame rendered!');

      // Show welcome dialog after first build
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Welcome!'),
          content:
              const Text('This dialog shows after the first frame renders.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });

    final counter = createOnce(() => SimpleCounter());
    final count = watch(counter).value;

    return Scaffold(
      appBar: AppBar(title: const Text('callOnceAfterThisBuild Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'callOnceAfterThisBuild shows the welcome dialog after rendering',
                style: TextStyle(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Counter: $count',
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
        ),
      ),
    );
  }
}
// #endregion example

void main() {
  runApp(MaterialApp(
    home: CallAfterFirstBuildWidget(),
  ));
}
