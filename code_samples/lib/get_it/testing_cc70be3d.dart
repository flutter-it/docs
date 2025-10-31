import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
Future<void> main() async {
  await getIt.allReady(); // Wait before testing
}
// #endregion example
