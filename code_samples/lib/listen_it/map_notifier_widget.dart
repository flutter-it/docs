import '_shared/stubs.dart';

// #region example
class SettingsWidget extends StatelessWidget {
  const SettingsWidget(this.settings, {super.key});

  final MapNotifier<String, dynamic> settings;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, dynamic>>(
      valueListenable: settings,
      builder: (context, map, _) => Column(
        children: [
          Switch(
            value: map['notifications'] as bool,
            onChanged: (value) => settings['notifications'] = value,
          ),
          Text(
            'Sample Text',
            style: TextStyle(fontSize: (map['fontSize'] as int).toDouble()),
          ),
        ],
      ),
    );
  }
}
// #endregion example
