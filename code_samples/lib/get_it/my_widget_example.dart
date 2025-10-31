import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// Feature flag scenario

void main() {
  final analyticsService = getIt.maybeGet<AnalyticsService>();
  print('analyticsService: $analyticsService');
  if (analyticsService != null) {
    analyticsService.trackEvent('user_action');
  }

  // Optional dependency
  class MyWidget extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      final logger = getIt.maybeGet<Logger>();
  print('logger: $logger');
      logger?.log('Building MyWidget'); // Safe even if Logger not registered

      return Text('Hello');
    }
  }

  // Graceful degradation
  final premiumFeature = getIt.maybeGet<PremiumFeature>();
  print('premiumFeature: $premiumFeature');
  if (premiumFeature != null) {
    return PremiumUI(feature: premiumFeature);
  } else {
    return BasicUI(); // Fallback when premium not available
  }
}
// #endregion example