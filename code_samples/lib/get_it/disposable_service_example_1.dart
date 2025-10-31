import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
class DisposableService implements Disposable {
  bool disposed = false;

  @override
  FutureOr onDispose() {
    disposed = true;
  }
}

test('services are disposed when scope is popped', () async {
  getIt.pushNewScope();

  final service = DisposableService();
  getIt.registerSingleton<DisposableService>(service);

  expect(service.disposed, false);

  await getIt.popScope();

  expect(service.disposed, true);
});
// #endregion example