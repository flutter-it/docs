import 'package:flutter/foundation.dart';
import 'package:listen_it/listen_it.dart';

// #region example
void main() {
  final source = ValueNotifier<String>('hello');
  final upperCaseSource = source.map((s) => s.toUpperCase());

  print(upperCaseSource.value); // Prints: HELLO

  source.value = 'world';
  print(upperCaseSource.value); // Prints: WORLD
}
// #endregion example
