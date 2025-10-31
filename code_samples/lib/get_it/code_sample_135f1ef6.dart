import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
// Register a cached factory
  getIt.registerCachedFactory<HeavyParser>(() => HeavyParser());

// First call - creates instance
  final parser1 = getIt<HeavyParser>();
  print('parser1: $parser1'); // New instance created

// Second call - reuses if not garbage collected
  final parser2 = getIt<HeavyParser>();
  print('parser2: $parser2'); // Same instance (if still in memory)

// After garbage collection (no references held)
  final parser3 = getIt<HeavyParser>();
  print('parser3: $parser3'); // New instance created
}
// #endregion example
