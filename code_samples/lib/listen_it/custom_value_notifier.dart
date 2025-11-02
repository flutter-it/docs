import 'package:listen_it/listen_it.dart';

// #region example
void main() {
  // Always mode - notify on every assignment
  final alwaysNotifier = CustomValueNotifier<int>(
    0,
    mode: CustomNotifierMode.always,
  );

  alwaysNotifier.addListener(() => print('Always: ${alwaysNotifier.value}'));

  alwaysNotifier.value = 42; // Notifies
  alwaysNotifier.value = 42; // Notifies again (same value)

  print('---');

  // Manual mode - only notify when you call notifyListeners()
  final manualNotifier = CustomValueNotifier<int>(
    0,
    mode: CustomNotifierMode.manual,
  );

  manualNotifier.addListener(() => print('Manual: ${manualNotifier.value}'));

  manualNotifier.value = 42; // No notification
  manualNotifier.value = 43; // No notification
  print('Current value: ${manualNotifier.value}'); // 43
  manualNotifier.notifyListeners(); // NOW listeners are notified

  print('---');

  // Normal mode (default) - notify only on value change
  final normalNotifier = CustomValueNotifier<int>(
    0,
    mode: CustomNotifierMode.normal,
  );

  normalNotifier.addListener(() => print('Normal: ${normalNotifier.value}'));

  normalNotifier.value = 42; // Notifies
  normalNotifier.value = 42; // No notification (same value)
  normalNotifier.value = 43; // Notifies
}
// #endregion example
