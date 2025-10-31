import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
class AuthService {
  Future<void> login(String username, String password) async {
    final user = await getIt<ApiClient>().login(username, password);

    // Push authenticated scope
    getIt.pushNewScope(scopeName: 'authenticated');
    getIt.registerSingleton<User>(user);
    getIt.registerSingleton<ApiClient>(AuthenticatedApiClient(user.token));
    getIt.registerSingleton<NotificationService>(NotificationService(user.id));
  }

  Future<void> logout() async {
    // Pop scope - automatic cleanup of all authenticated services
    await getIt.popScope();

    // GuestUser (from base scope) is now active again
  }
}
// #endregion example
