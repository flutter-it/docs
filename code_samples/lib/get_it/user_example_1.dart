import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
class User extends ChangeNotifier {
  String username;
  String email;

  User(this.username, this.email);

  Future<void> updateUsername(String newUsername) async {
    // Update on backend
    await api.updateUsername(username, newUsername);

    final oldUsername = username;
    username = newUsername;

    // Rename the instance in GetIt to match new username
    getIt.changeTypeInstanceName<User>(
      instanceName: oldUsername,
      newInstanceName: newUsername,
    );

    notifyListeners();
  }
}

// Register user with username as instance name
final user = User('alice', 'alice@example.com');
getIt.registerSingleton<User>(user, instanceName: 'alice');

// User changes their username
await getIt<User>(instanceName: 'alice').updateUsername('alice_jones');

// Now accessible with new name
final user = getIt<User>(instanceName: 'alice_jones'); // Works!
// getIt<User>(instanceName: 'alice'); // Would throw - old name invalid
// #endregion example