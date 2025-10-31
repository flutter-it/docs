import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void main() async {
  // #region example
  getIt.onScopeChanged = (bool pushed) {
    if (pushed) {
      print('New scope pushed - UI might need rebuild');
    } else {
      print('Scope popped - UI might need rebuild');
    }
  };
  // #endregion example
}
