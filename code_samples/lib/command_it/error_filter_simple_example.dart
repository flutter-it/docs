import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

// #region example
class ApiService {
  final api = ApiClient();

  // Simple error filtering using errorFilter helper
  late final fetchCommand = Command.createAsyncNoParam<List<Todo>>(
    () async {
      await simulateDelay();
      throw ApiException('Server error', 500);
    },
    initialValue: [],
    errorFilter: PredicatesErrorFilter([
      // Network errors: show to user (local handler)
      (error, stackTrace) => errorFilter<ApiException>(
            error,
            ErrorReaction.localHandler,
          ),
      // Validation errors: show to user (local handler)
      (error, stackTrace) => errorFilter<ValidationException>(
            error,
            ErrorReaction.localHandler,
          ),
      // Other errors: log globally
      (error, stackTrace) => ErrorReaction.globalHandler,
    ]),
  );

  // Alternative: using TableErrorFilter (type equality only)
  late final saveCommand = Command.createAsyncNoResult<Todo>(
    (todo) async {
      await simulateDelay();
      throw ValidationException('Invalid todo');
    },
    errorFilter: TableErrorFilter({
      ApiException: ErrorReaction.localHandler,
      ValidationException: ErrorReaction.localHandler,
      Exception: ErrorReaction.globalHandler,
    }),
  );
}

class SimpleErrorFilterWidget extends StatelessWidget {
  SimpleErrorFilterWidget({super.key});

  final service = ApiService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Display errors from fetch command
          ValueListenableBuilder<CommandError?>(
            valueListenable: service.fetchCommand.errors,
            builder: (context, error, _) {
              if (error != null) {
                return Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Fetch error: ${error.error}'),
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
          SizedBox(height: 16),

          ElevatedButton(
            onPressed: service.fetchCommand.run,
            child: Text('Fetch Data (will fail)'),
          ),
          SizedBox(height: 8),

          ElevatedButton(
            onPressed: () => service.saveCommand(Todo('1', 'Test', false)),
            child: Text('Save Todo (will fail)'),
          ),
        ],
      ),
    );
  }
}
// #endregion example

void main() {
  runApp(MaterialApp(home: Scaffold(body: SimpleErrorFilterWidget())));
}
