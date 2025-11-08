import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class UserProfile extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Synchronous data
    final userName = watchValue((SimpleUserManager m) => m.name);

    // Asynchronous data
    final avatarSnapshot = watchFuture(
      (UserService s) => s.fetchAvatar(userName),
      initialValue: null,
    );

    return Column(
      children: [
        Text(userName),
        avatarSnapshot.hasData
            ? Image.network(avatarSnapshot.data!)
            : CircularProgressIndicator(),
      ],
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: UserProfile()));
}
