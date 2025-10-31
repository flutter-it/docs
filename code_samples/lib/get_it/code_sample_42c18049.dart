import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// Register factory accepting two parameters
getIt.registerFactoryParam<UserViewModel, String, int>(
  (userId, age) => UserViewModel(userId: userId, age: age),
);

// Access with parameters
final vm = getIt<UserViewModel>(param1: 'user-123', param2: 25);
// #endregion example