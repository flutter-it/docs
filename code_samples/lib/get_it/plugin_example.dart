// ignore_for_file: unused_import, unused_local_variable, unused_element, prefer_collection_literals, use_key_in_widget_constructors, use_super_parameters, invalid_use_of_visible_for_testing_member, depend_on_referenced_packages
import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() async {
  // #region example
  getIt.enableRegisteringMultipleInstancesOfOneType();

  getIt.registerSingleton<Plugin>(CorePlugin()); // unnamed
  getIt.registerSingleton<Plugin>(LoggingPlugin()); // unnamed
  getIt.registerSingleton<Plugin>(AnalyticsPlugin(),
      instanceName: 'analytics'); // named

  final Iterable<Plugin> allPlugins = getIt.getAll<Plugin>();
// Returns: [CorePlugin, LoggingPlugin, AnalyticsPlugin]
//          ALL unnamed + ALL named registrations
  // #endregion example
}
