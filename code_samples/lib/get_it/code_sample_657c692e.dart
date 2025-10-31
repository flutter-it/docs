import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void main() async {
  // #region example
// Logout - pop scope
  await getIt.popScope(); // All auth services disposed automatically
// Guest services from base scope automatically restored!
  // #endregion example
}
