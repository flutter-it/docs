import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
abstract class IOutput {
  void write(String message);
}

class FileOutput implements IOutput {
  @override
  void write(String message) => File('log.txt').writeAsStringSync(message);
}

class ConsoleOutput implements IOutput {
  @override
  void write(String message) => print(message);
}

// Register different implementation types

void main() {
  getIt.registerSingleton<FileOutput>(FileOutput());
  getIt.registerLazySingleton<ConsoleOutput>(() => ConsoleOutput());

  // Find by interface (registration type matching)
  final outputs = getIt.findAll<IOutput>();
  print('outputs: $outputs');
  // Returns: [FileOutput] only (ConsoleOutput not instantiated yet)
}
// #endregion example
