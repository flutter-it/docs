import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void configureDependencies() {
  // Register async factory
  getIt.registerFactoryAsync<DatabaseConnection>(
    () async {
      final conn = DatabaseConnection();
      await conn.connect();
      return conn;
    },
  );

  // Register with instance name
  getIt.registerFactoryAsync<ApiClient>(
    () async => ApiClient.create('https://api-v2.example.com'),
    instanceName: 'api-v2',
  );
}

// Usage - creates new instance each time

void main() async {
  final db1 = await getIt.getAsync<DatabaseConnection>();
  final db2 = await getIt.getAsync<DatabaseConnection>(); // New instance
}
// #endregion example
