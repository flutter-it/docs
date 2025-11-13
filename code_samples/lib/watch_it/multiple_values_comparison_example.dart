import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import 'package:listen_it/listen_it.dart';
import '_shared/stubs.dart';

class Manager {
  final value1 = ValueNotifier<int>(0);
  final value2 = ValueNotifier<int>(0);

  // Combined result in data layer
  late final bothPositive = value1.combineLatest(
    value2,
    (v1, v2) => v1 > 0 && v2 > 0,
  );
}

// #region separate_watches
class SeparateWatchesWidget extends WatchingWidget {
  const SeparateWatchesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Two separate watches - rebuilds when EITHER changes
    final value1 = watchValue((Manager m) => m.value1);
    final value2 = watchValue((Manager m) => m.value2);

    // Combine in UI logic
    final bothPositive = value1 > 0 && value2 > 0;

    print('SeparateWatchesWidget rebuilt'); // Rebuilds on every change

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Approach 1: Separate Watches'),
            Text('Value1: $value1, Value2: $value2'),
            Text(
              bothPositive ? 'Both positive!' : 'At least one negative',
              style: TextStyle(color: bothPositive ? Colors.green : Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
// #endregion separate_watches

// #region combined_watch
class CombinedWatchWidget extends WatchingWidget {
  const CombinedWatchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // One watch on combined result - rebuilds only when result changes
    final bothPositive = watchValue((Manager m) => m.bothPositive);

    print('CombinedWatchWidget rebuilt'); // Only rebuilds when result changes

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Approach 2: Combined Watch'),
            Text(
              bothPositive ? 'Both positive!' : 'At least one negative',
              style: TextStyle(color: bothPositive ? Colors.green : Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
// #endregion combined_watch

void main() {
  di.registerSingleton<Manager>(Manager());
  runApp(MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SeparateWatchesWidget(),
            const SizedBox(height: 16),
            CombinedWatchWidget(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => di<Manager>().value1.value++,
                  child: const Text('Increment Value1'),
                ),
                ElevatedButton(
                  onPressed: () => di<Manager>().value2.value++,
                  child: const Text('Increment Value2'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ));
}
