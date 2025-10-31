import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
Future<void> isReady<T>({
  Object? instance,
  String? instanceName,
  Duration? timeout,
  Object? callee,
})
// #endregion example
