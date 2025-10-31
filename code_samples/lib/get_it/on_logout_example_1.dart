import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  void onLogout() async {
    await getIt.unregister<AuthService>(); // ✅ Wait for disposal
    getIt.registerSingleton<AuthService>(GuestAuthService());
  }
}
// #endregion example
