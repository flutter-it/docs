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
  const CounterWidgetWithBuilder({
    super.key,
    required this.manager,
  });

  final CounterManager manager;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommandBuilder(
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
  final manager = CounterManager();
  runApp(MaterialApp(
      home: Scaffold(
          body: Center(child: CounterWidgetWithBuilder(manager: manager)))));
}
