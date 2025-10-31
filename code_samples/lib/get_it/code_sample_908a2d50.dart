import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  // Access services
  final api = getIt<ApiClient>();
  print('api: $api');
  final db = getIt<Database>();
  print('db: $db');
  final auth = getIt<AuthService>();
  print('auth: $auth');

  // Use them
  final data = await api.fetchData();
  await db.save(data);
  final user = await auth.login('alice', 'secret');
  print('user: $user');
}
// #endregion example
