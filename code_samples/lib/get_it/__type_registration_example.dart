import 'package:get_it/get_it.dart';
import 'dart:collection';

// #region example
class _ObjectRegistration {}

class _TypeRegistration<T> {
  final registrations = <_ObjectRegistration>[]; // Unnamed registrations
  final namedRegistrations =
      LinkedHashMap<String, _ObjectRegistration>(); // Named registrations
}
// #endregion example
