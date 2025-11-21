import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:watch_it/watch_it.dart';
import '_shared/stubs.dart';

// #region example
class WeatherService {
  late final loadWeatherCommand = Command.createAsync<String, String>(
    (city) async {
      await simulateDelay(1000);
      return 'Weather in $city: Sunny, 72°F';
    },
    initialValue: 'No data loaded',
  );
}

// Register service with get_it (call this in main())
void setup() {
  GetIt.instance.registerSingleton(WeatherService());
}

// Use watch_it to observe commands without ValueListenableBuilder
class WeatherWidget extends WatchingWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the command value directly
    final weather = watchValue((WeatherService s) => s.loadWeatherCommand);

    // Watch the loading state
    final isLoading =
        watchValue((WeatherService s) => s.loadWeatherCommand.isRunning);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          CircularProgressIndicator()
        else
          Text(weather, style: TextStyle(fontSize: 18)),
        SizedBox(height: 16),
        // With parameters - call command directly (it's callable)
        ElevatedButton(
          onPressed: () =>
              GetIt.instance<WeatherService>().loadWeatherCommand('London'),
          child: Text('Load Weather'),
        ),
      ],
    );
  }
}
// #endregion example

void main() {
  setup();
  runApp(MaterialApp(home: Scaffold(body: Center(child: WeatherWidget()))));
}
