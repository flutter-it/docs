import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:watch_it/watch_it.dart';

// #region example
// 1. Create a service with a command
class CounterService {
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

// Register with get_it (call this in main())
void setup() {
  GetIt.instance.registerSingleton(CounterService());
}

// 2. Use watch_it to observe the command
class CounterWidget extends WatchingWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the command value
    final count = watchValue((CounterService s) => s.incrementCommand);

    // Watch the loading state
    final isRunning =
        watchValue((CounterService s) => s.incrementCommand.isRunning);

    return Column(
      children: [
        // Shows loading indicator automatically while command runs
        if (isRunning) CircularProgressIndicator() else Text('Count: $count'),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: GetIt.instance<CounterService>().incrementCommand.run,
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
