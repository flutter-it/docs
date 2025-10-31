import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() {
  // #region example
  test('service lifecycle matches scope lifecycle', () async {
    // Base scope
    getIt.registerLazySingleton<CoreService>(() => CoreService());

    // Feature scope
    getIt.pushNewScope(scopeName: 'feature');
    getIt.registerLazySingleton<FeatureService>(() => FeatureService(getIt()));

    expect(getIt<CoreService>(), isNotNull);
    expect(getIt<FeatureService>(), isNotNull);

    // Pop feature scope
    await getIt.popScope();

    expect(getIt<CoreService>(), isNotNull); // Still available
    expect(() => getIt<FeatureService>(), throwsStateError); // Gone!
  });
  // #endregion example
}
