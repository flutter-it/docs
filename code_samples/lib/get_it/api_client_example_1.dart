import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
// Register multiple REST services with different configurations
  getIt.registerSingleton<ApiClient>(
    ApiClient('https://api.example.com'),
    instanceName: 'mainApi',
  );

  getIt.registerSingleton<ApiClient>(
    ApiClient('https://analytics.example.com'),
    instanceName: 'analyticsApi',
  );

// Access individually by name
  final mainApi = getIt<ApiClient>(instanceName: 'mainApi');
  print('mainApi: $mainApi');
  final analyticsApi = getIt<ApiClient>(instanceName: 'analyticsApi');
  print('analyticsApi: $analyticsApi');
}
// #endregion example
