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

class MockAuthService {
  bool get isAuthenticated => true;
}

// GetItPreviewWrapper definition (normally in a separate file)
class GetItPreviewWrapper extends StatefulWidget {
  const GetItPreviewWrapper({
    super.key,
    required this.init,
    required this.child,
  });

  final Widget child;
  final void Function(GetIt getIt) init;

  @override
  State<GetItPreviewWrapper> createState() => _GetItPreviewWrapperState();
}

class _GetItPreviewWrapperState extends State<GetItPreviewWrapper> {
  @override
  void initState() {
    super.initState();
    widget.init(GetIt.instance);
  }

  @override
  void dispose() {
    GetIt.instance.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// #region example
// Top-level wrapper function for @Preview annotation
Widget myPreviewWrapper(Widget child) {
  return GetItPreviewWrapper(
    init: (getIt) {
      // Register all preview dependencies here
      getIt.registerLazySingleton<MockApiClient>(() => MockApiClient());
      getIt.registerSingleton<MockUserService>(MockUserService());
      getIt.registerFactory<MockAuthService>(() => MockAuthService());
    },
    child: child,
  );
}

// Use the wrapper in your preview
@Preview(name: 'Dashboard Widget', wrapper: myPreviewWrapper)
Widget dashboardPreview() => const MaterialApp(
      home: Scaffold(
        body: DashboardWidget(),
      ),
    );
// #endregion example

class DashboardWidget extends StatelessWidget {
  const DashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = getIt<MockUserService>();
    return Center(
      child: Text('Dashboard for ${userService.currentUser}'),
    );
  }
}

void main() {
  // Test code would go here
}
