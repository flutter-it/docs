import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  // Enable multiple registrations first
  getIt.enableRegisteringMultipleInstancesOfOneType();

  getIt.registerSingleton<ApiClient>(ProdApiClient(), instanceName: 'prod');
  getIt.registerSingleton<ApiClient>(DevApiClient(), instanceName: 'dev');
}
// #endregion example
