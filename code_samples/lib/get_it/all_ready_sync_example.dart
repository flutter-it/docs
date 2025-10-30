import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void showUI() {
  if (getIt.allReadySync()) {
    // Show main UI
  } else {
    // Show loading indicator
  }
}
// #endregion example
