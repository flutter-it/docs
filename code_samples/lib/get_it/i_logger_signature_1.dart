// ignore_for_file: missing_function_body, unused_element
abstract class ILogger {}
class FileLogger implements ILogger {}
class ConsoleLogger implements ILogger {}

// Approach 1: Multiple registrations with getAll()
getIt.enableRegisteringMultipleInstancesOfOneType();
getIt.registerSingleton<ILogger>(FileLogger());
getIt.registerSingleton<ILogger>(ConsoleLogger());

final loggers1 = getIt.getAll<ILogger>();
// Returns: [FileLogger, ConsoleLogger]

// Approach 2: Different registration types with findAll()
getIt.registerSingleton<FileLogger>(FileLogger());
getIt.registerSingleton<ConsoleLogger>(ConsoleLogger());

final loggers2 = getIt.findAll<ILogger>();
// Returns: [FileLogger, ConsoleLogger] (matched by type)