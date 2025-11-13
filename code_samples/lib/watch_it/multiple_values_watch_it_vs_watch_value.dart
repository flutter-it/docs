import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region manager
class UserSettings extends ChangeNotifier {
  bool _darkMode = false;
  bool _notifications = true;
  String _language = 'en';

  bool get darkMode => _darkMode;
  bool get notifications => _notifications;
  String get language => _language;

  void setDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  void setNotifications(bool value) {
    _notifications = value;
    notifyListeners();
  }

  void setLanguage(String value) {
    _language = value;
    notifyListeners();
  }
}
// #endregion manager

// #region watch_it_approach
class WatchItApproach extends WatchingWidget {
  const WatchItApproach({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the entire ChangeNotifier - rebuilds on ANY property change
    final settings = watchIt<UserSettings>();

    print('WatchItApproach rebuilt');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('watchIt() - Whole Object',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Dark mode: ${settings.darkMode}'),
            Text('Notifications: ${settings.notifications}'),
            Text('Language: ${settings.language}'),
          ],
        ),
      ),
    );
  }
}
// #endregion watch_it_approach

// #region watch_value_approach
class WatchValueApproach extends WatchingWidget {
  const WatchValueApproach({super.key});

  @override
  Widget build(BuildContext context) {
    // Can't use watchValue with ChangeNotifier directly
    // because ChangeNotifier doesn't have ValueNotifier properties

    // This widget would only show one property at a time
    // Not ideal for this use case

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('watchValue() approach',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Text(
                'Not applicable - ChangeNotifier has no ValueNotifier properties'),
          ],
        ),
      ),
    );
  }
}
// #endregion watch_value_approach

// #region better_design
class BetterDesignManager {
  // Better: Use ValueNotifiers for individual properties
  final darkMode = ValueNotifier<bool>(false);
  final notifications = ValueNotifier<bool>(true);
  final language = ValueNotifier<String>('en');
}

class BetterDesignWidget extends WatchingWidget {
  const BetterDesignWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch individual properties - only rebuilds when specific values change
    final darkMode = watchValue((BetterDesignManager m) => m.darkMode);
    final notifications =
        watchValue((BetterDesignManager m) => m.notifications);
    final language = watchValue((BetterDesignManager m) => m.language);

    print('BetterDesignWidget rebuilt');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Better: Individual ValueNotifiers',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Dark mode: $darkMode'),
            Text('Notifications: $notifications'),
            Text('Language: $language'),
          ],
        ),
      ),
    );
  }
}
// #endregion better_design

void main() {
  di.registerSingleton<UserSettings>(UserSettings());
  di.registerSingleton<BetterDesignManager>(BetterDesignManager());

  runApp(MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WatchItApproach(),
            const SizedBox(height: 16),
            WatchValueApproach(),
            const SizedBox(height: 16),
            BetterDesignWidget(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                di<UserSettings>().setDarkMode(!di<UserSettings>().darkMode);
              },
              child: const Text('Toggle Dark Mode'),
            ),
          ],
        ),
      ),
    ),
  ));
}
