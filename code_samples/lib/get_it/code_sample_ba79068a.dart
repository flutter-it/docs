// ignore_for_file: unused_import, unused_local_variable, unused_element, prefer_collection_literals, use_key_in_widget_constructors, use_super_parameters, invalid_use_of_visible_for_testing_member, depend_on_referenced_packages
import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

// #region example
class _ObjectRegistration {}

// #endregion example

void main() async {
  // #region example
  final Map<String, _ObjectRegistration> namedRegistrations = {};
  final List<_ObjectRegistration> registrations = [];

  _ObjectRegistration? getRegistration(String? name) {
    return name != null
        ? namedRegistrations[name] // If name provided, look in map
        : registrations.firstOrNull; // Otherwise, return FIRST from list
  }
  // #endregion example
}
