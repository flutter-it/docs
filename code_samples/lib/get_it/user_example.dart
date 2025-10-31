import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
class UserModel extends ChangeNotifier {
  String username;
  String email;

  UserModel(this.username, this.email);

  Future<void> updateUsername(String newUsername) async {
    // Update on backend via API (stubbed)
    final oldUsername = username;
    username = newUsername;

    // Rename the instance in GetIt to match new username
    getIt.changeTypeInstanceName<UserModel>(
      instanceName: oldUsername,
      newInstanceName: newUsername,
    );

    notifyListeners();
  }
}

// #endregion example

void main() async {
  // #region example
  // Register user with username as instance name
  final user = UserModel('alice', 'alice@example.com');
  getIt.registerSingleton<UserModel>(user, instanceName: 'alice');

  // User changes their username
  await getIt<UserModel>(instanceName: 'alice').updateUsername('alice_jones');

  // Now accessible with new name
  final renamedUser = getIt<UserModel>(instanceName: 'alice_jones');
  print('renamedUser: $renamedUser'); // Works!
  print('User: ${renamedUser.username}');
  // getIt<UserModel>(instanceName: 'alice'); // Would throw - old name invalid
  // #endregion example
}
