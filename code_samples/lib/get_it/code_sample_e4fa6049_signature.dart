// ignore_for_file: missing_function_body, unused_element
// Only search the base scope
final basePlugins = getIt.getAll<Plugin>(onlyInScope: 'baseScope');
// Returns: [CorePlugin, LoggingPlugin]

// Only search the 'feature' scope
final featurePlugins = getIt.getAll<Plugin>(onlyInScope: 'feature');
// Returns: [FeatureAPlugin, FeatureBPlugin]
