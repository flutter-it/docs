import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  // Base scope
  getIt.registerSingleton<IOutput>(FileOutput());

  // Push scope
  getIt.pushNewScope(scopeName: 'session');
  getIt.registerSingleton<IOutput>(ConsoleOutput());

  // Current scope only (default)
  final current = getIt.findAll<IOutput>();
  print('current: $current');
  // Returns: [ConsoleOutput]

  // All scopes
  final all = getIt.findAll<IOutput>(inAllScopes: true);
  print('all: $all');
  // Returns: [ConsoleOutput, FileOutput]

  // Specific scope
  final base = getIt.findAll<IOutput>(onlyInScope: 'baseScope');
  print('base: $base');
  // Returns: [FileOutput]
}
// #endregion example
