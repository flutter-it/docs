import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  await getIt.resetLazySingleton<AuthService>();
  // Next call to getIt<AuthService>() creates new instance
}
// #endregion example
