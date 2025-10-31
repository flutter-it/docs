import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
// Unregister by type with cleanup
  getIt.unregister<Database>(
    disposingFunction: (db) => db.close(),
  );

// Unregister by instance name
  getIt.unregister<ApiClient>(instanceName: 'legacy-api');

// Unregister specific instance
  final myService = getIt<MyService>();
  print('myService: $myService');
  getIt.unregister<MyService>(
    instance: myService,
    disposingFunction: (s) => s.dispose(),
  );
}
// #endregion example
