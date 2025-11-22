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
final di = GetIt.instance;

// #region example
class WeatherToWidgetExample extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final results = watchValue(
      (WeatherManager m) => m.loadWeatherCommand.results,
    );

    return results.toWidget(
      onData: (weather, param) {
        return ListView.builder(
          itemCount: weather.length,
          itemBuilder: (context, index) {
            final entry = weather[index];
            return ListTile(
              title: Text(entry.city),
              subtitle: Text(entry.condition),
              trailing: Text('${entry.temperature}°F'),
            );
          },
        );
      },
      whileRunning: (lastWeather, param) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading weather for ${param ?? ""}...'),
            ],
          ),
        );
      },
      onError: (error, lastWeather, param) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text('Error: $error'),
              if (param != null) Text('For city: $param'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => weatherManager.loadWeatherCommand('London'),
                child: Text('Retry'),
              ),
            ],
          ),
        );
      },
    );
  }
}
// #endregion example

void main() {
  GetIt.instance.registerSingleton<WeatherManager>(weatherManager);
  runApp(MaterialApp(home: Scaffold(body: WeatherToWidgetExample())));
}
