import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

// Mock services with mutable state for different scenarios
class MockAuthService {
  bool isAuthenticated = false;
}

class MockUserService {
  String currentUser = '';
}

class MockApiClient {
  bool shouldFail = false;

  Future<String> fetchData() async {
    if (shouldFail) throw Exception('API Error');
    return 'Mock data';
  }
}

// GetItPreviewWrapper (normally in a separate file)
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
// Create different wrappers for different scenarios

// Logged in user scenario
Widget loggedInWrapper(Widget child) {
  return GetItPreviewWrapper(
    init: (getIt) {
      getIt.registerSingleton<MockAuthService>(
        MockAuthService()..isAuthenticated = true,
      );
      getIt.registerSingleton<MockUserService>(
        MockUserService()..currentUser = 'John Doe',
      );
    },
    child: child,
  );
}

// Logged out user scenario
Widget loggedOutWrapper(Widget child) {
  return GetItPreviewWrapper(
    init: (getIt) {
      getIt.registerSingleton<MockAuthService>(
        MockAuthService()..isAuthenticated = false,
      );
    },
    child: child,
  );
}

// Error state scenario
Widget errorStateWrapper(Widget child) {
  return GetItPreviewWrapper(
    init: (getIt) {
      getIt.registerSingleton<MockApiClient>(
        MockApiClient()..shouldFail = true,
      );
    },
    child: child,
  );
}

// Use different wrappers to preview different states
@Preview(name: 'Login Button - Logged In', wrapper: loggedInWrapper)
Widget loginButtonLoggedIn() => const LoginButtonWidget();

@Preview(name: 'Login Button - Logged Out', wrapper: loggedOutWrapper)
Widget loginButtonLoggedOut() => const LoginButtonWidget();

@Preview(name: 'Dashboard - Error State', wrapper: errorStateWrapper)
Widget dashboardError() => const DashboardWidget();
// #endregion example

class LoginButtonWidget extends StatelessWidget {
  const LoginButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = getIt<MockAuthService>();
    return ElevatedButton(
      onPressed: () {},
      child: Text(auth.isAuthenticated ? 'Logout' : 'Login'),
    );
  }
}

class DashboardWidget extends StatelessWidget {
  const DashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Dashboard'));
  }
}

void main() {
  // Test code would go here
}
