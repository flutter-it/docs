import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void setupPaymentProcessor(bool useNewVersion) {
  if (useNewVersion) {
    getIt.registerSingleton<PaymentProcessor>(
      StripePaymentProcessor(),
      instanceName: 'payment',
    );
  } else {
    getIt.registerSingleton<PaymentProcessor>(
      LegacyPaymentProcessor(),
      instanceName: 'payment',
    );
  }
}
// #endregion example
