import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
Future<void> main() async {
  // Initialize base scope
  await getIt.allReady();

  // Push new scope with its own async services
  getIt.pushNewScope(scopeName: 'user-session');
  getIt.registerSingletonAsync<UserService>(() async => UserService.load());

  // Wait for new scope to be ready
  await getIt.allReady();
}
// #endregion example
