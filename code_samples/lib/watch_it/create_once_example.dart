import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class CreateOnceWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // createOnce creates an object on first build and automatically disposes it
    // Perfect for TextEditingControllers, AnimationControllers, local state, etc.
    final titleController = createOnce(() => TextEditingController());
    final descController = createOnce(() => TextEditingController());

    // Create a local counter that persists across rebuilds
    final counter = createOnce(() => SimpleCounter());

    // Watch the counter for reactive updates
    final count = watch(counter).value;

    return Scaffold(
      appBar: AppBar(title: const Text('createOnce Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'createOnce creates objects once and auto-disposes them',
              style: TextStyle(fontStyle: FontStyle.italic),
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
            const SizedBox(height: 32),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
    home: CreateOnceWidget(),
  ));
}
