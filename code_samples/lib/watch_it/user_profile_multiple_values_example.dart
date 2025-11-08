import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class UserProfile extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final name = watchValue((SimpleUserManager m) => m.name);
    final email = watchValue((SimpleUserManager m) => m.email);
    final avatar = watchValue((SimpleUserManager m) => m.avatarUrl);

    return Column(
      children: [
        Image.network(avatar),
        Text(name, style: TextStyle(fontSize: 20)),
        Text(email, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: UserProfile()));
}
