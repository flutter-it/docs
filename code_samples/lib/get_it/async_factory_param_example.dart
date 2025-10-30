import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

Future<String> fetchReportData(String userId, DateTime date) async {
  await Future.delayed(const Duration(milliseconds: 10));
  return 'Report data for $userId on $date';
}

// #region example
void configureDependencies() {
  // Async factory with parameters
  getIt.registerFactoryParamAsync<Report, String, DateTime>(
    (userId, date) async {
      final data = await fetchReportData(userId!, date!);
      return Report(data);
    },
  );
}

void main() async {
  // Usage
  final report = await getIt.getAsync<Report>(
    param1: 'user-123',
    param2: DateTime.now(),
  );
}
// #endregion example
