import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// Instantiate lazy singletons that match
final all = getIt.findAll<IOutput>(
  instantiateLazySingletons: true,
);
// Returns: [FileOutput, ConsoleOutput]
// ConsoleOutput is now created and cached
// #endregion example
