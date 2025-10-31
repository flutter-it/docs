import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  if (getIt.hasScope('authenticated')) {
    // Scope exists
  } else {
    // Not logged in
  }
}
// #endregion example
