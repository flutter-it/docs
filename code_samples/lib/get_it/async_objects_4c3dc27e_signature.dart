import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
Future<T> getAsync<T>({
  String? instanceName,
  dynamic param1,
  dynamic param2,
  Type? type,
})
// #endregion example
