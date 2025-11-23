import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import '_shared/stubs.dart';

// #region example
class DataService {
  final isAuthenticated = ValueNotifier<bool>(false);

  late final fetchDataCommand = Command.createAsync<String, List<String>>(
    (query) async {
      // Fetch data from API
      final api = getIt<ApiClient>();
      return await api.searchData(query);
    },
    initialValue: [], // initial value
    restriction:
        isAuthenticated.map((auth) => !auth), // disabled when not authenticated
    ifRestrictedRunInstead: (query) {
      // Called when command is restricted (not authenticated)
      // Show login prompt instead of executing
      debugPrint('Please log in to search for: $query');
      showLoginDialog();
    },
  );

  void showLoginDialog() {
    // In a real app, this would show a dialog
    debugPrint('Showing login dialog...');
  }
}
// #endregion example

void main() {
  setupDependencyInjection();

  final service = DataService();

  // Try to run command while not authenticated
  service.fetchDataCommand('flutter'); // Will call ifRestrictedRunInstead

  // Authenticate
  service.isAuthenticated.value = true;

  // Now the command will execute normally
  service.fetchDataCommand('flutter');
}
