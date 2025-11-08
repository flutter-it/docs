import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class SettingsPage extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final settings = createOnce(() => SettingsModel());

    // registerChangeNotifierHandler listens to a ChangeNotifier
    // and executes a handler whenever it changes
    // Useful for side effects like saving to storage, analytics, etc.
    registerChangeNotifierHandler(
      target: settings,
      handler: (context, notifier, cancel) {
        // Save settings whenever they change
        debugPrint('Settings changed - saving to storage...');
        // In real app: await StorageService.saveSettings(settings)
      },
    );

    // Watch individual properties for UI updates
    watch(settings);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: settings.darkMode,
              onChanged: settings.setDarkMode,
            ),
            const Divider(),
            ListTile(
              title: const Text('Language'),
              subtitle: Text(settings.language),
              trailing: DropdownButton<String>(
                value: settings.language,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'es', child: Text('Spanish')),
                  DropdownMenuItem(value: 'fr', child: Text('French')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    settings.setLanguage(value);
                  }
                },
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Font Size'),
              subtitle: Slider(
                value: settings.fontSize,
                min: 10,
                max: 24,
                divisions: 14,
                label: settings.fontSize.round().toString(),
                onChanged: settings.setFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// #endregion example

void main() {
  runApp(MaterialApp(
    home: SettingsPage(),
  ));
}
