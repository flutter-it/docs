import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';

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

// #region example
class CounterWidgetWithBuilder extends StatelessWidget {
  CounterWidgetWithBuilder({super.key});

  final manager = CounterManager();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommandBuilder<void, String>(
          command: manager.incrementCommand,
          whileRunning: (context, _, __) => CircularProgressIndicator(),
          onData: (context, value, _) => Text('Count: $value'),
          onError: (context, error, _, __) => Text('Error: $error'),
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
  runApp(MaterialApp(
      home: Scaffold(body: Center(child: CounterWidgetWithBuilder()))));
}
