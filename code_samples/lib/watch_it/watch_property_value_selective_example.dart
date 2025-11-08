import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class ThemeSwitch extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Only rebuilds when darkMode changes, not language or fontSize
    final darkMode = watchPropertyValue((SettingsModel m) => m.darkMode);

    return Switch(
      value: darkMode,
      onChanged: (value) => di<SettingsModel>().setDarkMode(value),
    );
  }
}
// #endregion example

void main() {
  di.registerSingleton<SettingsModel>(SettingsModel());
  runApp(MaterialApp(home: ThemeSwitch()));
}
