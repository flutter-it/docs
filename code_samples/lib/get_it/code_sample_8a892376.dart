import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() async {
  // #region example
  // Register with one parameter (second type is void)
  getIt.registerFactoryParam<ReportGenerator, String, void>(
    (reportType, _) => ReportGenerator(reportType),
  );

  // Access with one parameter
  final report = getIt<ReportGenerator>(param1: 'sales');
  // #endregion example
  print('report: $report');
}
