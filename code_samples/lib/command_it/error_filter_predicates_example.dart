import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

// #region example
class DataService {
  final api = ApiClient();
  int requestCount = 0;

  // Command with ErrorFilter for different error types
  late final loadDataCommand = Command.createAsyncNoParam<List<Todo>>(
    () async {
      await simulateDelay();
      requestCount++;

      // Simulate different error scenarios
      if (requestCount == 1) {
        throw ValidationException('Invalid request');
      } else if (requestCount == 2) {
        throw ApiException('Network timeout', 408);
      } else if (requestCount == 3) {
        throw Exception('Unknown error');
      }

      return fakeTodos;
    },
    initialValue: [],
    errorFilter: PredicatesErrorFilter([
      // Validation errors: handled locally (show to user)
      (error, stackTrace) {
        if (error is ValidationException) {
          return ErrorReaction.localHandler;
        }
        return null;
      },
      // API errors with retry-able status: local handler
      (error, stackTrace) {
        if (error is ApiException && error.statusCode == 408) {
          return ErrorReaction.localHandler;
        }
        return null;
      },
      // Other API errors: send to global handler (logging)
      (error, stackTrace) {
        if (error is ApiException) {
          return ErrorReaction.globalHandler;
        }
        return null;
      },
      // Unknown errors: both local and global
      (error, stackTrace) => ErrorReaction.localAndGlobalHandler,
    ]),
  );
}

class ErrorFilterWidget extends StatefulWidget {
  const ErrorFilterWidget({super.key});

  @override
  State<ErrorFilterWidget> createState() => _ErrorFilterWidgetState();
}

class _ErrorFilterWidgetState extends State<ErrorFilterWidget> {
  final service = DataService();
  String? lastError;

  @override
  void initState() {
    super.initState();

    // Set up global error handler
    Command.globalExceptionHandler = (error, stackTrace) {
      debugPrint('Global handler caught: $error');
      // In real app: send to logging service
    };

    // Listen to local errors
    service.loadDataCommand.errors.listen((error, _) {
      setState(() {
        lastError = error?.error.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Error Filter Example',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          if (lastError != null)
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(child: Text(lastError!)),
                  ],
                ),
              ),
            ),
          SizedBox(height: 16),

          ElevatedButton(
            onPressed: service.loadDataCommand.run,
            child: Text('Load Data (attempt ${service.requestCount + 1})'),
          ),
          SizedBox(height: 8),

          Text(
            'Try loading multiple times to see different error types:\n'
            '1st: ValidationException (local)\n'
            '2nd: ApiException 408 (local)\n'
            '3rd: Exception (both handlers)\n'
            '4th: Success',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
// #endregion example

void main() {
  runApp(MaterialApp(home: Scaffold(body: ErrorFilterWidget())));
}
