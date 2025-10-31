// ignore_for_file: missing_function_body, unused_element
// resetScope - clears all registrations in current scope but keeps scope
await getIt.resetScope(dispose: true);

// popScope - removes entire scope and restores previous
await getIt.popScope();