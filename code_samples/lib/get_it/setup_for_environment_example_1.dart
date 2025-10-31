import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void setupForEnvironment(String env) {
  if (env == 'production') {
    getIt.registerSingleton<ApiClient>(
      ApiClient('https://api.prod.example.com'),
      instanceName: 'api',
    );
  } else {
    getIt.registerSingleton<ApiClient>(
      MockApiClient(),
      instanceName: 'api',
    );
  }
}

// Always access with same name
final api = getIt<ApiClient>(instanceName: 'api');
// #endregion example
