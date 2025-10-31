import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  // Base scope
  getIt.registerSingleton<User>(GuestUser());

  // Push new scope
  getIt.pushNewScope(scopeName: 'logged-in');
  getIt.registerSingleton<User>(LoggedInUser());

  getIt<User>(); // Returns LoggedInUser (shadows GuestUser)

  // Pop scope
  await getIt.popScope();

  getIt<User>(); // Returns GuestUser (automatically restored)
}
// #endregion example
