// ignore_for_file: missing_function_body, unused_element
// Base scope lazy singletons
getIt.registerLazySingleton<GlobalCache>(() => GlobalCache());

// Push scope and register more
getIt.pushNewScope(scopeName: 'session');
getIt.registerLazySingleton<SessionCache>(() => SessionCache());
getIt.registerLazySingleton<UserState>(() => UserState());

// Access them
final globalCache = getIt<GlobalCache>();
final sessionCache = getIt<SessionCache>();

// Reset only current scope ('session')
await getIt.resetLazySingletons();
// GlobalCache NOT reset, SessionCache and UserState ARE reset

// Reset all scopes
await getIt.resetLazySingletons(inAllScopes: true);
// Both GlobalCache and SessionCache are reset

// Reset only specific scope
await getIt.resetLazySingletons(onlyInScope: 'baseScope');
// Only GlobalCache is reset