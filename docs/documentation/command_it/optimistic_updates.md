# Optimistic Updates

Build responsive UIs that update instantly while background operations complete. `UndoableCommand` provides automatic rollback when operations fail, giving you optimistic updates without complex error recovery code.

**Key Features:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">⚡ <strong>Instant UI updates</strong> - Update state immediately, sync in background</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">🔄 <strong>Automatic rollback</strong> - Failed operations restore previous state automatically</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">🎯 <strong>No manual error recovery</strong> - No try/catch blocks, no state restoration code</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">📚 <strong>Undo/Redo support</strong> - Built-in undo stack for manual undo operations</li>
</ul>

## Auto-Rollback on Failure

The `undoOnExecutionFailure` parameter enables automatic state restoration when operations fail:

```dart
class TodoService {
  final todos = ValueNotifier<List<Todo>>([]);

  late final deleteTodoCommand = Command.createUndoableNoResult<String, List<Todo>>(
    (id, previousTodos) async {
      // Make optimistic update
      todos.value = todos.value.where((t) => t.id != id).toList();

      // Try to delete on server
      await api.deleteTodo(id);
      // If this throws an exception, the undo handler is called automatically
    },
    undo: (id) {
      // Capture state snapshot before execution
      return todos.value;
    },
    undoOnExecutionFailure: true, // Automatically rollback on error
  );
}
```

**Execution Flow:**

1. **Before execution**: The `undo` handler is called to capture the current state
2. **During execution**: Your function runs (e.g., optimistic UI update + API call)
3. **On success**: State snapshot is pushed to the undo stack
4. **On failure** (when `undoOnExecutionFailure: true`):
   - The command automatically calls the undo handler
   - State is restored to the pre-execution snapshot
   - Error is still propagated to error handlers

## Why Optimistic Updates?

Traditional synchronous updates feel slow:

```dart
// ❌ Traditional: User waits for server response
Future<void> deleteTodo(String id) async {
  // UI shows loading spinner...
  await api.deleteTodo(id); // User waits 500ms
  // Finally update UI
  todos.value = todos.value.where((t) => t.id != id).toList();
}
```

Optimistic updates feel instant:

```dart
// ✅ Optimistic: UI updates immediately
late final deleteTodo = Command.createUndoableNoResult<String, List<Todo>>(
  (id, _) async {
    todos.value = todos.value.where((t) => t.id != id).toList(); // Instant!
    await api.deleteTodo(id); // Happens in background
    // If this fails, state automatically rolls back
  },
  undo: (_) => todos.value,
  undoOnExecutionFailure: true,
);
```

## Common Patterns

### Pattern 1: Toggle State

```dart
class TodoService {
  final todos = ValueNotifier<List<Todo>>([]);

  late final toggleCompleteCommand = Command.createUndoable<String, void, List<Todo>>(
    (id, previousTodos) async {
      // Optimistic toggle
      todos.value = todos.value.map((todo) {
        if (todo.id == id) {
          return todo.copyWith(completed: !todo.completed);
        }
        return todo;
      }).toList();

      // Sync to server
      await api.toggleTodo(id);
    },
    undo: (id) => todos.value,
    undoOnExecutionFailure: true,
  );
}
```

### Pattern 2: Edit Data

```dart
class UserProfileService {
  final profile = ValueNotifier<UserProfile>(UserProfile.empty());

  late final updateNameCommand = Command.createUndoable<String, void, UserProfile>(
    (newName, previousProfile) async {
      // Optimistic update
      profile.value = profile.value.copyWith(name: newName);

      // Sync to server
      await api.updateUserName(newName);
    },
    undo: (newName) => profile.value,
    undoOnExecutionFailure: true,
  );
}
```

### Pattern 3: Multi-Step Operations

For operations with multiple steps where any failure should rollback everything:

```dart
class CheckoutService {
  final cart = ValueNotifier<Cart>(Cart.empty());
  final order = ValueNotifier<Order?>(null);

  late final checkoutCommand = Command.createUndoableNoResult<void, CheckoutState>(
    (_, previousState) async {
      // Step 1: Reserve inventory
      final reservation = await api.reserveInventory(cart.value.items);

      // Step 2: Process payment
      final payment = await api.processPayment(cart.value.total);

      // Step 3: Create order
      final newOrder = await api.createOrder(reservation, payment);

      // Update state
      order.value = newOrder;
      cart.value = Cart.empty();

      // If any step fails, all state automatically rolls back
    },
    undo: (_) => CheckoutState(cart.value, order.value),
    undoOnExecutionFailure: true,
  );
}
```

## Manual Undo/Redo

`UndoableCommand` also supports manual undo operations for user-initiated undo:

```dart
class TextEditorService {
  final content = ValueNotifier<String>('');

  late final editCommand = Command.createUndoable<String, void, String>(
    (newText, previousText) async {
      content.value = newText;
      await api.saveContent(newText);
    },
    undo: (newText) => content.value,
    // Note: undoOnExecutionFailure defaults to false for manual undo
  );

  void undo() {
    if (editCommand.canUndo) {
      final previousState = editCommand.undoStack.pop();
      content.value = previousState;
    }
  }

  void redo() {
    if (editCommand.canRedo) {
      final nextState = editCommand.redoStack.pop();
      content.value = nextState;
    }
  }
}
```

## Benefits

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Better UX</strong> - Instant feedback, no loading spinners for simple operations</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Cleaner code</strong> - No manual try/catch or state restoration logic</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Consistent error recovery</strong> - Automatic rollback works the same everywhere</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Offline-ready</strong> - Works with error handling to defer operations or rollback</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Testable</strong> - Test both success and failure paths easily</li>
</ul>

## When to Use

**Good candidates for optimistic updates:**

- Toggle operations (complete task, like item, follow user)
- Delete operations (remove item, clear notification)
- Simple edits (rename, update single field)
- State changes (mark as read, archive item)

**Not recommended for:**

- Operations where failure is common (validation errors)
- Complex forms with multiple validation steps
- Operations where the server determines the outcome (approval workflows)
- Financial transactions requiring confirmation

## Error Handling

Automatic rollback works with command_it's error handling system:

```dart
late final deleteCommand = Command.createUndoableNoResult<String, List<Todo>>(
  (id, _) async {
    // Optimistic delete
    todos.value = todos.value.where((t) => t.id != id).toList();

    await api.deleteTodo(id);
    // If this throws, state is automatically restored
  },
  undo: (_) => todos.value,
  undoOnExecutionFailure: true,
)..errors.listen((error, _) {
    if (error != null) {
      // State already rolled back automatically
      // Just show error message
      showSnackBar('Failed to delete: ${error.error}');
    }
  });
```

The error is still propagated to error handlers, so you can show appropriate feedback to the user.

## Testing

Test both success and failure paths:

```dart
test('delete todo - success path', () async {
  final service = TodoService();
  service.todos.value = [Todo(id: '1', title: 'Test')];

  await service.deleteTodoCommand.runAsync('1');

  expect(service.todos.value, isEmpty);
  expect(service.deleteTodoCommand.undoStack, hasLength(1));
});

test('delete todo - failure rolls back', () async {
  final service = TodoService();
  final originalTodos = [Todo(id: '1', title: 'Test')];
  service.todos.value = originalTodos;

  // Mock API to throw error
  when(() => api.deleteTodo('1')).thenThrow(Exception('Network error'));

  await expectLater(
    service.deleteTodoCommand.runAsync('1'),
    throwsException,
  );

  // State automatically rolled back
  expect(service.todos.value, equals(originalTodos));
});
```

## See Also

- [Command Types - Undoable Commands](/documentation/command_it/command_types#undoable-commands) - All factory methods and API details
- [Best Practices - Undoable Commands](/documentation/command_it/best_practices#pattern-5-undoable-commands-with-automatic-rollback) - More patterns and recommendations
- [Error Handling](/documentation/command_it/error_handling) - How errors work with automatic rollback
