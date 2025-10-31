import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

// #region example
class RestService {
  Future<RestService> init() async {
    // do your async initialisation...
    await Future.delayed(Duration(seconds: 2));
    return this;
  }
}

Future<void> setup() async {
  // Pattern: Create instance and call init() in one expression
  getIt.registerSingletonAsync<RestService>(() async => RestService().init());

  // Wait for all async singletons to be ready
  await getIt.allReady();

  // Now access normally
  final service = getIt<RestService>();
}
// #endregion example

void main() async {
  setup();
}
