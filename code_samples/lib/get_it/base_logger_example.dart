// ignore_for_file: unused_import, unused_local_variable, unused_element, prefer_collection_literals, use_key_in_widget_constructors, use_super_parameters, invalid_use_of_visible_for_testing_member, depend_on_referenced_packages
import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
class BaseLogger {}

class FileLogger extends BaseLogger {}

class ConsoleLogger extends BaseLogger {}

void main() {
  getIt.registerSingleton<BaseLogger>(FileLogger());
  getIt.registerSingleton<BaseLogger>(ConsoleLogger());

  // Find subtypes (default)
  final allLoggers = getIt.findAll<BaseLogger>();
  print('allLoggers: $allLoggers');
  // Returns: [FileLogger, ConsoleLogger]

  // Find exact type only
  final exactBase = getIt.findAll<BaseLogger>(
    includeSubtypes: false,
  );
  // Returns: [] (no exact BaseLogger instances, only subtypes)
}
// #endregion example
