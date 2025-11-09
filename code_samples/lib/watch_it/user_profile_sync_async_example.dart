import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class UserProfile extends WatchingWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    // Synchronous data
    final userId = watchValue((SimpleUserManager m) => m.name);

    // Asynchronous data - fetch stats from API based on current userId
    final statsSnapshot = watchFuture(
      (ApiClient api) => api.get('/users/$userId/stats'),
      initialValue: null,
    );

    return Column(
      children: [
        Text('User: $userId'),
        if (statsSnapshot.data == null)
          CircularProgressIndicator()
        else if (statsSnapshot.hasError)
          Text('Error loading stats')
        else
          Text('Stats: ${statsSnapshot.data!['data']}'),
      ],
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: UserProfile()));
}
