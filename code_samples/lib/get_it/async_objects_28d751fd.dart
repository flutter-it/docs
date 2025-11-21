// ignore_for_file: unused_element
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() async {
  // #region example
  // Register first batch of services
  getIt.registerSingletonAsync<ConfigService>(() async => ConfigService.load());
  getIt.registerSingletonAsync<Logger>(() async => Logger.initialize());

  // Wait for first batch
  await getIt.allReady();
  print('Core services ready');

  // Register second batch based on config
  final config = getIt<ConfigService>();
  if (config.enableFeatureX) {
    getIt.registerSingletonAsync<FeatureX>(() async => FeatureX.initialize());
  }

  // Wait for second batch
  await getIt.allReady();
  print('All services ready');

  runApp(MyApp());
  // #endregion example
}
