import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() {
// #region example
  getIt.enableRegisteringMultipleInstancesOfOneType();

  getIt.registerSingleton<Plugin>(CorePlugin());
  getIt.registerSingleton<Plugin>(LoggingPlugin());
  getIt.registerSingleton<Plugin>(AnalyticsPlugin());

  final plugin = getIt<Plugin>();
  // Returns: CorePlugin (the first one only!)
// #endregion example
  print('plugin: $plugin');
}
