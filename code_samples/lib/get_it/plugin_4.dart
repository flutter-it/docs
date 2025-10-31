import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  // Enable multiple unnamed registrations
  getIt.enableRegisteringMultipleInstancesOfOneType();

  // Core plugins (unnamed)
  getIt.registerSingleton<Plugin>(CorePlugin());
  getIt.registerSingleton<Plugin>(LoggingPlugin());

  // Special plugins (named for individual access + included in getAll())
  getIt.registerSingleton<Plugin>(DebugPlugin(), instanceName: 'debug');

  // Get all including named
  final all = getIt.getAll<Plugin>();
  print('all: $all'); // [CorePlugin, LoggingPlugin, DebugPlugin]

  // Get specific named one
  final debug = getIt<Plugin>(instanceName: 'debug');
  print('debug: $debug');
}
// #endregion example
