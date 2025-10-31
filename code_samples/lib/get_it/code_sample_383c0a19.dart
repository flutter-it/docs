import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() async {
  // #region example
// ❌ Trying to get without registering first
  final service = getIt<MyService>();
  print('service: $service'); // ERROR!
  // #endregion example
}
