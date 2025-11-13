import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class UserProfileWidget extends WatchingWidget {
  const UserProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch three separate values - widget rebuilds when ANY changes
    final name = watchValue((SimpleUserManager m) => m.name);
    final email = watchValue((SimpleUserManager m) => m.email);
    final avatarUrl = watchValue((SimpleUserManager m) => m.avatarUrl);

    return Column(
      children: [
        if (avatarUrl.isNotEmpty)
          CircleAvatar(backgroundImage: NetworkImage(avatarUrl)),
        Text(name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(email, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: Scaffold(body: UserProfileWidget())));
}
