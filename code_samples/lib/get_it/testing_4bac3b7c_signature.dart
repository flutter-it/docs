import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// ❌ Bad - scopes leak into next test
   test('...', () {
     getIt.pushNewScope();
     // ... test code
     // Missing popScope()!
   });
// #endregion example
