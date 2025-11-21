import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:watch_it/watch_it.dart';

// #region example
class CounterService {
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

// Register with get_it (call this in main())
void setup() {
  GetIt.instance.registerSingleton(CounterService());
}

// Use watch_it to observe the command
class CounterWidget extends WatchingWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the command value - rebuilds when it changes
    final count = watchValue((CounterService s) => s.incrementCommand);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('You have pushed the button this many times:'),
        Text(
          count,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: 16),
        // No parameters - use .run as tearoff
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
  setup();
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(child: CounterWidget()),
    ),
  ));
}
