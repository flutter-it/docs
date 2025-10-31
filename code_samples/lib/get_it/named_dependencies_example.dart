import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  void configureDependencies() {
    // Register multiple API clients
    getIt.registerSingletonAsync<ApiClient>(
      () async => ApiClient.create('https://api-v1.example.com'),
      instanceName: 'api-v1',
    );

    getIt.registerSingletonAsync<ApiClient>(
      () async => ApiClient.create('https://api-v2.example.com'),
      instanceName: 'api-v2',
    );

    // Depend on specific named instance
    getIt.registerSingletonWithDependencies<DataSync>(
      () => DataSync(),
      dependsOn: [InitDependency(ApiClient, instanceName: 'api-v2')],
    );
  }
}
// #endregion example
