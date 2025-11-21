import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:watch_it/watch_it.dart';
import '_shared/stubs.dart';

class WeatherManager {
  late final loadWeatherCommand =
      Command.createAsync<String, List<WeatherEntry>>(
    (city) async {
      await simulateDelay(2000);
      return [WeatherEntry(city, 'Sunny', 72)];
    },
    initialValue: [],
  );
}

final weatherManager = WeatherManager();

// #region example
class WeatherWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final isRunning =
        watchValue((WeatherManager m) => m.loadWeatherCommand.isRunning);
    final weather = watchValue((WeatherManager m) => m.loadWeatherCommand);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isRunning)
          CircularProgressIndicator()
        else
          ElevatedButton(
            onPressed: () => weatherManager.loadWeatherCommand('London'),
            child: Text('Load Weather'),
          ),
        if (weather.isNotEmpty)
          Text('${weather.first.city}: ${weather.first.condition}'),
      ],
    );
  }
}
// #endregion example

void main() {
  GetIt.instance.registerSingleton<WeatherManager>(weatherManager);
  runApp(MaterialApp(home: Scaffold(body: WeatherWidget())));
}
