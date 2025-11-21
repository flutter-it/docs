// ignore_for_file: unused_import
import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() async {
  // #region example
  // resetScope - clears all registrations in current scope but keeps scope
  await getIt.resetScope(dispose: true);

  // popScope - removes entire scope and restores previous
  await getIt.popScope();
  // #endregion example
}
