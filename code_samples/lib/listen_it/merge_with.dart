import 'package:flutter/foundation.dart';
import 'package:listen_it/listen_it.dart';

// #region example
void main() {
  final listenable1 = ValueNotifier<int>(0);
  final listenable2 = ValueNotifier<int>(0);
  final listenable3 = ValueNotifier<int>(0);

  // Merge multiple ValueListenables - updates when ANY changes
  listenable1.mergeWith([listenable2, listenable3]).listen((x, _) => print(x));

  listenable2.value = 42;
  // Prints: 42

  listenable1.value = 43;
  // Prints: 43

  listenable3.value = 44;
  // Prints: 44

  listenable2.value = 45;
  // Prints: 45

  listenable1.value = 46;
  // Prints: 46
}
// #endregion example
