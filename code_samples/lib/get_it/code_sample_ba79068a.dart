import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

// #region example
void main() async {
  _ObjectRegistration? getRegistration(String? name) {
    return name != null
        ? namedRegistrations[name] // If name provided, look in map
        : registrations.firstOrNull; // Otherwise, return FIRST from list
  }
}
// #endregion example
