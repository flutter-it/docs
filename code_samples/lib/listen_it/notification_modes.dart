import '_shared/stubs.dart';

// #region example
void main() {
  // Normal mode - only notify on actual changes
  final normalCart = SetNotifier<String>(
    data: {},
    notificationMode: CustomNotifierMode.normal,
  );

  normalCart.listen((items, _) => print('Normal: $items'));
  normalCart.add('item1'); // ✅ Notifies (new item)
  normalCart.add('item1'); // ❌ No notification (already exists)

  print('---');

  // Always mode - notify on every operation (default)
  final alwaysCart = SetNotifier<String>(
    data: {},
    notificationMode: CustomNotifierMode.always,
  );

  alwaysCart.listen((items, _) => print('Always: $items'));
  alwaysCart.add('item1'); // ✅ Notifies
  alwaysCart.add('item1'); // ✅ Notifies (even though already exists)

  print('---');

  // Manual mode - you control when to notify
  final manualCart = SetNotifier<String>(
    data: {},
    notificationMode: CustomNotifierMode.manual,
  );

  manualCart.listen((items, _) => print('Manual: $items'));
  manualCart.add('item1'); // No automatic notification
  manualCart.add('item2'); // No automatic notification
  manualCart.notifyListeners(); // ✅ Single notification for both adds
}
// #endregion example
