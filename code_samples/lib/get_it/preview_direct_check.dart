import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

// Simple mock services for preview
class MockUserService {
  String get currentUser => 'John Doe';
}

class MockApiClient {
  Future<String> fetchData() async => 'Mock data';
}

// #region example
@Preview()
Widget userProfilePreview() {
  // The preview function may be called multiple times during hot reload,
  // so guard against double registration by checking the last service
  if (!getIt.isRegistered<MockApiClient>()) {
    getIt.registerSingleton<MockUserService>(MockUserService());
    getIt.registerLazySingleton<MockApiClient>(() => MockApiClient());
  }

  return const MaterialApp(
    home: Scaffold(
      body: UserProfileWidget(),
    ),
  );
}
// #endregion example

class UserProfileWidget extends StatelessWidget {
  const UserProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = getIt<MockUserService>();
    return Center(
      child: Text('User: ${userService.currentUser}'),
    );
  }
}

void main() {
  // Test code would go here
}
