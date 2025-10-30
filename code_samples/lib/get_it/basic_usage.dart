// Basic usage example for get_it
import 'package:get_it/get_it.dart';

// Sample services
class ApiClient {
  void fetchData() {
    print('Fetching data...');
  }
}

class Database {
  void save(String data) {
    print('Saving: $data');
  }
}

class AuthService {
  Future<String> login(String username, String password) async {
    return 'User: $username';
  }
}

// #region setup
final getIt = GetIt.instance;

void configureDependencies() {
  // Register your services
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<Database>(() => Database());
  getIt.registerLazySingleton<AuthService>(() => AuthService());
}
// #endregion

// #region access
void accessServices() async {
  // Access services
  final api = getIt<ApiClient>();
  final db = getIt<Database>();
  final auth = getIt<AuthService>();

  // Use them
  api.fetchData();
  db.save('data');
  final user = await auth.login('alice', 'secret');
  print(user);
}
// #endregion

// #region registration-types
void registrationExamples() {
  // Singleton - created immediately, used for entire app lifetime
  getIt.registerSingleton<ApiClient>(ApiClient());

  // LazySingleton - created on first use, used for entire app lifetime
  getIt.registerLazySingleton<Database>(() => Database());

  // Factory - new instance every time you call getIt<T>()
  getIt.registerFactory<AuthService>(() => AuthService());
}
// #endregion
