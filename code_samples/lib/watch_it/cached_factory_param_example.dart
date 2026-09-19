import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart' hide di;
import '_shared/stubs.dart';

// #region manager
/// One manager per station - created on demand, kept while in use.
class StationManager {
  StationManager(this.stationId);

  final String stationId;
  final name = ValueNotifier<String>('');

  Future<void> load() async {
    // fetch station details...
    name.value = 'Station $stationId';
  }
}

void registerStationManager() {
  di.registerCachedFactoryParam<StationManager, String, void>(
    (stationId, _) => StationManager(stationId)..load(),
  );
}
// #endregion manager

// #region with_create_once
class StationTileCreateOnce extends WatchingWidget {
  const StationTileCreateOnce({super.key, required this.stationId});

  final String stationId;

  @override
  Widget build(BuildContext context) {
    // Manager lives and dies with this widget instance
    final manager = createOnce(() => StationManager(stationId)..load());
    final name = watch(manager.name).value;
    return Text(name);
  }
}
// #endregion with_create_once

// #region with_cached_factory
class StationTileCachedFactory extends WatchingWidget {
  const StationTileCachedFactory({super.key, required this.stationId});

  final String stationId;

  @override
  Widget build(BuildContext context) {
    // Manager is resolved from get_it with the parameter; if stationId
    // changes, watch_it switches to the new instance automatically
    final name = watchValue(
      (StationManager m) => m.name,
      param1: stationId,
    );
    return Text(name);
  }
}
// #endregion with_cached_factory

void main() {
  registerStationManager();
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            StationTileCreateOnce(stationId: 'A1'),
            StationTileCachedFactory(stationId: 'A1'),
          ],
        ),
      ),
    ),
  );
}
