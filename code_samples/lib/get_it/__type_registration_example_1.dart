import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

// #region example
class _TypeRegistration<T> {
  final registrations = <_ObjectRegistration>[];           // Unnamed registrations
  final namedRegistrations = LinkedHashMap<String, ...>(); // Named registrations
}
// #endregion example