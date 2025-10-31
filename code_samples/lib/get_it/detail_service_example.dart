// ignore_for_file: unused_import, unused_local_variable, unused_element, prefer_collection_literals, use_key_in_widget_constructors, use_super_parameters, invalid_use_of_visible_for_testing_member, depend_on_referenced_packages
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '_shared/stubs.dart' hide ChangeNotifier;

final getIt = GetIt.instance;

// #region example
class DetailService extends ChangeNotifier {
  final String itemId;
  String? data;
  bool isLoading = false;

  DetailService(this.itemId) {
    // Trigger async loading in constructor (fire and forget)
    _loadData();
  }

  Future<void> _loadData() async {
    if (data != null) return; // Already loaded

    isLoading = true;
    notifyListeners();

    print('Loading data for $itemId from backend...');
    // Simulate backend call
    await Future.delayed(Duration(seconds: 1));
    data = 'Data for $itemId';

    isLoading = false;
    notifyListeners();
  }
}

class DetailPage extends WatchingWidget {
  final String itemId;
  const DetailPage(this.itemId);

  @override
  Widget build(BuildContext context) {
    // Register once when widget is created, dispose when widget is disposed
    callOnce(
      (context) {
        // Register or get existing - increments reference count
        getIt.registerSingletonIfAbsent<DetailService>(
          () => DetailService(itemId),
          instanceName: itemId,
        );
      },
      dispose: () {
        // Decrements reference count when widget disposes
        getIt.releaseInstance(getIt<DetailService>(instanceName: itemId));
      },
    );

    // Watch the service - rebuilds when notifyListeners() called
    final service = watchIt<DetailService>(instanceName: itemId);

    return Scaffold(
      appBar: AppBar(title: Text('Detail $itemId')),
      body: service.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Text(service.data ?? 'No data'),
                ElevatedButton(
                  onPressed: () {
                    // Can push same page recursively
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPage('related-$itemId'),
                      ),
                    );
                  },
                  child: const Text('View Related'),
                ),
              ],
            ),
    );
  }
}
// #endregion example
