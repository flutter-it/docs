import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  getIt.enableRegisteringMultipleInstancesOfOneType();

  getIt.registerSingleton<Plugin>(CorePlugin());
  getIt.registerSingleton<Plugin>(LoggingPlugin());
  getIt.registerSingleton<Plugin>(AnalyticsPlugin());

  final plugin = getIt<Plugin>();
  print('plugin: $plugin');
  // Returns: CorePlugin (the first one only!)
}
// #endregion example
