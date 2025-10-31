import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// ❌ Bad - duplicates production setup
   setUp(() {
     getIt.registerLazySingleton<ApiClient>(...);
     getIt.registerLazySingleton<Database>(...);
     // ... 50 more registrations
   });

   // ✅ Good - reuse production setup
   setUpAll(() {
     configureDependencies(); // Call once
   });
// #endregion example
