import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
tearDown(() async {

Future<void> main() async {
  await getIt.popScope(); // Always await!
  });
}
// #endregion example
