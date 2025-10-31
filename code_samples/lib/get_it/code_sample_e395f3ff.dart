import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  print('Current scope: ${getIt.currentScopeName}');
// Output: null (for unnamed scopes), 'session', 'baseScope', etc.
}
// #endregion example
