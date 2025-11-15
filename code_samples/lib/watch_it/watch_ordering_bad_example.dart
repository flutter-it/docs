import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
// ❌ WRONG: Conditional watch calls - ORDER CHANGES between builds
// This will cause errors or unexpected behavior!

class BadWatchOrderingWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final showDetails = createOnce(() => ValueNotifier(false));
    final show = watch(showDetails).value;

    // ❌ WRONG: Conditional watch - order changes!
    // When show changes, the order of watch calls changes
    if (show) {
      // This watch call only happens sometimes
      final todos = watchValue((TodoManager m) => m.todos);

      return Scaffold(
        appBar: AppBar(title: const Text('❌ Bad Ordering - Details View')),
        body: ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            return ListTile(title: Text(todos[index].title));
          },
        ),
      );
    }

    // Different watch calls in different branches
    final isLoading =
        watchValue((TodoManager m) => m.fetchTodosCommand.isRunning);

    return Scaffold(
      appBar: AppBar(title: const Text('❌ Bad Ordering - Simple View')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              color: Colors.red.shade100,
              child: const Text(
                '❌ BAD: Watch call order changes based on conditions!\n'
                'This violates the golden rule.',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            if (isLoading) const CircularProgressIndicator(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => showDetails.value = true,
              child: const Text('Toggle View (will break)'),
            ),
          ],
        ),
      ),
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();

  runApp(MaterialApp(
    home: BadWatchOrderingWidget(),
  ));
}
