import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  // First unnamed registration
  getIt.registerSingleton<Plugin>(CorePlugin());

  // Second unnamed registration (now allowed!)
  getIt.registerSingleton<Plugin>(LoggingPlugin());

  // Named registrations (always allowed - even without enabling)
  getIt.registerSingleton<Plugin>(FeaturePlugin(), instanceName: 'feature');
}
// #endregion example
