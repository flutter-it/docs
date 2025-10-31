import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  getIt.skipDoubleRegistration = true;

// If already registered, this does nothing instead of throwing
  getIt.registerSingleton<Logger>(Logger());
}
// #endregion example
