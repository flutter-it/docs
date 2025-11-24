import 'package:command_it/command_it.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

// Stub for example
class Item {
  final String id;
  final String name;
  Item(this.id, this.name);
}

class ApiClient {
  Future<List<Item>> search(String query) async {
    await Future.delayed(Duration(milliseconds: 100));
    return [Item('1', 'Result for $query')];
  }
}

// #region example
/// Real service with actual command
class DataService {
  late final loadCommand = Command.createAsync<String, List<Item>>(
    (query) => getIt<ApiClient>().search(query),
    initialValue: [],
  );
}

/// Mock service for testing - overrides command with MockCommand
class MockDataService implements DataService {
  @override
  late final loadCommand = MockCommand<String, List<Item>>(
    initialValue: [],
  );

  // Control methods make tests readable and maintainable
  void queueSuccess(String query, List<Item> data) {
    (loadCommand as MockCommand<String, List<Item>>)
        .queueResultsForNextRunCall([
      CommandResult<String, List<Item>>(query, data, null, false),
    ]);
  }

  void simulateError(String message) {
    (loadCommand as MockCommand).endRunWithError(message);
  }
}

// Code that depends on DataService
class DataManager {
  DataManager() {
    // Listen to service command and update local state
    getIt<DataService>().loadCommand.isRunning.listen((running, _) {
      _isLoading = running;
    });

    getIt<DataService>().loadCommand.listen((data, _) {
      _currentData = data;
    });
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Item> _currentData = [];
  List<Item> get currentData => _currentData;

  Future<void> loadData(String query) async {
    getIt<DataService>().loadCommand(query);
  }
}

void main() {
  group('MockCommand Pattern', () {
    test('Test manager with mock service - success state', () async {
      final mockService = MockDataService();
      getIt.registerSingleton<DataService>(mockService);

      final manager = DataManager();

      final testData = [Item('1', 'Test Item')];

      // Queue result for the next execution
      mockService.queueSuccess('test', testData);

      // Execute the command through the manager
      await manager.loadData('test');

      // Wait for listener to fire
      await Future.delayed(Duration.zero);

      // Verify success state
      expect(manager.isLoading, false);
      expect(manager.currentData, testData);

      // Cleanup
      await getIt.reset();
    });

    test('Test manager with mock service - error state', () async {
      final mockService = MockDataService();
      getIt.registerSingleton<DataService>(mockService);

      final manager = DataManager();

      CommandError? capturedError;
      mockService.loadCommand.errors.listen((error, _) {
        capturedError = error;
      });

      // Simulate error without using loadData
      mockService.simulateError('Network error');

      // Wait for listener to fire
      await Future.delayed(Duration.zero);

      // Verify error state
      expect(manager.isLoading, false);
      expect(capturedError?.error.toString(), contains('Network error'));

      // Cleanup
      await getIt.reset();
    });

    test('Real service works as expected', () async {
      // Register real dependencies
      getIt.registerSingleton<ApiClient>(ApiClient());
      getIt.registerSingleton<DataService>(DataService());

      final manager = DataManager();

      // Test with real service
      await manager.loadData('flutter');

      await Future.delayed(Duration(milliseconds: 150));

      expect(manager.currentData.isNotEmpty, true);
      expect(manager.currentData.first.name, contains('flutter'));

      // Cleanup
      await getIt.reset();
    });
  });
}
// #endregion example
