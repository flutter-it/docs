import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
Future<T> withRetry<T>(
  Future<T> Function() operation, {
  int maxAttempts = 3,
}) async {
  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await operation();
    } catch (e) {
      if (attempt == maxAttempts) rethrow;
      await Future.delayed(Duration(seconds: attempt));
    }
  }
  throw StateError('Should never reach here');
}

void configureDependencies() {
  getIt.registerSingletonAsync<ApiClient>(
    () => withRetry(() async => ApiClient.connect()),
  );
}
// #endregion example
