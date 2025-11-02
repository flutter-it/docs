import 'package:flutter/foundation.dart';
import 'package:listen_it/listen_it.dart';

// #region example
void main() {
  final listenable = ValueNotifier<int>(0);

  // Basic listen - prints every value change
  final subscription = listenable.listen((x, _) => print(x));

  listenable.value = 1; // Prints: 1
  listenable.value = 2; // Prints: 2

  // Cancel subscription when done
  subscription.cancel();

  // This won't print anything (subscription cancelled)
  listenable.value = 3;
}
// #endregion example

// #region self_cancel
void runOnce() {
  final listenable = ValueNotifier<int>(0);

  // Run only once
  listenable.listen((x, subscription) {
    print('First value: $x');
    subscription.cancel();
  });
}

void runNTimes() {
  final listenable = ValueNotifier<int>(0);

  // Run exactly 3 times
  var count = 0;
  listenable.listen((x, subscription) {
    print('Value: $x');
    if (++count >= 3) subscription.cancel();
  });
}
// #endregion self_cancel

// #region listenable
void listenableExample() {
  final listenable = ChangeNotifier();
  listenable.listen((subscription) => print('Changed!'));
}
// #endregion listenable
