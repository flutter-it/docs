import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
class UserManager {
  final dynamic appModel;
  final dynamic dbService;

  UserManager({
    dynamic appModel,
    dynamic dbService,
  })  : appModel = appModel ?? getIt<AppModel>(),
        dbService = dbService ?? getIt<DbService>();

  Future<void> saveUser(User user) async {
    appModel.currentUser = user;
    await dbService.save(user);
  }
}

void main() async {
  // Example: In tests - no get_it needed
  final mockModel = MockAppModel();
  final mockDb = MockDbService();

  // Create instance directly with mocks
  final manager = UserManager(appModel: mockModel, dbService: mockDb);

  await manager.saveUser(User(id: '1', name: 'Bob'));

  print('Test passed: User saved to mock database');

  // Example: Using with GetIt

  // Setup GetIt
  getIt.registerSingleton<AppModel>(AppModel());
  getIt.registerSingleton<DbService>(DbService());

  // Use UserManager with GetIt
  final managerWithGetIt = UserManager();
  await managerWithGetIt.saveUser(User(id: '1', name: 'Alice'));
}
// #endregion example
