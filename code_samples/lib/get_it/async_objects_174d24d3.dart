import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

// #region example
class DatabaseService {
  DatabaseService() {
    _init();
  }

  Future<void> _init() async {
    await connectToDatabase();
    await runMigrations();

    // Signal this instance is ready
    GetIt.instance.signalReady(this);
  }

  Future<void> connectToDatabase() async {}
  Future<void> runMigrations() async {}
}
// #endregion example
