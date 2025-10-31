import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
// ❌ Trying to get without registering first
  final service = getIt<MyService>();
  print('service: $service'); // ERROR!
}
// #endregion example
