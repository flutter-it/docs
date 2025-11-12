import 'package:flutter/material.dart';
import '_shared/stubs.dart';

// #region example
class UserActivity extends StatelessWidget {
  const UserActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: di<UserService>().activityStream,
      initialData: 'No activity',
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return Text('Activity: ${snapshot.data}');
      },
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();
  runApp(MaterialApp(home: UserActivity()));
}
