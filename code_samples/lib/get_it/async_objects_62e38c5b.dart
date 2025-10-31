import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
class ConfigService implements WillSignalReady {
  bool isReady = false;

  ConfigService() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadConfig();
    isReady = true;
    GetIt.instance.signalReady(this);
  }

  Future<void> loadConfig() async {}
}

void configureDependencies() {
  // No signalsReady parameter needed - interface handles it
  getIt.registerSingleton<ConfigService>(ConfigService());
}
// #endregion example
