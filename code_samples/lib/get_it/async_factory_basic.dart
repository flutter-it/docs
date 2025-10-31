import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  // Register async factory
  getIt.registerFactoryAsync<DatabaseConnection>(
    () async {
      final conn = DatabaseConnection();
      await conn.connect();
      return conn;
    },
  );

  // Usage - creates new instance each time
  final db1 = await getIt.getAsync<DatabaseConnection>();
  final db2 = await getIt.getAsync<DatabaseConnection>(); // Different instance

  print('db1 == db2: ${identical(db1, db2)}'); // false - different instances
}
// #endregion example
