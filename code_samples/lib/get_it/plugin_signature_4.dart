// ignore_for_file: missing_function_body, unused_element
getIt.enableRegisteringMultipleInstancesOfOneType();

// Base scope
getIt.registerSingleton<Plugin>(CorePlugin());
getIt.registerSingleton<Plugin>(LoggingPlugin());

// Push new scope
getIt.pushNewScope(scopeName: 'feature');
getIt.registerSingleton<Plugin>(FeatureAPlugin());
getIt.registerSingleton<Plugin>(FeatureBPlugin());

// Current scope only (default)
final featurePlugins = getIt.getAll<Plugin>();
// Returns: [FeatureAPlugin, FeatureBPlugin]