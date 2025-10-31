// ignore_for_file: missing_function_body, unused_element
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
