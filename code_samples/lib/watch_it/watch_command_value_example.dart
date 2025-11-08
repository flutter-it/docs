import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region example
class WeatherResultWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Get the command from the manager
    final manager = di<WeatherManager>();

    // Watch the command to get its result value
    final weather = watch(manager.fetchWeatherCommand).value;
    final isLoading = watch(manager.fetchWeatherCommand.isExecuting).value;

    callOnce((_) {
      di<WeatherManager>().fetchWeatherCommand.execute();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Watch Command - Result Value')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const CircularProgressIndicator()
            else if (weather != null) ...[
              Text(
                weather.location,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '${weather.temperature}°C',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                weather.condition,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ] else
              const Text('No weather data'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => di<WeatherManager>().fetchWeatherCommand.execute(),
              child: const Text('Refresh Weather'),
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
    home: WeatherResultWidget(),
  ));
}
