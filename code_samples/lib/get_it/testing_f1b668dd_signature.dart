import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
setUp(() => getIt.pushNewScope());
   tearDown(() async => await getIt.popScope());
// #endregion example
