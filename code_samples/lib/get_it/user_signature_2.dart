// ignore_for_file: missing_function_body, unused_element
// App startup - guest mode
getIt.registerSingleton<User>(GuestUser());
getIt.registerSingleton<Permissions>(GuestPermissions());

// User logs in
getIt.pushNewScope(scopeName: 'authenticated');
getIt.registerSingleton<User>(AuthenticatedUser(token));
getIt.registerSingleton<Permissions>(UserPermissions(user));

// User logs out - automatic cleanup
await getIt.popScope(); // GuestUser & GuestPermissions restored