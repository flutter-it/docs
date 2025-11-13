import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import 'package:listen_it/listen_it.dart';
import '_shared/stubs.dart';

class Manager {
  final value1 = ValueNotifier<int>(0);
  final value2 = ValueNotifier<int>(0);
}

// #region antipattern_create_outside_selector
class AntipatternCreateOutsideSelector extends WatchingWidget {
  const AntipatternCreateOutsideSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = di<Manager>();

    // ❌ WRONG: Creating operator chain OUTSIDE selector
    // This creates a NEW chain on every build - memory leak!
    final combined = manager.value1.combineLatest(
      manager.value2,
      (v1, v2) => v1 + v2,
    );

    // Watching the chain that was just created
    final sum = watch(combined).value;

    return Text('Sum: $sum (MEMORY LEAK!)');
  }
}
// #endregion antipattern_create_outside_selector

// #region correct_create_in_selector
class CorrectCreateInSelector extends WatchingWidget {
  const CorrectCreateInSelector({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ CORRECT: Create chain INSIDE selector
    // Selector runs once, chain is cached automatically
    final sum = watchValue(
      (Manager m) => m.value1.combineLatest(
        m.value2,
        (v1, v2) => v1 + v2,
      ),
    );

    return Text('Sum: $sum');
  }
}
// #endregion correct_create_in_selector

// #region antipattern_unnecessary_allow_change
class AntipatternUnnecessaryAllowChange extends WatchingWidget {
  const AntipatternUnnecessaryAllowChange({super.key});

  @override
  Widget build(BuildContext context) {
    // ❌ WRONG: Setting allowObservableChange: true without reason
    // This causes the selector to run on EVERY build
    // Creates new chain every time - memory leak!
    final sum = watchValue(
      (Manager m) => m.value1.combineLatest(
        m.value2,
        (v1, v2) => v1 + v2,
      ),
      allowObservableChange: true, // DON'T DO THIS!
    );

    return Text('Sum: $sum (MEMORY LEAK!)');
  }
}
// #endregion antipattern_unnecessary_allow_change

// #region antipattern_create_in_data_layer
class WrongDataLayerApproach {
  final value1 = ValueNotifier<int>(0);
  final value2 = ValueNotifier<int>(0);

  // ❌ WRONG if you create this as a getter
  // Getter creates NEW chain every time it's accessed!
  ValueListenable<int> get combined => value1.combineLatest(
        value2,
        (v1, v2) => v1 + v2,
      );
}

class CorrectDataLayerApproach {
  final value1 = ValueNotifier<int>(0);
  final value2 = ValueNotifier<int>(0);

  // ✅ CORRECT: Create once with late final
  // Chain is created once and reused
  late final combined = value1.combineLatest(
    value2,
    (v1, v2) => v1 + v2,
  );
}
// #endregion antipattern_create_in_data_layer

// #region antipattern_multiple_subscriptions
class AntipatternMultipleSubscriptions extends WatchingWidget {
  const AntipatternMultipleSubscriptions({super.key});

  @override
  Widget build(BuildContext context) {
    // ❌ SOMEWHAT WASTEFUL: Watching same values separately
    // when you really need a computed result
    final value1 = watchValue((Manager m) => m.value1);
    final value2 = watchValue((Manager m) => m.value2);

    // Computing in build
    final sum = value1 + value2;

    // This works, but:
    // - Widget rebuilds when EITHER value changes
    // - Even if sum doesn't change (e.g., 1+2->2+1)
    // - Two subscriptions instead of one

    return Text('Sum: $sum');
  }
}

class BetterCombinedApproach extends WatchingWidget {
  const BetterCombinedApproach({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ BETTER: Combine in selector
    // Only rebuilds when sum actually changes
    // Single subscription
    final sum = watchValue(
      (Manager m) => m.value1.combineLatest(
        m.value2,
        (v1, v2) => v1 + v2,
      ),
    );

    return Text('Sum: $sum');
  }
}
// #endregion antipattern_multiple_subscriptions

void main() {
  di.registerSingleton<Manager>(Manager());
  di.registerSingleton<WrongDataLayerApproach>(WrongDataLayerApproach());
  di.registerSingleton<CorrectDataLayerApproach>(CorrectDataLayerApproach());

  runApp(MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Anti-patterns vs Correct Approaches',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            CorrectCreateInSelector(),
            const SizedBox(height: 16),
            BetterCombinedApproach(),
          ],
        ),
      ),
    ),
  ));
}
