// ignore_for_file: missing_function_body, unused_element
// Enable multiple unnamed registrations
getIt.enableRegisteringMultipleInstancesOfOneType();

// Core plugins (unnamed)
getIt.registerSingleton<Plugin>(CorePlugin());
getIt.registerSingleton<Plugin>(LoggingPlugin());

// Special plugins (named for individual access + included in getAll())
getIt.registerSingleton<Plugin>(DebugPlugin(), instanceName: 'debug');

// Get all including named
final all = getIt.getAll<Plugin>(); // [CorePlugin, LoggingPlugin, DebugPlugin]

// Get specific named one
final debug = getIt<Plugin>(instanceName: 'debug');