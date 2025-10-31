import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  getIt.enableRegisteringMultipleInstancesOfOneType();

  getIt.registerSingleton<Plugin>(CorePlugin()); // unnamed
  getIt.registerSingleton<Plugin>(LoggingPlugin()); // unnamed
  getIt.registerSingleton<Plugin>(AnalyticsPlugin(),
      instanceName: 'analytics'); // named

  final Iterable<Plugin> allPlugins = getIt.getAll<Plugin>();
// Returns: [CorePlugin, LoggingPlugin, AnalyticsPlugin]
//          ALL unnamed + ALL named registrations
}
// #endregion example
