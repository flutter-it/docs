import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

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

  Future<void> connectToDatabase() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  Future<void> runMigrations() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }
}
// #endregion example
