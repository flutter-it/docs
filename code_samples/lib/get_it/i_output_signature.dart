// ignore_for_file: missing_function_body, unused_element
// Base scope
getIt.registerSingleton<IOutput>(FileOutput());

// Push scope
getIt.pushNewScope(scopeName: 'session');
getIt.registerSingleton<IOutput>(ConsoleOutput());

// Current scope only (default)
final current = getIt.findAll<IOutput>();
// Returns: [ConsoleOutput]

// All scopes
final all = getIt.findAll<IOutput>(inAllScopes: true);
// Returns: [ConsoleOutput, FileOutput]

// Specific scope
final base = getIt.findAll<IOutput>(onlyInScope: 'baseScope');
// Returns: [FileOutput]