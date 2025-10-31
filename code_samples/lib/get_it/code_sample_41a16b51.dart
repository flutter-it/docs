import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() async {
// #region example
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
// #endregion example
}
