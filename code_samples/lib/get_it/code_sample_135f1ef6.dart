import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
// Register a cached factory
getIt.registerCachedFactory<HeavyParser>(() => HeavyParser());

// First call - creates instance
final parser1 = getIt<HeavyParser>(); // New instance created

// Second call - reuses if not garbage collected
final parser2 = getIt<HeavyParser>(); // Same instance (if still in memory)

// After garbage collection (no references held)
final parser3 = getIt<HeavyParser>(); // New instance created
// #endregion example