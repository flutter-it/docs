import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
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

// #region example
class WeatherResultWidget extends StatelessWidget {
  WeatherResultWidget({super.key});

  final manager = WeatherManager();

  @override
  Widget build(BuildContext context) {
    // Use results property for all data at once
    return ValueListenableBuilder<CommandResult<String?, List<WeatherEntry>>>(
      valueListenable: manager.loadWeatherCommand.results,
      builder: (context, result, _) {
        // Check execution state
        if (result.isRunning) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading weather for ${result.paramData ?? ""}...'),
              ],
            ),
          );
        }

        // Check for errors
        if (result.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 48),
                SizedBox(height: 16),
                Text('Error: ${result.error}'),
                if (result.paramData != null)
                  Text('For city: ${result.paramData}'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => manager.loadWeatherCommand('London'),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Check for data
        if (result.hasData && result.data!.isNotEmpty) {
          return ListView.builder(
            itemCount: result.data!.length,
            itemBuilder: (context, index) {
              final entry = result.data![index];
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
                onPressed: () => manager.loadWeatherCommand('London'),
                child: Text('Load Weather'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  manager.shouldFail = true;
                  manager.loadWeatherCommand('Paris');
                },
                child: Text('Load Weather (will fail)'),
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
  runApp(MaterialApp(home: Scaffold(body: WeatherResultWidget())));
}
