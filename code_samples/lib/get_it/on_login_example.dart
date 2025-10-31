// ignore_for_file: unused_import, unused_local_variable, unused_element, prefer_collection_literals, use_key_in_widget_constructors, use_super_parameters, invalid_use_of_visible_for_testing_member, depend_on_referenced_packages
import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
// App starts with guest services
  getIt.registerSingleton<User>(GuestUser());
  getIt.registerSingleton<ApiClient>(PublicApiClient());

// User logs in - push new scope
  void onLogin(String token) {
    getIt.pushNewScope(scopeName: 'authenticated');
    getIt.registerSingleton<User>(AuthenticatedUser(token));
    getIt.registerSingleton<ApiClient>(AuthenticatedApiClient(token));
  }

// User logs out - pop scope (automatic cleanup!)
  void onLogout() async {
    await getIt
        .popScope(); // All auth services disposed, guest services restored
  }
}
// #endregion example
