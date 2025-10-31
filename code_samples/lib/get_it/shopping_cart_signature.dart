import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  // Start new shopping session
  getIt.pushNewScope(scopeName: 'session');
  getIt.registerSingleton<ShoppingCart>(ShoppingCart());
  getIt.registerSingleton<SessionAnalytics>(SessionAnalytics());

  // End session - cart discarded, analytics sent
  await getIt.popScope();
}
// #endregion example
