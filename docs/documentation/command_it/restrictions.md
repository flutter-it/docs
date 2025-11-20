# Command Restrictions

Control when commands can execute using reactive conditions. Restrictions integrate with `canRun` to automatically disable commands based on application state.

## Overview

Commands can be conditionally enabled or disabled using the `restriction` parameter. When a restriction is active (evaluates to `true`), the command cannot run.

**Key concept:** `restriction: true` = command is **disabled**

```dart
Command.createAsyncNoParam<List<Todo>>(
  () => api.fetchTodos(),
  initialValue: [],
  restriction: isLoggedIn.map((logged) => !logged), // disabled when NOT logged in
);
```

**Formula:** `canRun = !isRunning && !restriction`

## Basic Restriction with ValueNotifier

The most common pattern is restricting based on application state:

<<< @/../code_samples/lib/command_it/restriction_example.dart#example

**How it works:**
1. Create a `ValueNotifier<bool>` to track state (`isLoggedIn`)
2. Map it to restriction logic: `!logged` means "restrict when NOT logged in"
3. Command automatically updates `canRun` property
4. UI disables buttons when `canRun` is false

**Important:** The restriction parameter expects `ValueListenable<bool>` where `true` means "disabled".

## Chaining Commands via isRunningSync

Prevent commands from running while other commands execute:

<<< @/../code_samples/lib/command_it/restriction_chaining_example.dart#example

**How it works:**
1. `saveCommand` uses `loadCommand.isRunningSync` as restriction
2. While loading, `saveCommand` cannot run
3. `updateCommand` uses `saveCommand.isRunningSync`
4. Creates a dependency chain: load → save → update

**Why isRunningSync?**
- `isRunning` updates asynchronously (via microtask)
- `isRunningSync` updates immediately
- Prevents race conditions in restrictions
- Use `isRunning` for UI, `isRunningSync` for restrictions

## canRun Property

`canRun` automatically combines running state and restrictions:

```dart
ValueListenableBuilder<bool>(
  valueListenable: command.canRun,
  builder: (context, canRun, _) {
    return ElevatedButton(
      onPressed: canRun ? command.run : null,
      child: Text('Execute'),
    );
  },
)
```

**canRun is true when:**
- Command is NOT running (`!isRunning`)
- AND restriction is false (`!restriction`)

This is more convenient than manually checking both conditions.

## Restriction Patterns

### Authentication-Based Restriction

```dart
final isAuthenticated = ValueNotifier<bool>(false);

late final dataCommand = Command.createAsyncNoParam<Data>(
  () => api.fetchSecureData(),
  initialValue: Data.empty(),
  restriction: isAuthenticated.map((auth) => !auth), // disabled when not authenticated
);
```

### Validation-Based Restriction

```dart
final formValid = ValueNotifier<bool>(false);

late final submitCommand = Command.createAsync<FormData, void>(
  (data) => api.submit(data),
  restriction: formValid.map((valid) => !valid), // disabled when invalid
);
```

### Multiple Conditions

Use `ValueListenable` operators to combine restrictions:

```dart
final isOnline = ValueNotifier<bool>(true);
final hasPermission = ValueNotifier<bool>(false);

late final syncCommand = Command.createAsyncNoParam<void>(
  () => api.sync(),
  // Disabled when offline OR no permission
  restriction: isOnline.combineLatest(
    hasPermission,
    (online, permission) => !online || !permission,
  ),
);
```

## Temporary Restrictions

Restrict commands during specific operations:

```dart
class DataManager {
  final isSyncing = ValueNotifier<bool>(false);

  late final deleteCommand = Command.createAsync<String, void>(
    (id) => api.delete(id),
    // Can't delete while syncing
    restriction: isSyncing,
  );

  Future<void> sync() async {
    isSyncing.value = true;
    try {
      await api.syncAll();
    } finally {
      isSyncing.value = false;
    }
  }
}
```

## Restriction vs Manual Checks

**❌️️ Without restrictions (manual checks):**

```dart
void handleSave() {
  if (!isLoggedIn.value) return; // Manual check
  if (command.isRunning.value) return; // Manual check
  command.run();
}
```

**✅ With restrictions (automatic):**

```dart
late final command = Command.createAsync<Data, void>(
  (data) => api.save(data),
  restriction: isLoggedIn.map((logged) => !logged),
);

// UI automatically disables when restricted
ValueListenableBuilder<bool>(
  valueListenable: command.canRun,
  builder: (context, canRun, _) {
    return ElevatedButton(
      onPressed: canRun ? () => command(data) : null,
      child: Text('Save'),
    );
  },
)
```

**Benefits:**
- UI automatically reflects state
- No manual checks needed
- Centralized logic
- Reactive to state changes

## Restrictions vs Error Handling

**Restrictions prevent execution** — the command never runs.
**Error handling deals with failures** — the command runs but throws.

```dart
// Restriction: prevent execution when offline
restriction: isOnline.map((online) => !online)

// Error handling: handle failures when network fails during execution
errorFilter: PredicatesErrorFilter({
  NetworkException: (error, _) => showRetryDialog(error),
})
```

Use restrictions for **known conditions** (auth, validation, state).
Use error handling for **runtime failures** (network, API errors).

## Common Mistakes

### ❌️️ Inverting the restriction logic

```dart
// WRONG: restriction expects true = disabled
restriction: isLoggedIn, // disabled when logged in (backwards!)
```

```dart
// CORRECT: negate the condition
restriction: isLoggedIn.map((logged) => !logged), // disabled when NOT logged in
```

### ❌️️ Using isRunning for restrictions

```dart
// WRONG: async update can cause race conditions
restriction: otherCommand.isRunning,
```

```dart
// CORRECT: use synchronous version
restriction: otherCommand.isRunningSync,
```

### ❌️️ Forgetting to dispose restriction sources

```dart
class Manager {
  final customRestriction = ValueNotifier<bool>(false);

  late final command = Command.createAsync<Data, void>(
    (data) => api.save(data),
    restriction: customRestriction,
  );

  void dispose() {
    command.dispose();
    customRestriction.dispose(); // Don't forget this!
  }
}
```

## See Also

- [Command Basics](/documentation/command_it/command_basics) — Creating and running commands
- [Command Properties](/documentation/command_it/command_properties) — canRun, isRunning, isRunningSync
- [Error Handling](/documentation/command_it/error_handling) — Handling runtime errors
- [listen_it Operators](/documentation/listen_it/operators/overview) — ValueListenable operators
