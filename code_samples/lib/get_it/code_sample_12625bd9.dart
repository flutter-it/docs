import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

// #region example
List<T> findAll<T>({
  bool includeSubtypes = true,
  bool inAllScopes = false,
  String? onlyInScope,
  bool includeMatchedByRegistrationType = true,
  bool includeMatchedByInstance = true,
  bool instantiateLazySingletons = false,
  bool callFactories = false,
})
// #endregion example