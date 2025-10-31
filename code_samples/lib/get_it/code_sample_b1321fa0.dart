import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

// #region example
final registrations = [
  ...typeRegistration.registrations, // ALL unnamed
  ...typeRegistration.namedRegistrations.values, // ALL named
];
// #endregion example
