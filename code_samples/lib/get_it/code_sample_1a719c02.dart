import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

void main() {
  // #region example
  getIt.registerCachedFactoryParam<ImageProcessor, int, int>(
    (width, height) => ImageProcessor(width, height),
  );

  // Creates new instance
  final processor1 = getIt<ImageProcessor>(param1: 1920, param2: 1080);
  print('processor1: $processor1');

  // Reuses same instance (same parameters)
  final processor2 = getIt<ImageProcessor>(param1: 1920, param2: 1080);
  print('processor2: $processor2');

  // Creates NEW instance (different parameters)
  final processor3 = getIt<ImageProcessor>(param1: 3840, param2: 2160);
  print('processor3: $processor3');
  // #endregion example
}
