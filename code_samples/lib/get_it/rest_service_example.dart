import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
abstract class RestService {
  Future<Response> get(String endpoint);
}

class RestServiceImpl implements RestService {
  final String baseUrl;

  RestServiceImpl(this.baseUrl);

  @override
  Future<Response> get(String endpoint) async {
    return http.get('$baseUrl/$endpoint');
  }
}

// Register multiple REST services with different base URLs
getIt.registerSingleton<RestService>(
  RestServiceImpl('https://api.example.com'),
  instanceName: 'mainApi',
);

getIt.registerSingleton<RestService>(
  RestServiceImpl('https://analytics.example.com'),
  instanceName: 'analyticsApi',
);

// Access them by name
class UserRepository {
  UserRepository() {
    _mainApi = getIt<RestService>(instanceName: 'mainApi');
    _analyticsApi = getIt<RestService>(instanceName: 'analyticsApi');
  }

  late final RestService _mainApi;
  late final RestService _analyticsApi;

  Future<User> getUser(String id) async {
    final response = await _mainApi.get('users/$id');
    _analyticsApi.get('track/user_fetch'); // Track analytics
    return User.fromJson(response.data);
  }
}
}
// #endregion example