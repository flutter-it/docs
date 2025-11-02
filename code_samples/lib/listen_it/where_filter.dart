import 'package:flutter/foundation.dart';
import 'package:listen_it/listen_it.dart';

// #region example
void main() {
  final intNotifier = ValueNotifier<int>(1);
  bool onlyEven = true;

  // Filter to only allow even values
  final filteredNotifier = intNotifier.where((i) => onlyEven ? i.isEven : true);

  filteredNotifier.listen((value, _) => print('Filtered value: $value'));

  intNotifier.value = 2; // Even - passes filter
  // Prints: Filtered value: 2

  intNotifier.value = 3; // Odd - blocked by filter
  // No output

  intNotifier.value = 4; // Even - passes filter
  // Prints: Filtered value: 4

  // Change filter condition
  onlyEven = false;

  intNotifier.value = 5; // Now passes (filter disabled)
  // Prints: Filtered value: 5
}
// #endregion example
