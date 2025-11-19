import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class CreateTodoWithHandlerWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final titleController = createOnce(() => TextEditingController());
    final descController = createOnce(() => TextEditingController());

    // Use registerHandler to handle successful command completion
    // This is perfect for navigation, showing success messages, etc.
    registerHandler(
      select: (TodoManager m) => m.createTodoCommand,
      handler: (context, result, _) {
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Created: ${result!.title}'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back with result
        Navigator.of(context).pop(result);
      },
    );

    final isCreating =
        watchValue((TodoManager m) => m.createTodoCommand.isRunning);

    return Scaffold(
      appBar: AppBar(title: const Text('Command Handler - Success')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'This example uses registerHandler to navigate on success',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCreating
                    ? null
                    : () {
                        final params = CreateTodoParams(
                          title: titleController.text,
                          description: descController.text,
                        );
                        di<TodoManager>().createTodoCommand.run(params);
                      },
                child: isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Todo'),
              ),
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
    home: CreateTodoWithHandlerWidget(),
  ));
}
