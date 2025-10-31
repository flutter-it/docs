import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  final token = 'auth_token_123';
  final user = GuestUser();

  // App startup - guest mode
  getIt.registerSingleton<User>(GuestUser());
  getIt.registerSingleton<Permissions>(GuestPermissions());

  // User logs in
  getIt.pushNewScope(scopeName: 'authenticated');
  getIt.registerSingleton<User>(AuthenticatedUser(token));
  getIt.registerSingleton<Permissions>(UserPermissions(user));

  // User logs out - automatic cleanup
  await getIt.popScope(); // GuestUser & GuestPermissions restored
}
// #endregion example
