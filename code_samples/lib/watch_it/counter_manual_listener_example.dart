import 'package:flutter/material.dart';
import '_shared/stubs.dart';

// #region example
class CounterWidget extends StatelessWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = di<CounterManager>();

    return ValueListenableBuilder<int>(
      valueListenable: manager.count,
      builder: (context, count, child) {
        return Scaffold(
          body: Center(
            child: Text('Count: $count', style: TextStyle(fontSize: 48)),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => manager.increment(),
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: CounterWidget()));
}
