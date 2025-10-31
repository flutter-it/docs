import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
class BaseLogger {}
class FileLogger extends BaseLogger {}
class ConsoleLogger extends BaseLogger {}

getIt.registerSingleton<BaseLogger>(FileLogger());
getIt.registerSingleton<BaseLogger>(ConsoleLogger());

// Find subtypes (default)
final allLoggers = getIt.findAll<BaseLogger>();
// Returns: [FileLogger, ConsoleLogger]

// Find exact type only
final exactBase = getIt.findAll<BaseLogger>(
  includeSubtypes: false,
);
// Returns: [] (no exact BaseLogger instances, only subtypes)
// #endregion example