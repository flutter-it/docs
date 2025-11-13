import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import 'package:listen_it/listen_it.dart';
import '_shared/stubs.dart';

class UserDisplayData {
  final String fullName;
  final String avatarUrl;

  UserDisplayData(this.fullName, this.avatarUrl);
}

// #region manager
class UserProfileManager {
  final firstName = ValueNotifier<String>('John');
  final lastName = ValueNotifier<String>('Doe');
  final avatarUrl = ValueNotifier<String>('https://example.com/avatar.png');

  // Combine 3 values into a computed display object
  late final userDisplay = firstName.combineLatest3(
    lastName,
    avatarUrl,
    (first, last, avatar) => UserDisplayData('$first $last', avatar),
  );
}
// #endregion manager

// #region widget
class UserDisplayWidget extends WatchingWidget {
  const UserDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the combined result - one subscription, one rebuild trigger
    final display = watchValue((UserProfileManager m) => m.userDisplay);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(display.avatarUrl),
        ),
        const SizedBox(height: 16),
        Text(
          display.fullName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
// #endregion widget

void main() {
  di.registerSingleton<UserProfileManager>(UserProfileManager());
  runApp(MaterialApp(home: Scaffold(body: Center(child: UserDisplayWidget()))));
}
