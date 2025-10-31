// ignore_for_file: unused_import, unused_local_variable, unused_element, prefer_collection_literals, use_key_in_widget_constructors, use_super_parameters, invalid_use_of_visible_for_testing_member, depend_on_referenced_packages
import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
abstract class AppLifecycleObserver {
  void onAppStarted();
  void onAppPaused();
  void onAppResumed();
}

class AnalyticsObserver implements AppLifecycleObserver {
  @override
  void onAppStarted() {}
  @override
  void onAppPaused() {}
  @override
  void onAppResumed() {}
}

class LoggingObserver implements AppLifecycleObserver {
  @override
  void onAppStarted() {}
  @override
  void onAppPaused() {}
  @override
  void onAppResumed() {}
}

class CacheObserver implements AppLifecycleObserver {
  @override
  void onAppStarted() {}
  @override
  void onAppPaused() {}
  @override
  void onAppResumed() {}
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

void main() {
  getIt.enableRegisteringMultipleInstancesOfOneType();

  // Multiple observers can register
  getIt.registerSingleton<AppLifecycleObserver>(AnalyticsObserver());
  getIt.registerSingleton<AppLifecycleObserver>(LoggingObserver());
  getIt.registerSingleton<AppLifecycleObserver>(CacheObserver());
}
// #endregion example
