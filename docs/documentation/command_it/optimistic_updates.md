# Optimistic Updates

Build responsive UIs that update instantly while background operations complete. command_it supports optimistic updates with two approaches: a simple error listener pattern for learning and straightforward cases, and `UndoableCommand` for automatic rollback in complex scenarios.

**Key Benefits:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">⚡ <strong>Instant UI updates</strong> - Update state immediately, sync in background</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">🔄 <strong>Graceful error recovery</strong> - Restore previous state when operations fail</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">🎯 <strong>Choose your approach</strong> - Simple manual pattern or automatic UndoableCommand</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">📚 <strong>Progressive complexity</strong> - Start simple, upgrade when needed</li>
</ul>

## Why Optimistic Updates?

Traditional synchronous updates feel slow:

```dart
// ❌ Traditional: User waits for server response
Future<void> toggleBookmark(String postId, bool isBookmarked) async {
  // UI shows loading spinner...
  await api.updateBookmark(postId, !isBookmarked); // User waits 500ms
  // Finally update UI
  bookmarkedPosts.value = !isBookmarked;
}
```

Optimistic updates feel instant:

```dart
// ✅ Optimistic: UI updates immediately
Future<void> toggleBookmark(String postId, bool isBookmarked) async {
  // Save current state in case we need to rollback
  final previousState = isBookmarked;

  // Update UI immediately - feels instant!
  bookmarkedPosts.value = !isBookmarked;

  try {
    // Sync to server in background
    await api.updateBookmark(postId, !isBookmarked);
  } catch (e) {
    // Rollback on failure
    bookmarkedPosts.value = previousState;
    showSnackBar('Failed to update bookmark');
  }
}
```

## Simple Approach with Error Listeners

Before diving into `UndoableCommand`, let's understand the fundamental pattern. This approach gives you full control and helps you understand what's happening under the hood.

### Basic Toggle Pattern

The key insight: when an error occurs, **invert the current value** to restore the previous state, don't just reload from the server.

This example shows a `Post` model with an embedded bookmark command:

<<< @/../code_samples/lib/command_it/optimistic_simple_toggle_example.dart#example

**Why invert instead of reload?**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ No server round-trip needed</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Preserves other concurrent changes</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Instant rollback</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Requires knowing the inverse operation</li>
</ul>

### Delete Pattern

For deletions, capture the item before removing it. This example uses [`MapNotifier`](/documentation/listen_it/reactive_collections#mapnotifier) to store todos by ID:

<<< @/../code_samples/lib/command_it/optimistic_simple_delete_example.dart#example

::: tip Passing the Object
Notice the command accepts `Todo` as a parameter, not just the ID. This allows the error handler to access the deleted todo via `error.paramData` for restoration. If you only pass an ID, you'll need to capture the object in a field before deletion (like the `_lastDeleted` pattern) - in which case `UndoableCommand` would be a better approach.
:::

### When to Use Simple Approach

**Good for:**
- Learning optimistic updates
- Simple toggles (bookmarks, likes, archived)
- Simple deletions
- When you want explicit control
- Prototyping and understanding the pattern

**Limitations:**
- Manual error handling for each command
- Need to track previous values for complex state
- More code duplication across commands
- Easy to forget error handling

## Advanced: Auto-Rollback with UndoableCommand

For complex state or multiple operations, `UndoableCommand` automates the pattern above. It captures state before execution and restores it automatically on failure - no manual error handling needed.

Automatic state restoration on failure is enabled by default:

<<< @/../code_samples/lib/command_it/optimistic_undoable_delete_example.dart#example

**Execution Flow:**

1. **During execution**: Your function runs and calls `stack.push()` to save state snapshots
2. **On success**: State snapshots remain on the undo stack for potential manual undo
3. **On failure** (automatic by default):
   - The `undo` handler is called automatically with `(stack, reason)`
   - Your undo handler calls `stack.pop()` to restore the previous state
   - Error is still propagated to error handlers

### UndoableCommand Patterns

#### Pattern 1: Toggle State with Immutable Objects

When working with immutable objects, the undo stack automatically preserves the previous state:

<<< @/../code_samples/lib/command_it/optimistic_undoable_toggle_example.dart#example

Since `Todo` is immutable, pushing it to the stack captures a complete snapshot. No need to manually clone - immutability guarantees the saved state won't change.

#### Pattern 2: Multi-Step Operations

For operations with multiple steps where any failure should rollback everything:

<<< @/../code_samples/lib/command_it/optimistic_multistep_example.dart#example

## Manual Undo

`UndoableCommand` supports manual undo operations by calling the `undo()` method directly. Disable automatic rollback when you want to control undo manually:

<<< @/../code_samples/lib/command_it/optimistic_manual_undo_example.dart#example

::: tip Manual Undo Only
UndoableCommand currently only supports undo, not redo. The `undo()` method pops the last state from the undo stack and restores it. For redo functionality, you would need to implement your own redo stack.
:::

## Choosing an Approach

Both approaches have their place - choose based on your needs and preferences, not dogma.

### Use Simple Error Listeners When:

- **Learning**: You want to understand optimistic updates from first principles
- **Simple operations**: Single toggles or deletes where the inverse is obvious
- **Explicit control**: You prefer seeing exactly what happens on error
- **Prototyping**: Quick experiments before committing to a pattern
- **Edge cases**: Specific rollback logic that doesn't fit the standard pattern

### Use UndoableCommand When:

- **Complex state**: Multiple fields change together and must roll back atomically
- **Consistency**: You want the same rollback pattern across all commands
- **Less boilerplate**: Tired of writing error listeners for every command
- **Team projects**: Standardize on automatic rollback to prevent forgotten error handling
- **Multi-step operations**: Complex workflows where any step can fail

::: tip Pragmatic Approach
There's no "right" answer - both patterns are valid. Start with the simple approach to understand the mechanics, then upgrade to `UndoableCommand` when the manual pattern becomes tedious. You can even mix approaches in the same app: use simple listeners for straightforward toggles and `UndoableCommand` for complex operations.

For deeper context on avoiding dogmatic programming advice, see Thomas Burkhart's article: [Understanding the Problems with Dogmatic Programming Advice](https://blog.burkharts.net/understanding-the-problems-with-dogmatic-programming-advice)
:::

## When to Use Optimistic Updates

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

<<< @/../code_samples/lib/command_it/optimistic_error_handling_example.dart#example

The error is still propagated to error handlers, so you can show appropriate feedback to the user.

## See Also

- [Command Types - Undoable Commands](/documentation/command_it/command_types#undoable-commands) - All factory methods and API details
- [Best Practices - Undoable Commands](/documentation/command_it/best_practices#pattern-5-undoable-commands-with-automatic-rollback) - More patterns and recommendations
- [Error Handling](/documentation/command_it/error_handling) - How errors work with automatic rollback
- [Keeping Widgets in Sync with Your Data](https://blog.burkharts.net/keeping-widgets-in-sync-with-your-data) - Original blog post demonstrating both simple and UndoableCommand patterns
