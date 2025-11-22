import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:watch_it/watch_it.dart';
import '_shared/stubs.dart';

class WeatherManager {
  final api = ApiClient();
  bool shouldFail = false;

  late final loadWeatherCommand =
      Command.createAsync<String, List<WeatherEntry>>(
    (city) async {
      await simulateDelay(1500);
      if (shouldFail) {
        throw ApiException('Failed to load weather for $city');
      }
      return [
        WeatherEntry(city, 'Sunny', 75),
        WeatherEntry('$city North', 'Cloudy', 68),
        WeatherEntry('$city South', 'Rainy', 62),
      ];
    },
    initialValue: [],
  );
}

final weatherManager = WeatherManager();

// #region example
class WeatherResultWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Watch the results property for all state
    final results = watchValue(
      (WeatherManager m) => m.loadWeatherCommand.results,
    );

    // Check execution state
    if (results.isRunning) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading weather for ${results.paramData ?? ""}...'),
          ],
        ),
      );
    }

    // Check for errors
    if (results.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text('Error: ${results.error}'),
            if (results.paramData != null)
              Text('For city: ${results.paramData}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => weatherManager.loadWeatherCommand('London'),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Check for data
    if (results.hasData && results.data!.isNotEmpty) {
      return ListView.builder(
        itemCount: results.data!.length,
        itemBuilder: (context, index) {
          final entry = results.data![index];
          return ListTile(
            title: Text(entry.city),
            subtitle: Text(entry.condition),
            trailing: Text('${entry.temperature}°F'),
          );
        },
      );
    }

    // Initial state
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => weatherManager.loadWeatherCommand('London'),
            child: Text('Load Weather'),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              weatherManager.shouldFail = true;
              weatherManager.loadWeatherCommand('Paris');
            },
            child: Text('Load Weather (will fail)'),
          ),
        ],
      ),
    );
  }
}
// #endregion example

void main() {
  GetIt.instance.registerSingleton<WeatherManager>(weatherManager);
  runApp(MaterialApp(home: Scaffold(body: WeatherResultWidget())));
}
