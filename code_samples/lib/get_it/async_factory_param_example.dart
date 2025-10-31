import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() async {
  // #region example
  // Register async factory with two parameters
  getIt.registerFactoryParamAsync<UserViewModel, String, int>(
    (userId, age) async {
      // Simulate async initialization (e.g., fetch from API)
      await Future.delayed(Duration(milliseconds: 100));
      return UserViewModel(userId, age: age);
    },
  );

  // Access with parameters
  final vm = await getIt.getAsync<UserViewModel>(
    param1: 'user-123',
    param2: 25,
  );
  // #endregion example

  print('Created ViewModel for user: ${vm.userId}');
}
