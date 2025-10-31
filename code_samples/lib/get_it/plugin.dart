import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() {
  // #region example
  // Enable feature first
  getIt.enableRegisteringMultipleInstancesOfOneType();

  // Register multiple plugins without names
  getIt.registerSingleton<Plugin>(CorePlugin());
  getIt.registerSingleton<Plugin>(LoggingPlugin());
  getIt.registerSingleton<Plugin>(AnalyticsPlugin());

  // Get all at once
  final Iterable<Plugin> allPlugins = getIt.getAll<Plugin>();
  // #endregion example
}
