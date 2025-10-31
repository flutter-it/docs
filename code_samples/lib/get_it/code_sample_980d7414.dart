import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() {
  // #region example
  getIt.enableRegisteringMultipleInstancesOfOneType();
  // #endregion example
}
