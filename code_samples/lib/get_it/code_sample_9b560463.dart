import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() async {
  // #region example
  await getIt.unregister<AuthService>(
    disposingFunction: (service) async {
      await service.cleanup(); // Custom cleanup logic
    },
  );
  // #endregion example
}
