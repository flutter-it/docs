// ignore_for_file: missing_function_body, unused_element
getIt.enableRegisteringMultipleInstancesOfOneType();

getIt.registerSingleton<Plugin>(CorePlugin());
getIt.registerSingleton<Plugin>(LoggingPlugin());
getIt.registerSingleton<Plugin>(AnalyticsPlugin());

final plugin = getIt<Plugin>();
// Returns: CorePlugin (the first one only!)