import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class UserProfileWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // watchPropertyValue watches a ChangeNotifier and extracts a specific property
    // Widget only rebuilds when that property changes, not when other properties change
    // This is more efficient than watching the entire object

    final settings = createOnce(() => SettingsModel());

    // Watch just the darkMode property
    watch(settings);
    final darkMode = settings.darkMode;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Dark Mode: ${darkMode ? "ON" : "OFF"}'),
        const SizedBox(height: 16),
        Switch(
          value: darkMode,
          onChanged: (value) => settings.setDarkMode(value),
        ),
        const SizedBox(height: 24),
        Text('Language: ${settings.language}'),
        const SizedBox(height: 8),
        Text(
          'Sample Text',
          style: TextStyle(fontSize: settings.fontSize),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => settings.setFontSize(settings.fontSize - 2),
              child: const Text('A-'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => settings.setFontSize(settings.fontSize + 2),
              child: const Text('A+'),
            ),
          ],
        ),
      ],
    );
  }
}
// #endregion example

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: UserProfileWidget(),
      ),
    ),
  ));
}
