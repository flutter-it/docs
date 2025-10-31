// ignore_for_file: unused_import, unused_local_variable, unused_element, prefer_collection_literals, use_key_in_widget_constructors, use_super_parameters, invalid_use_of_visible_for_testing_member, depend_on_referenced_packages
import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() async {
  // #region example
  const userId = 'user-123';
  const age = 25;

  // Register factory accepting two parameters
  getIt.registerFactoryParam<UserViewModel, String, int>(
    (userId, age) => UserViewModel(userId, age: age),
  );

  // Access with parameters
  final vm = getIt<UserViewModel>(param1: userId, param2: age);
  // #endregion example
  print('vm: $vm');
}
