import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// Feature flag scenario
final analyticsService = getIt.maybeGet<AnalyticsService>();
if (analyticsService != null) {
  analyticsService.trackEvent('user_action');
}

// Optional dependency
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logger = getIt.maybeGet<Logger>();
    logger?.log('Building MyWidget'); // Safe even if Logger not registered

    return Text('Hello');
  }
}

// Graceful degradation
final premiumFeature = getIt.maybeGet<PremiumFeature>();
if (premiumFeature != null) {
  return PremiumUI(feature: premiumFeature);
} else {
  return BasicUI(); // Fallback when premium not available
}
// #endregion example