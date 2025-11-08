import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
// 1. Create a manager with reactive state
class CounterManager {
  final count = ValueNotifier<int>(0);

  void increment() => count.value++;
}

// 2. Register it in get_it
void setupCounter() {
  di.registerLazySingleton<CounterManager>(() => CounterManager());
}

// 3. Watch it in your widget
class CounterWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // This one line makes it reactive!
    final count = watchValue((CounterManager m) => m.count);

    return Scaffold(
      body: Center(
        child: Text('Count: $count', style: TextStyle(fontSize: 48)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => di<CounterManager>().increment(),
        child: Icon(Icons.add),
      ),
    );
  }
}
// #endregion example

void main() {
  setupCounter();
  runApp(MaterialApp(home: CounterWidget()));
}
