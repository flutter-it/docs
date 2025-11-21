import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';

// #region example
class CounterModel {
  int _count = 0;

  // Command wraps a function and acts as a ValueListenable
  late final incrementCommand = Command.createSyncNoParam<String>(
    () {
      _count++;
      return _count.toString();
    },
    initialValue: '0',
  );
}

class CounterWidget extends StatelessWidget {
  CounterWidget({super.key});

  final model = CounterModel();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('You have pushed the button this many times:'),
        // Command is a ValueListenable - use ValueListenableBuilder
        ValueListenableBuilder<String>(
          valueListenable: model.incrementCommand,
          builder: (context, value, _) => Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        SizedBox(height: 16),
        // Command has a .run method - use it as tearoff for onPressed
        ElevatedButton(
          onPressed: model.incrementCommand.run,
          child: Text('Increment'),
        ),
      ],
    );
  }
}
// #endregion example

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(child: CounterWidget()),
    ),
  ));
}
