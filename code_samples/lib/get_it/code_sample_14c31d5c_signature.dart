// ignore_for_file: missing_function_body, unused_element
// Reset everything and call disposal functions
await getIt.reset();

// Reset without calling disposals
await getIt.reset(dispose: false);