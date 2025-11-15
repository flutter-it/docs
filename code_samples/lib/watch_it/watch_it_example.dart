import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class WeatherDisplay extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // watchValue watches a specific ValueListenable from a get_it registered object
    // This is more efficient than watching the entire manager
    final weather = watchValue((WeatherManager m) => m.weather);
    final location = watchValue((WeatherManager m) => m.location);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Location: $location',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (weather != null) ...[
          Text('Temperature: ${weather.temperature}°C'),
          Text('Condition: ${weather.condition}'),
        ] else
          const Text('No weather data'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => di<WeatherManager>().fetchWeatherCommand.run(),
          child: const Text('Refresh Weather'),
        ),
      ],
    );
  }
}
// #endregion example

void main() {
  setupDependencyInjection();

  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: WeatherDisplay(),
      ),
    ),
  ));
}
