import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '../listen_it/_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
class UserInfoWidget extends WatchingWidget {
  const UserInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // watch_it v2.0+ caches the selector, so the chain is created only once
    final userName = watchValue((Model m) =>
        m.user.select<String>((u) => u.name).map((name) => name.toUpperCase()));

    return Text('Hello, $userName!');
  }
}
// #endregion example

class Model {
  final ValueNotifier<User> user = ValueNotifier(User(name: 'John', age: 25));
}
