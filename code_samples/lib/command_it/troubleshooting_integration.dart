// ignore_for_file: unused_local_variable
import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:watch_it/watch_it.dart';
import '_shared/stubs.dart';

Future<List<Data>> fetch() => ApiClient().fetchData();

// #region watch_it_not_registered
// ❌️ Manager not registered
class WidgetWithoutRegistration extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final data = watchValue((DataManager m) => m.command); // Fails!
    return Text('$data');
  }
}
// #endregion watch_it_not_registered

// #region register_first
void main() {
  GetIt.I.registerSingleton<DataManager>(DataManager()); // ✅ Register first
  runApp(MyApp());
}
// #endregion register_first

// #region vlb_new_instance_bad
class BadNewInstanceEveryBuild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ❌️ Creating new instance on every build
    return ValueListenableBuilder(
      valueListenable: Command.createAsync<String, List<Data>>(
        (query) => fetch(),
        initialValue: [],
      ), // New command each build!
      builder: (context, value, _) => Text('$value'),
    );
  }
}
// #endregion vlb_new_instance_bad

// #region vlb_reuse_good
class DataManager {
  late final command = Command.createAsync<String, List<Data>>(
    (query) => fetch(),
    initialValue: [],
  ); // ✅ Created once
}

class GoodReuseInstance extends StatelessWidget {
  final DataManager manager;
  const GoodReuseInstance({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    // In widget:
    return ValueListenableBuilder(
      valueListenable: manager.command, // ✅ Same instance
      builder: (context, value, _) => Text('$value'),
    );
  }
}
// #endregion vlb_reuse_good

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp();
}
