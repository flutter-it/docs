import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() {
  test('factory param passes parameters correctly', () async {
    getIt.pushNewScope();

    getIt.registerFactoryParam<UserViewModel, String, void>(
      (userId, _) => UserViewModel(userId),
    );

    final vm = getIt<UserViewModel>(param1: 'user-123');
    print('vm: $vm');
    expect(vm.userId, 'user-123');

    await getIt.popScope();
  });
}
// #endregion example
