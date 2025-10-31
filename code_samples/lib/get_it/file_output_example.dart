import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
// Register as FileOutput but it implements IOutput
  getIt.registerSingleton<FileOutput>(FileOutput());

// Match by registration type
  final byRegistration = getIt.findAll<IOutput>(
    includeMatchedByRegistrationType: true,
    includeMatchedByInstance: false,
  );
// Returns: [] (registered as FileOutput, not IOutput)

// Match by instance type
  final byInstance = getIt.findAll<IOutput>(
    includeMatchedByRegistrationType: false,
    includeMatchedByInstance: true,
  );
// Returns: [FileOutput] (instance implements IOutput)
}
// #endregion example
