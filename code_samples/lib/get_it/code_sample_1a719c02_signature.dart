// ignore_for_file: missing_function_body, unused_element
getIt.registerCachedFactoryParam<ImageProcessor, int, int>(
  (width, height) => ImageProcessor(width, height),
);

// Creates new instance
final processor1 = getIt<ImageProcessor>(param1: 1920, param2: 1080);

// Reuses same instance (same parameters)
final processor2 = getIt<ImageProcessor>(param1: 1920, param2: 1080);

// Creates NEW instance (different parameters)
final processor3 = getIt<ImageProcessor>(param1: 3840, param2: 2160);