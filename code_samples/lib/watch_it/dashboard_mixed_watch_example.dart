import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class Dashboard extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // watchValue - for ValueListenable property
    final userName = watchValue((SimpleUserManager m) => m.name);

    // watchPropertyValue - selective rebuild
    final darkMode = watchPropertyValue((SettingsModel m) => m.darkMode);

    // watch - local state
    final searchQuery = createOnce(() => ValueNotifier<String>(''));
    final query = watch(searchQuery).value;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, $userName'),
        backgroundColor: darkMode ? Colors.black : Colors.blue,
      ),
      body: Column(
        children: [
          TextField(
            onChanged: (value) => searchQuery.value = value,
          ),
          Text('Searching: $query'),
        ],
      ),
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();
  di.registerLazySingleton<SettingsModel>(() => SettingsModel());
  runApp(MaterialApp(home: Dashboard()));
}
