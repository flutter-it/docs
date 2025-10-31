import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
Future<void> main() async {
  // ❌ Bad - loses all registrations
  tearDown(() async {
    await getIt.reset();
  });

  // ✅ Good - use scopes instead
  tearDown(() async {
    await getIt.popScope();
  });
}
// #endregion example
