// ignore_for_file: unused_import, unused_local_variable, unused_element, prefer_collection_literals, use_key_in_widget_constructors, use_super_parameters, invalid_use_of_visible_for_testing_member, depend_on_referenced_packages
import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
// Register as FileOutput but it implements IOutput
  getIt.registerSingleton<FileOutput>(FileOutput('/path/to/file.txt'));

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
