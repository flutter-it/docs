import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  getIt.registerSingleton(TestClass());

  final instance1 = getIt.get(type: TestClass);
  print('instance1: $instance1');

  expect(instance1 is TestClass, true);
}
// #endregion example
