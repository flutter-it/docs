import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import 'package:listen_it/listen_it.dart';
import '_shared/stubs.dart';

class Manager {
  final value1 = ValueNotifier<int>(0);
  final value2 = ValueNotifier<int>(0);
}

// #region safe_inline_combine
class SafeInlineCombineWidget extends WatchingWidget {
  const SafeInlineCombineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ SAFE: Operator chain created ONCE and cached automatically
    // Default allowObservableChange: false ensures selector runs only once
    final sum = watchValue(
      (Manager m) => m.value1.combineLatest(
        m.value2,
        (v1, v2) => v1 + v2,
      ),
    );

    print('Widget rebuilt with sum: $sum');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Sum: $sum', style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 16),
        const Text(
          'The combineLatest chain is created once and cached.\n'
          'No memory leaks, no repeated chain creation!',
          style: TextStyle(fontSize: 12, color: Colors.green),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
// #endregion safe_inline_combine

// #region unsafe_inline_combine
class UnsafeInlineCombineWidget extends WatchingWidget {
  const UnsafeInlineCombineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // ❌ UNSAFE: Setting allowObservableChange: true unnecessarily
    // Selector runs on EVERY build, creates new chain every time
    final sum = watchValue(
      (Manager m) => m.value1.combineLatest(
        m.value2,
        (v1, v2) => v1 + v2,
      ),
      allowObservableChange: true, // DON'T DO THIS without good reason!
    );

    print('UNSAFE widget rebuilt with sum: $sum');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Sum: $sum', style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 16),
        const Text(
          '⚠️ This creates a NEW combineLatest chain on every build!\n'
          'Memory leak! Performance issue!',
          style: TextStyle(fontSize: 12, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
// #endregion unsafe_inline_combine

// #region when_to_use_allow_change
class DynamicStreamWidget extends WatchingWidget {
  const DynamicStreamWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Get dynamic value that determines which stream to watch
    final useStream1 = watchValue((StreamManager m) => m.useStream1);

    // ✅ CORRECT use of allowStreamChange: true
    // Stream identity changes when useStream1 changes
    final data = watchStream(
      (StreamManager m) => useStream1 ? m.stream1 : m.stream2,
      initialValue: 0,
      allowStreamChange: true, // Needed because stream identity changes
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Using stream ${useStream1 ? "1" : "2"}'),
        Text('Data: ${data.data}'),
        const SizedBox(height: 16),
        const Text(
          'allowStreamChange: true is CORRECT here\n'
          'because we genuinely switch between different streams',
          style: TextStyle(fontSize: 12, color: Colors.blue),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
// #endregion when_to_use_allow_change

void main() {
  di.registerSingleton<Manager>(Manager());
  di.registerSingleton<StreamManager>(StreamManager());

  runApp(MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Safe vs Unsafe Inline Combining',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Expanded(child: SafeInlineCombineWidget()),
            const Divider(),
            Expanded(child: UnsafeInlineCombineWidget()),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                di<Manager>().value1.value++;
              },
              child: const Text('Increment Value 1'),
            ),
          ],
        ),
      ),
    ),
  ));
}
