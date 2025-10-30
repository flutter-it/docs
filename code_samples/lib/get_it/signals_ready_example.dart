import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
class ConfigService {
  bool isReady = false;

  ConfigService() {
    _initialize();
  }

  Future<void> _initialize() async {
    // Complex async initialization
    await loadRemoteConfig();
    await validateConfig();
    await setupConnections();

    isReady = true;
    // Signal that we're ready
    GetIt.instance.signalReady(this);
  }

  Future<void> loadRemoteConfig() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  Future<void> validateConfig() async {}
  Future<void> setupConnections() async {}
}

void configureDependencies() {
  getIt.registerSingleton<ConfigService>(
    ConfigService(),
    signalsReady: true, // Must manually signal ready
  );
}

void main() async {
  // Wait for ready signal
  await getIt.isReady<ConfigService>();
}
// #endregion example
