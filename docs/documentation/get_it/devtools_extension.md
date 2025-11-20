---
title: DevTools Extension
prev:
  text: 'Testing'
  link: '/documentation/get_it/testing'
next:
  text: 'Flutter Previews'
  link: '/documentation/get_it/flutter_previews'
---

<div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 2rem;">
  <img src="/images/get_it.svg" alt="get_it logo" width="100" />
  <h1 style="margin: 0;">DevTools Extension</h1>
</div>

**get_it** includes a DevTools extension that lets you visualize and inspect all registered objects in your running Flutter app in real-time.

<strong>Key features:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>View all registrations</strong> - See every object registered in get_it across all scopes</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Inspect instance state</strong> - View the toString() output of created instances</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Track registration details</strong> - Type, scope, mode, async status, ready state, creation status</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Real-time updates</strong> - Automatically refreshes when registrations change (with debug events enabled)</li>
</ul>

---

## Setup

### 1. Enable Debug Events

In your app's `main.dart`, enable debug events before running your app:

```dart
void main() {
  GetIt.instance.debugEventsEnabled = true;

  // ... configure your dependencies
  configureDependencies();

  runApp(MyApp());
}
```

::: tip Why Enable Debug Events?
When `debugEventsEnabled` is `true`, get_it sends events to DevTools whenever registrations change, allowing the extension to automatically update. Without this, you'll need to manually refresh the extension to see changes.
:::

::: warning Debug Mode Only
The DevTools extension only works in debug mode. In release builds, the extension is not available and debug events have no effect.
:::

### 2. Run Your App in Debug Mode

```bash
flutter run
```

### 3. Open DevTools in Browser

The get_it extension currently **only works in the browser-based DevTools**, not in IDE-embedded DevTools.

When you run your app, Flutter will display a message like:

```
The Flutter DevTools debugger and profiler is available at: http://127.0.0.1:9100
```

Open that URL in your browser.

### 4. Enable the Extension

1. In DevTools, click the **Extensions** button (puzzle piece icon) in the top right corner
2. Find the `get_it` extension in the list and enable it
3. The "get_it" tab will appear in the main DevTools navigation

### 5. Open the get_it Tab

Click on the "get_it" tab to view all your registrations.

---

## Understanding the Registration Table

The DevTools extension displays all registered objects in a table with the following columns:

![get_it DevTools Extension](/images/get_it_devtools_extension.png)
*The get_it DevTools extension showing all registered objects in a running app*

| Column | Description |
|--------|-------------|
| **Type** | The registered type (class name) |
| **Instance Name** | The instance name if using named registrations, otherwise empty |
| **Scope** | The scope this registration belongs to (e.g., `baseScope` for the default scope) |
| **Mode** | The registration type: `constant` (singleton), `lazy` (lazy singleton), `alwaysNew` (factory), or `cachedFactory` |
| **Async** | Whether this is an async registration (`true` for `registerSingletonAsync` and `registerLazySingletonAsync`) |
| **Ready** | For async registrations, whether the initialization is complete |
| **Created** | Whether the instance has been created (false for lazy registrations that haven't been accessed yet) |
| **Instance Details** | The `toString()` output of the instance (if created) |

---

## Making Instance Details Meaningful

By default, Dart's `toString()` only shows the type name and instance ID (e.g., `Instance of 'UserRepository'`). To see meaningful details in the DevTools extension, **override `toString()` in your registered classes**:

```dart
class UserRepository {
  final String userId;
  final bool isAuthenticated;

  UserRepository(this.userId, this.isAuthenticated);

  @override
  String toString() {
    return 'UserRepository(userId: $userId, isAuthenticated: $isAuthenticated)';
  }
}
```

Now in DevTools, you'll see:
```
UserRepository(userId: user123, isAuthenticated: true)
```

### Tips for Good toString() Implementations

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Include key state</strong> - Show the most important properties that help you understand the object's current state</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Keep it concise</strong> - Long strings are hard to read in the table. Stick to the essential information</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Use descriptive names</strong> - Make it obvious what each value represents</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Include enum states</strong> - If your object has states or modes, include them</li>
</ul>

**Example for a media player:**

```dart
class PlayerManager {
  bool isPlaying;
  String? currentTrack;
  Duration position;
  Duration duration;

  @override
  String toString() {
    final posStr = '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}';
    final durStr = '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

    return 'PlayerManager('
        'playing: $isPlaying, '
        'track: ${currentTrack ?? 'none'}, '
        'position: $posStr/$durStr'
        ')';
  }
}
```

This shows: `PlayerManager(playing: true, track: My Song, position: 2:34/4:15)`

---

## Refreshing the View

- **With debug events enabled**: The view automatically updates when registrations change
- **Without debug events**: Click the **Refresh** button in the extension to manually update the view
- **Manual refresh**: You can always click Refresh to ensure you're seeing the latest state

---

## Troubleshooting

### The get_it tab doesn't appear

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">➜ Make sure you're using <strong>browser-based DevTools</strong>, not IDE-embedded DevTools</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">➜ Verify the extension is <strong>enabled</strong> in the Extensions menu (puzzle piece icon)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">➜ Ensure your app is running in <strong>debug mode</strong></li>
</ul>

### The extension shows no registrations

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">➜ Make sure you've actually <strong>registered objects</strong> in your app</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">➜ Click the <strong>Refresh button</strong> to manually update the view</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">➜ Verify you're looking at the correct <strong>DevTools instance</strong> for your running app</li>
</ul>

### The extension doesn't auto-update

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">➜ Check that <code>debugEventsEnabled = true</code> is set <strong>before</strong> any registrations</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">➜ Use the manual <strong>Refresh button</strong> if auto-updates aren't working</li>
</ul>

---

## Use Cases

### During Development

- **Verify registrations** - Ensure all required services are registered at startup
- **Debug initialization** - Check which async singletons are ready
- **Inspect state** - View the current state of your services and models
- **Understand scopes** - See which objects belong to which scope

### During Testing

- **Verify test setup** - Ensure mocks are registered correctly
- **Debug flaky tests** - Check if objects are being created multiple times
- **Scope isolation** - Verify that test scopes are working as expected

### During Debugging

- **Track down bugs** - Inspect service state when bugs occur
- **Verify lifecycle** - Check if lazy singletons are created when expected
- **Monitor changes** - Watch how registrations change as you navigate your app

---

## Learn More

- [Testing with get_it](/documentation/get_it/testing) - Learn how to test your get_it registrations
- [Scopes](/documentation/get_it/scopes) - Understand how scopes work
- [Async Objects](/documentation/get_it/async_objects) - Learn about async initialization
- [Official Flutter DevTools Documentation](https://docs.flutter.dev/tools/devtools/extensions)
