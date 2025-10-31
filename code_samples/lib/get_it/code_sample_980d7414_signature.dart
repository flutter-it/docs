import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  getIt.enableRegisteringMultipleInstancesOfOneType();
}
// #endregion example
