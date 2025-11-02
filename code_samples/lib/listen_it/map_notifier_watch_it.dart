import '_shared/stubs.dart';

// #region example
class SettingsWidget extends WatchingWidget {
  const SettingsWidget(this.settings, {super.key});

  final MapNotifier<String, dynamic> settings;

  @override
  Widget build(BuildContext context) {
    final map = watch(settings).value;

    return Column(
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
    );
  }
}
// #endregion example
