import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
  void checkStatus() {
    if (getIt.isReadySync<Database>()) {
      print('Database is ready');
    } else {
      print('Database still initializing...');
    }
  }
}
// #endregion example
