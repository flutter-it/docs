import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart';

class WeatherManager {
  final api = ApiClient();

  late final loadWeatherCommand = Command.createAsync<String, List<WeatherEntry>>(
    (city) async {
      await simulateDelay(2000);
      return [
        WeatherEntry(city, 'Sunny', 72),
        WeatherEntry('$city North', 'Cloudy', 65),
      ];
    },
    initialValue: [],
  );
}

// #region example
class WeatherWidget extends StatelessWidget {
  WeatherWidget({super.key});

  final manager = WeatherManager();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: manager.loadWeatherCommand.isRunning,
      builder: (context, isRunning, _) {
        // Show loading indicator while command runs
        if (isRunning) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading weather data...'),
              ],
            ),
          );
        }

        // Show data when ready
        return ValueListenableBuilder<List<WeatherEntry>>(
          valueListenable: manager.loadWeatherCommand,
          builder: (context, weather, _) {
            if (weather.isEmpty) {
              return Center(
                child: ElevatedButton(
                  onPressed: () => manager.loadWeatherCommand('London'),
                  child: Text('Load Weather'),
                ),
              );
            }

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
        );
      },
    );
  }
}
// #endregion example

void main() {
  runApp(MaterialApp(home: Scaffold(body: WeatherWidget())));
}
