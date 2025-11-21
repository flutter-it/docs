// ignore_for_file: unused_import
import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() async {
  // #region example
  // Reset everything and call disposal functions
  await getIt.reset();

  // Reset without calling disposals
  await getIt.reset(dispose: false);
  // #endregion example
}
