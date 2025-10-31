import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  // Reset everything and call disposal functions
  await getIt.reset();

  // Reset without calling disposals
  await getIt.reset(dispose: false);
}
// #endregion example
