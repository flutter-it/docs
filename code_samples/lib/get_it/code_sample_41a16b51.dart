import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  getIt.registerSingletonAsync<Database>(
    () async => Database.connect('postgres://main-db'),
    instanceName: 'mainDb',
  );

  getIt.registerSingletonAsync<Database>(
    () async => Database.connect('postgres://analytics-db'),
    instanceName: 'analyticsDb',
  );

  getIt.registerSingletonAsync<Database>(
    () async => Database.connect('postgres://cache-db'),
    instanceName: 'cacheDb',
  );
}
// #endregion example
