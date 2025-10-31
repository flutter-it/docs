// ignore_for_file: missing_function_body, unused_element
// Base scope
getIt.registerSingleton<User>(GuestUser());

// Push new scope
getIt.pushNewScope(scopeName: 'logged-in');
getIt.registerSingleton<User>(LoggedInUser());

getIt<User>(); // Returns LoggedInUser (shadows GuestUser)

// Pop scope
await getIt.popScope();

getIt<User>(); // Returns GuestUser (automatically restored)