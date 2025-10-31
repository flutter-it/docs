import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
class UserProfilePage extends WatchingWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Automatically pushes scope when widget mounts
    // Automatically pops scope when widget disposes
    pushScope(init: (_) {
      getIt.registerSingleton<ProfileController>(
        ProfileController(userId: userId),
      );
    });

    final controller = watchIt<ProfileController>();

    return Scaffold(
      body: Text(controller.userData.name),
    );
  }
}
// #endregion example
