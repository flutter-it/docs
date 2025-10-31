// ignore_for_file: missing_function_body, unused_element
// First unnamed registration
getIt.registerSingleton<Plugin>(CorePlugin());

// Second unnamed registration (now allowed!)
getIt.registerSingleton<Plugin>(LoggingPlugin());

// Named registrations (always allowed - even without enabling)
getIt.registerSingleton<Plugin>(FeaturePlugin(), instanceName: 'feature');