import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() {
// #region example
  // First unnamed registration
  getIt.registerSingleton<Plugin>(CorePlugin());

  // Second unnamed registration (now allowed!)
  getIt.registerSingleton<Plugin>(LoggingPlugin());

  // Named registrations (always allowed - even without enabling)
  getIt.registerSingleton<Plugin>(FeaturePlugin(), instanceName: 'feature');
// #endregion example
}
