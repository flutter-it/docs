import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
abstract class AppLifecycleObserver {
  void onAppStarted();
  void onAppPaused();
  void onAppResumed();
}

void setupApp() {

void main() {
    getIt.enableRegisteringMultipleInstancesOfOneType();

    // Multiple observers can register
    getIt.registerSingleton<AppLifecycleObserver>(AnalyticsObserver());
    getIt.registerSingleton<AppLifecycleObserver>(LoggingObserver());
    getIt.registerSingleton<AppLifecycleObserver>(CacheObserver());
  }

  class AppLifecycleManager {
    void notifyAppStarted() {
      final observers = getIt.getAll<AppLifecycleObserver>();
  print('observers: $observers');
      for (final observer in observers) {
        observer.onAppStarted();
      }
    }

    void notifyAppPaused() {
      final observers = getIt.getAll<AppLifecycleObserver>();
  print('observers: $observers');
      for (final observer in observers) {
        observer.onAppPaused();
      }
    }
  }
}
// #endregion example