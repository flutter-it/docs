import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
class UserManager {
  final AppModel appModel;
  final DbService dbService;

  UserManager({
    AppModel? appModel,
    DbService? dbService,
  })  : appModel = appModel ?? getIt<AppModel>(),
        dbService = dbService ?? getIt<DbService>();

  Future<void> saveUser(User user) async {
    appModel.currentUser = user;
    await dbService.save(user);
  }
}

// In tests - no get_it needed
test('saveUser updates model and persists to database', () async {
  final mockModel = MockAppModel();
  final mockDb = MockDbService();

  // Create instance directly with mocks
  final manager = UserManager(appModel: mockModel, dbService: mockDb);

  await manager.saveUser(User(id: '1', name: 'Bob'));

  verify(mockDb.save(any)).called(1);
});

void main() async {
  // Setup GetIt
  getIt.registerSingleton<AppModel>(AppModel());
  getIt.registerSingleton<DbService>(DbService());

  // Use UserManager with GetIt
  final manager = UserManager();
  await manager.saveUser(User(id: '1', name: 'Alice'));
}
// #endregion example