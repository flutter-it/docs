import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  getIt.onScopeChanged = (bool pushed) {
    if (pushed) {
      print('New scope pushed - UI might need rebuild');
    } else {
      print('Scope popped - UI might need rebuild');
    }
  };
}
// #endregion example
