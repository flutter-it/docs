import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
class MyService implements Disposable {
  StreamSubscription? _subscription;

  void init() {
    _subscription = stream.listen(...);
  }

  @override
  Future<void> onDispose() async {
    await _subscription?.cancel();
    // Cleanup resources
  }
}

// Automatically calls onDispose when scope pops or object is unregistered

void main() {
  getIt.registerSingleton<MyService>(MyService()..init());
}
// #endregion example