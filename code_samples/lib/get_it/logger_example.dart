import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() async {
  // #region example
  getIt.allowReassignment = true;

// Now you can re-register
  getIt.registerSingleton<Logger>(ConsoleLogger());
  getIt.registerSingleton<Logger>(FileLogger()); // Overwrites previous
  // #endregion example
}
