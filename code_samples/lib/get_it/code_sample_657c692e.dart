import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
// Logout - pop scope
  await getIt.popScope(); // All auth services disposed automatically
// Guest services from base scope automatically restored!
}
// #endregion example
