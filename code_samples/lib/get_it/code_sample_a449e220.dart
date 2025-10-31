import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() async {
  // #region example
  await getIt.resetLazySingleton<AuthService>();
  // Next call to getIt<AuthService>() creates new instance
  // #endregion example
}
