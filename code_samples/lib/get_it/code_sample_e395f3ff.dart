import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void main() async {
  // #region example
  print('Current scope: ${getIt.currentScopeName}');
// Output: null (for unnamed scopes), 'session', 'baseScope', etc.
  // #endregion example
}
