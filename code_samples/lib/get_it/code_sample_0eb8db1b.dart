import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void main() async {
  // #region example
  if (getIt.hasScope('authenticated')) {
    // Scope exists
  } else {
    // Not logged in
  }
  // #endregion example
}
