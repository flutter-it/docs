import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
setUp(() {
     getIt.pushNewScope();
     getIt.registerSingleton<ApiClient>(MockApiClient()); // Only mock this
     // Everything else uses real registrations from base scope
   });
// #endregion example
