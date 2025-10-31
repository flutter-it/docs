import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  abstract class ILogger {}
  class FileLogger implements ILogger {}
  class ConsoleLogger implements ILogger {}

  // Approach 1: Multiple registrations with getAll()
  getIt.enableRegisteringMultipleInstancesOfOneType();
  getIt.registerSingleton<ILogger>(FileLogger());
  getIt.registerSingleton<ILogger>(ConsoleLogger());

  final loggers1 = getIt.getAll<ILogger>();
  print('loggers1: $loggers1');
  // Returns: [FileLogger, ConsoleLogger]

  // Approach 2: Different registration types with findAll()
  getIt.registerSingleton<FileLogger>(FileLogger());
  getIt.registerSingleton<ConsoleLogger>(ConsoleLogger());

  final loggers2 = getIt.findAll<ILogger>();
  print('loggers2: $loggers2');
  // Returns: [FileLogger, ConsoleLogger] (matched by type)
}
// #endregion example