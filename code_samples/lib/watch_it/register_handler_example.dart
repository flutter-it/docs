import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class TodoCreationPage extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final titleController = createOnce(() => TextEditingController());
    final descController = createOnce(() => TextEditingController());

    // registerHandler executes side effects when a ValueListenable changes
    // Unlike watch, it does NOT rebuild the widget
    // Perfect for navigation, showing toasts, logging, etc.
    registerHandler(
      select: (TodoManager m) => m.createTodoCommand,
      handler: (context, result, _) {
        if (result != null) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Created: ${result.title}')),
          );
          // Navigate back
          Navigator.of(context).pop(result);
        }
      },
    );

    // Handle errors separately
    registerHandler(
      select: (TodoManager m) => m.createTodoCommand.errors,
      handler: (context, error, _) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );

    // Watch loading state to disable button
    final isCreating =
        watchValue((TodoManager m) => m.createTodoCommand.isExecuting);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Todo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isCreating
                  ? null
                  : () {
                      final params = CreateTodoParams(
                        title: titleController.text,
                        description: descController.text,
                      );
                      di<TodoManager>().createTodoCommand.execute(params);
                    },
              child: isCreating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();

  runApp(MaterialApp(
    home: TodoCreationPage(),
  ));
}
