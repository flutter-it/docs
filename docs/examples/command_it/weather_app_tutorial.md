# Building a Weather App with command_it

::: warning AI-Generated Content Under Review
This tutorial was generated with AI assistance and is currently under review. While we strive for accuracy, there may be errors or inconsistencies. Please report any issues you find.
:::

This tutorial walks you through building a complete weather app feature using command_it, demonstrating real-world patterns for async operations, loading states, error handling, and user input.

## What You'll Build

A weather search app that:
- Fetches weather data from an API
- Shows loading indicators during API calls
- Debounces search input to avoid excessive requests
- Allows enabling/disabling the search feature
- Handles errors gracefully
- Updates the UI reactively

## The Service Layer

First, create a `WeatherManager` service to handle weather data:

```dart
class WeatherManager {
  final ApiClient _api = ApiClient();

  // Command to update weather data
  late final updateWeatherCommand = Command.createAsync<String, List<WeatherEntry>>(
    _fetchWeather,
    [],
    restriction: setExecutionStateCommand,
  );

  // Command to handle search field changes
  late final textChangedCommand = Command.createSync<String, String>(
    (s) => s,
    '',
  );

  // Command to control whether updates are allowed
  late final setExecutionStateCommand = Command.createSync<bool, bool>(
    (b) => b,
    true,
  );

  WeatherManager() {
    // Debounce search input and trigger update
    textChangedCommand
        .debounce(Duration(milliseconds: 500))
        .listen((filterText, _) {
      updateWeatherCommand(filterText);
    });
  }

  Future<List<WeatherEntry>> _fetchWeather(String city) async {
    final response = await _api.getWeather(city);
    return response.entries;
  }
}
```

**Key patterns:**
- **Async command** for API calls (`updateWeatherCommand`)
- **Sync command** for UI events (`textChangedCommand`)
- **Sync command** for feature toggles (`setExecutionStateCommand`)
- **Debouncing** with listen_it to avoid excessive API calls
- **Restriction** to enable/disable the feature

## Displaying the Weather List

Use watch_it to reactively display the weather data:

```dart
class WeatherListView extends WatchingWidget {
  const WeatherListView({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherData = watchValue(
      (WeatherManager m) => m.updateWeatherCommand,
    );

    return ListView.builder(
      itemCount: weatherData.length,
      itemBuilder: (context, index) {
        final entry = weatherData[index];
        return ListTile(
          title: Text(entry.city),
          subtitle: Text(entry.condition),
          trailing: Text('${entry.temperature}°C'),
        );
      },
    );
  }
}
```

**What's happening:**
- `watchValue` observes the command's result
- Widget rebuilds automatically when new data arrives
- No manual state management needed

## Showing Loading State

Display a loading indicator while the API call is in progress:

```dart
class WeatherPage extends WatchingWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isRunning = watchValue(
      (WeatherManager m) => m.updateWeatherCommand.isRunning,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Weather')),
      body: Column(
        children: [
          SearchField(),
          EnableSwitch(),
          Expanded(
            child: isRunning
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading weather data...'),
                      ],
                    ),
                  )
                : WeatherListView(),
          ),
        ],
      ),
    );
  }
}
```

**Key points:**
- Watch `isRunning` separately from the data
- Show loading UI when `isRunning == true`
- Show results when `isRunning == false`
- Automatic, reactive updates

## Debouncing User Input

Handle search field input with debouncing:

```dart
class SearchField extends WatchingWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Search city',
          border: OutlineInputBorder(),
        ),
        onChanged: GetIt.instance<WeatherManager>().textChangedCommand,
      ),
    );
  }
}
```

**How it works:**
1. User types in the TextField
2. `onChanged` triggers `textChangedCommand`
3. Command value updates
4. Debounced listener waits 500ms
5. If no new input, triggers `updateWeatherCommand`
6. API call executes with the debounced search term

This prevents API calls on every keystroke!

## Controlling Command Execution

Add a switch to enable/disable weather updates:

```dart
class EnableSwitch extends WatchingWidget {
  const EnableSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final isEnabled = watchValue(
      (WeatherManager m) => m.setExecutionStateCommand,
    );

    return SwitchListTile(
      title: Text('Enable weather updates'),
      value: isEnabled,
      onChanged: GetIt.instance<WeatherManager>().setExecutionStateCommand,
    );
  }
}
```

**Restriction in action:**
- When switch is ON (`true`): `updateWeatherCommand` can execute
- When switch is OFF (`false`): `updateWeatherCommand` is restricted
- The restriction is passed when creating the command: `restriction: setExecutionStateCommand`
- **Note**: The restriction logic is inverted in the command setup

## Disabling the Update Button

Use `canRun` to control button state:

```dart
class UpdateButton extends WatchingWidget {
  const UpdateButton({super.key});

  @override
  Widget build(BuildContext context) {
    final canRun = watchValue(
      (WeatherManager m) => m.updateWeatherCommand.canRun,
    );

    final searchText = watchValue(
      (WeatherManager m) => m.textChangedCommand,
    );

    return ElevatedButton(
      onPressed: canRun
          ? () => GetIt.instance<WeatherManager>().updateWeatherCommand(searchText)
          : null,
      child: Text('Update'),
    );
  }
}
```

**`canRun` combines:**
- `!isRunning` - Button disabled while command executes
- `!restriction` - Button disabled when feature is turned off
- Automatically updates as state changes

## Complete Setup

Register the service with get_it:

```dart
void main() {
  // Setup dependency injection
  GetIt.instance.registerSingleton(WeatherManager());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WeatherPage(),
    );
  }
}
```

## Error Handling

Handle errors by watching the `errors` property:

```dart
class WeatherPageWithErrors extends WatchingWidget {
  const WeatherPageWithErrors({super.key});

  @override
  Widget build(BuildContext context) {
    final error = watchValue(
      (WeatherManager m) => m.updateWeatherCommand.errors,
    );

    final isRunning = watchValue(
      (WeatherManager m) => m.updateWeatherCommand.isRunning,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Weather')),
      body: Column(
        children: [
          if (error != null)
            Container(
              color: Colors.red[100],
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Error: ${error.error}',
                      style: TextStyle(color: Colors.red[900]),
                    ),
                  ),
                ],
              ),
            ),
          SearchField(),
          EnableSwitch(),
          Expanded(
            child: isRunning
                ? Center(child: CircularProgressIndicator())
                : WeatherListView(),
          ),
        ],
      ),
    );
  }
}
```

## What You Learned

This tutorial demonstrated:

✅ **Creating async commands** for API calls
✅ **Watching command state** (`isRunning`, `canRun`, `errors`)
✅ **Debouncing user input** with listen_it operators
✅ **Restricting command execution** based on app state
✅ **Reactive UI updates** with watch_it
✅ **Combining multiple commands** for complex workflows
✅ **Error handling** with command errors property

## Next Steps

- Add [error filters](/documentation/command_it/error_handling.md#error-filters) to route different error types
- Use [CommandResult](/documentation/command_it/command_results.md) for comprehensive state handling
- Explore [command chaining](/documentation/command_it/restrictions.md#chaining-commands-via-isrunningsync) for multi-step workflows
- Learn [testing patterns](/documentation/command_it/testing.md) for your commands

## See Also

- [Command Basics](/documentation/command_it/command_basics.md) - All command creation methods
- [Observing Commands with watch_it](/documentation/watch_it/observing_commands) - Advanced patterns
- [Restrictions](/documentation/command_it/restrictions.md) - Deep dive on command restrictions
- [Best Practices](/documentation/command_it/best_practices.md) - Production-ready patterns
