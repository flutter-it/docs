import 'package:flutter/foundation.dart';
import 'package:listen_it/listen_it.dart';

// #region example
void main() {
  final intNotifier = ValueNotifier<int>(1);

  // Chain multiple operators together
  intNotifier
      .where((x) => x.isEven) // Only allow even numbers
      .map<String>((x) => x.toString()) // Convert to String
      .listen((s, _) => print('Result: $s'));

  intNotifier.value = 2; // Even - passes filter, converts to "2"
  // Prints: Result: 2

  intNotifier.value = 3; // Odd - blocked by filter
  // No output

  intNotifier.value = 4; // Even - passes filter, converts to "4"
  // Prints: Result: 4

  intNotifier.value = 5; // Odd - blocked by filter
  // No output

  intNotifier.value = 6; // Even - passes filter, converts to "6"
  // Prints: Result: 6
}
// #endregion example
