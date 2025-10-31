import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
class UserProfilePage extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Automatically pushes scope when widget mounts
    // Automatically pops scope when widget disposes
    pushScope(init: (getIt) {

void main() {
  const userId = "user123";
        getIt.registerSingleton<ProfileController>(
          ProfileController(userId: widget.userId),
        );
      });

      final controller = watchIt<ProfileController>();

      return Scaffold(
        body: Text(controller.userData.name),
      );
    }
  }
}
// #endregion example