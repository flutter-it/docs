import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  getIt.enableRegisteringMultipleInstancesOfOneType();

  getIt.registerSingletonAsync<Plugin>(() async => await CorePlugin.create());
  getIt
      .registerSingletonAsync<Plugin>(() async => await LoggingPlugin.create());

  // Wait for all plugins to be ready
  await getIt.allReady();

  // Retrieve all async instances
  final Iterable<Plugin> plugins = await getIt.getAllAsync<Plugin>();
}
// #endregion example
