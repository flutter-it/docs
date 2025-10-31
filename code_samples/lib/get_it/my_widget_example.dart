import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// Feature flag scenario
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = getIt.maybeGet<Logger>();
    print('logger: $logger');
    logger?.log('Building MyWidget'); // Safe even if Logger not registered

    return const Text('Hello');
  }
}

// Graceful degradation
Widget getUIForPremiumStatus() {
  final premiumFeature = getIt.maybeGet<PremiumFeature>();
  print('premiumFeature: $premiumFeature');
  if (premiumFeature != null) {
    return PremiumUI(feature: premiumFeature);
  } else {
    return const BasicUI(); // Fallback when premium not available
  }
}

void main() {
  final analyticsService = getIt.maybeGet<AnalyticsService>();
  print('analyticsService: $analyticsService');
  if (analyticsService != null) {
    analyticsService.trackEvent('user_action');
  }

  final ui = getUIForPremiumStatus();
  print('UI: $ui');
}
// #endregion example
