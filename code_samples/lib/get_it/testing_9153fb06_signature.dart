import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
test('async test', () async {

Future<void> main() async {
  await getIt.allReady(); // Wait for all async registrations
  final db = getIt<Database>();
  // ...
  });
}
// #endregion example
