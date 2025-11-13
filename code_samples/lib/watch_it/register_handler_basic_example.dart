import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

class CounterManager {
  final count = ValueNotifier<int>(0);

  void increment() => count.value++;

  void dispose() {
    count.dispose();
  }
}

// #region example
class CounterWidget extends WatchingWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Handler: Show snackbar when count reaches 10 (no rebuild needed)
    registerHandler(
      select: (CounterManager m) => m.count,
      handler: (context, count, cancel) {
        if (count == 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You reached 10!')),
          );
        }
      },
    );

    // Watch: Display the count (triggers rebuild)
    final count = watchValue((CounterManager m) => m.count);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Count: $count', style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => di<CounterManager>().increment(),
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
// #endregion example

void main() {
  di.registerSingleton<CounterManager>(CounterManager());

  runApp(MaterialApp(
    home: Scaffold(
      body: Center(child: CounterWidget()),
    ),
  ));
}
