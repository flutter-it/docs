// ignore_for_file: missing_function_body, unused_element
// Enable feature first
getIt.enableRegisteringMultipleInstancesOfOneType();

// Register multiple plugins without names
getIt.registerSingleton<Plugin>(CorePlugin());
getIt.registerSingleton<Plugin>(LoggingPlugin());
getIt.registerSingleton<Plugin>(AnalyticsPlugin());

// Get all at once
final Iterable<Plugin> allPlugins = getIt.getAll<Plugin>();