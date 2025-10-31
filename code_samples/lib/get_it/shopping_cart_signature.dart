// ignore_for_file: missing_function_body, unused_element
// Start new shopping session
getIt.pushNewScope(scopeName: 'session');
getIt.registerSingleton<ShoppingCart>(ShoppingCart());
getIt.registerSingleton<SessionAnalytics>(SessionAnalytics());

// End session - cart discarded, analytics sent
await getIt.popScope();