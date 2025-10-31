// ignore_for_file: missing_function_body, unused_element
getIt.enableRegisteringMultipleInstancesOfOneType();

getIt.registerSingletonAsync<Plugin>(() async => await CorePlugin.create());
getIt.registerSingletonAsync<Plugin>(() async => await LoggingPlugin.create());

// Wait for all plugins to be ready
await getIt.allReady();

// Retrieve all async instances
final Iterable<Plugin> plugins = await getIt.getAllAsync<Plugin>();