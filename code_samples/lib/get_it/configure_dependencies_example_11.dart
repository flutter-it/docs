import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
@injectable
class ApiClient {}

@Injectable(as: IAuthService)
class AuthService implements IAuthService {
  AuthService(ApiClient client);
}

@injectable
class UserRepository {
  UserRepository(ApiClient client, AuthService auth);
}

// Generated code handles all registrations!
@InjectableInit()
void configureDependencies() => getIt.init();
// #endregion example
