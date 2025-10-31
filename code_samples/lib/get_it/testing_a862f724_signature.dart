import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// ❌ Bad - masks bugs
   getIt.allowReassignment = true;

   // ✅ Good - use scopes for isolation
// #endregion example
