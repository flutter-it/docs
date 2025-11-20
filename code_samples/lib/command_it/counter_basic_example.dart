import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';

// #region example
// 1. Create a command that wraps your async function
class CounterManager {
  int _counter = 0;

  late final incrementCommand = Command.createAsyncNoParam<String>(
    () async {
      await Future.delayed(Duration(milliseconds: 500));
      _counter++;
      return _counter.toString();
    },
    initialValue: '0',
  );
}

// 2. Use it in your UI - command is a ValueListenable
class CounterWidget extends StatelessWidget {
  CounterWidget({super.key});

  final manager = CounterManager();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Shows loading indicator automatically while command runs
        ValueListenableBuilder<bool>(
          valueListenable: manager.incrementCommand.isRunning,
          builder: (context, isRunning, _) {
            if (isRunning) return CircularProgressIndicator();

            return ValueListenableBuilder<String>(
              valueListenable: manager.incrementCommand,
              builder: (context, value, _) => Text('Count: $value'),
            );
          },
        ),
        ElevatedButton(
          onPressed: manager.incrementCommand.run,
          child: Text('Increment'),
        ),
      ],
    );
  }
}
// #endregion example

void main() {
  runApp(MaterialApp(home: Scaffold(body: Center(child: CounterWidget()))));
}
