import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class CounterModel {
  final counter = ValueNotifier<int>(0);
  void increment() => counter.value++;
}

class CounterPage extends WatchingWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    pushScope(init: (getIt) => getIt<CounterModel>());
    final count = watchValue((CounterModel m) => m.counter);

    return Scaffold(
      body: Text('$count'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => di<CounterModel>().increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
