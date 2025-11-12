# Flutter Widget Previews

This guide shows you how to use `get_it` with Flutter's [widget previewer](https://docs.flutter.dev/tools/widget-previewer).

## The Challenge

When you use the `@Preview` annotation, Flutter renders your widget without calling `main()` or running your app's startup code. This means:

- `get_it` hasn't been initialized
- No services have been registered
- Widgets that call `GetIt.I<SomeService>()` will throw errors

You need to handle `get_it` initialization within the preview itself.

## Two Approaches

There are two ways to initialize `get_it` for previews, each with different trade-offs:

1. **Direct Registration** - Simple check and register pattern
2. **Wrapper Widget** - Reusable wrapper with automatic cleanup

Choose based on your needs:

| Approach | Best For | Pros | Cons |
|----------|----------|------|------|
| Direct Registration | Simple, one-off previews | Maximum control, minimal code | No automatic cleanup, manual guards |
| Wrapper Widget | Reusable setups, multiple previews | Automatic cleanup, DRY principle | Slightly more setup |

## Approach 1: Direct Registration

The simplest approach is to check if services are registered and register them if not.

### How It Works

Flutter may call your preview function multiple times (on hot reload, etc.), so you guard against double registration using `isRegistered()`:

<<< @/../code_samples/lib/get_it/preview_direct_check.dart#example

### When to Use

- **One-off previews** with unique dependencies
- **Quick prototyping** where you want immediate results
- **Maximum control** over initialization timing

### Pros & Cons

**Pros:**
- Minimal code, easy to understand
- Full control over registration order
- No additional widgets needed

**Cons:**
- Manual guard checks for every service
- No automatic cleanup (stays in `get_it` until manually reset)
- Code duplication if multiple previews need same setup

## Approach 2: Wrapper Widget

For better organization and reusability, create a wrapper widget that handles initialization and cleanup automatically.

### The Wrapper Widget

First, create a reusable wrapper widget:

<<< @/../code_samples/lib/get_it/preview_wrapper_class.dart#example

### Using the Wrapper

Use the wrapper with the `@Preview` annotation's `wrapper` parameter:

<<< @/../code_samples/lib/get_it/preview_wrapper_usage.dart#example

### When to Use

- **Multiple previews** that share the same dependencies
- **Reusable setups** across different widget previews
- **Automatic cleanup** via `reset()` on dispose
- **Cleaner code** with separation of concerns

### Pros & Cons

**Pros:**
- Automatic cleanup when preview is disposed
- Reusable across multiple previews
- Cleaner preview code (setup is separate)
- Easy to create multiple configurations

**Cons:**
- Requires separate wrapper widget definition
- Wrapper function must be top-level or static
- Slightly more initial setup

## Testing Different Scenarios

One powerful use of the wrapper approach is creating different scenarios for the same widget:

<<< @/../code_samples/lib/get_it/preview_custom_scenarios.dart#example

This pattern is excellent for:

- **Testing edge cases** (error states, empty data, loading)
- **Different user states** (logged in, logged out, guest)
- **Accessibility testing** (different font sizes, themes)
- **Responsive design** (different screen sizes with `size` parameter)

## Complete Example

See the [get_it example app](https://github.com/flutter-it/get_it/blob/master/example/lib/main.dart) for a complete working example showing both approaches.

The example includes:
- `preview()` - Direct registration approach
- `previewWithWrapper()` - Wrapper approach
- `GetItPreviewWrapper` implementation in [preview_wrapper.dart](https://github.com/flutter-it/get_it/blob/master/example/lib/preview_wrapper.dart)

## Tips & Best Practices

### Using Real vs Mock Services

One of the key benefits of `get_it` is that you can connect your widgets to **real services** in previews, allowing you to see your widgets with actual data and behavior. You just need to ensure proper initialization:

```dart
// Real services - perfectly valid if properly initialized
Widget realServicesWrapper(Widget child) {
  return GetItPreviewWrapper(
    init: (getIt) {
      getIt.registerSingleton<ApiClient>(ApiClient(baseUrl: 'https://api.example.com'));
      getIt.registerSingleton<AuthService>(AuthService());
      getIt.registerSingleton<DatabaseService>(DatabaseService());
    },
    child: child,
  );
}
```

However, **mock services are recommended** when you want:
- **Isolated testing** of specific UI states
- **Fast rendering** without network/database delays
- **Controlled scenarios** (error states, edge cases, empty data)

```dart
// Mock services - great for testing specific scenarios
getIt.registerSingleton<ApiClient>(MockApiClient()); // Instant responses
```

Choose based on your preview goals: real services for integration-style previews, mocks for isolated UI state testing.

### Async Initialization

Async initialization works normally in previews. The async factory functions are called only once, just like in your regular app. The key is to use `allReady()` or `isReady<T>()` in your widgets to wait for initialization:

```dart
Widget asyncPreviewWrapper(Widget child) {
  return GetItPreviewWrapper(
    init: (getIt) {
      // Async registrations work perfectly - factory called once
      getIt.registerSingletonAsync<ApiService>(
        () async => ApiService().initialize(),
      );
      getIt.registerSingletonAsync<DatabaseService>(
        () async => DatabaseService().connect(),
      );
    },
    child: child,
  );
}

// In your widget, wait for services to be ready
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt.allReady(), // Wait for all async singletons
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Services are ready, use them
          final api = getIt<ApiService>();
          return Text(api.data);
        }
        return CircularProgressIndicator(); // Show loading
      },
    );
  }
}
```

**Note:** The preview environment is web-based, so file I/O (`dart:io`) and native plugins won't work, but network calls and most async operations work fine.

### Create Reusable Wrappers

If you have common setups, create named wrappers:

```dart
// Define once
Widget basicAppWrapper(Widget child) => GetItPreviewWrapper(
  init: (getIt) {
    getIt.registerSingleton<ApiClient>(MockApiClient());
    getIt.registerSingleton<AuthService>(MockAuthService());
  },
  child: child,
);

// Reuse everywhere
@Preview(name: 'Widget 1', wrapper: basicAppWrapper)
Widget widget1Preview() => const Widget1();

@Preview(name: 'Widget 2', wrapper: basicAppWrapper)
Widget widget2Preview() => const Widget2();
```

### Combine with Other Preview Parameters

You can use `get_it` wrappers alongside other preview features:

```dart
@Preview(
  name: 'Responsive Dashboard',
  wrapper: myPreviewWrapper,
  size: Size(375, 812), // iPhone 11 Pro size
  textScaleFactor: 1.3,  // Accessibility testing
)
Widget dashboardPreview() => const DashboardWidget();
```

## Troubleshooting

### "`get_it`: Object/factory with type X is not registered"

Your preview function is being called before `get_it` is initialized. Use one of the two approaches above to register services before accessing them.

### Preview not updating on hot reload

The wrapper's `dispose()` might not be called. Try stopping and restarting the preview, or use the direct registration approach with `isRegistered()` checks.

### Services persisting between previews

If using direct registration without cleanup, services remain in `get_it`. Either:
- Use the wrapper approach (automatic `reset()` on dispose)
- Manually call `await GetIt.I.reset()` when needed
- Use separate named instances for different previews

## Learn More

- [Flutter Widget Previewer Documentation](https://docs.flutter.dev/tools/widget-previewer)
- [`get_it` Testing Guide](./testing.md) - Similar patterns for unit tests
- [`get_it` Scopes](./scopes.md) - For more advanced isolation needs

## Next Steps

- Try both approaches in your project
- Create reusable wrapper functions for common scenarios
- Explore combining previews with different themes and sizes
- Check out the complete example in the get_it repository
