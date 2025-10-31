import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void onLogin(String token) async {
  await getIt.unregister<User>();
  await getIt.unregister<ApiClient>();
  getIt.registerSingleton<User>(AuthenticatedUser(token));
  getIt.registerSingleton<ApiClient>(AuthenticatedApiClient(token));
}

void onLogout() async {
  await getIt.unregister<User>();
  await getIt.unregister<ApiClient>();
  getIt.registerSingleton<User>(GuestUser());
  getIt.registerSingleton<ApiClient>(PublicApiClient());
}
// #endregion example
