import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  void onLogout() async {
    getIt.unregister<AuthService>(); // ❌ Not awaited!
    getIt.registerSingleton<AuthService>(GuestAuthService());
    // Error: AuthService already registered (unregister didn't complete!)
  }
}
// #endregion example
