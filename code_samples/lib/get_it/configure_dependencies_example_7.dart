import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// Enable multiple registrations at app startup
void configureDependencies() {

void main() {
    getIt.enableRegisteringMultipleInstancesOfOneType();

    // Core plugins (unnamed - always loaded)
    getIt.registerSingleton<AppPlugin>(CorePlugin());
    getIt.registerSingleton<AppPlugin>(LoggingPlugin());
    getIt.registerSingleton<AppPlugin>(AnalyticsPlugin());
  }

  // Feature module registers additional plugins
  void enableShoppingFeature() {
    getIt.pushNewScope(scopeName: 'shopping');
    getIt.registerSingleton<AppPlugin>(ShoppingCartPlugin());
    getIt.registerSingleton<AppPlugin>(PaymentPlugin());
  }

  // App initialization
  class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      // Initialize all plugins
      final allPlugins = getIt.getAll<AppPlugin>(fromAllScopes: true);
  print('allPlugins: $allPlugins');
      for (final plugin in allPlugins) {
        plugin.initialize();
      }

      return MaterialApp(...);
    }
  }
}
// #endregion example