import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  getIt.registerFactory<IOutput>(() => RemoteOutput());

// Include factories by calling them
  final withFactories = getIt.findAll<IOutput>(
    instantiateLazySingletons: true,
    callFactories: true,
  );
// Returns: [FileOutput, ConsoleOutput, RemoteOutput]
// Each factory call creates a new instance
}
// #endregion example
