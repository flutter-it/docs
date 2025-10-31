// ignore_for_file: missing_function_body, unused_element
// Access services
final api = getIt<ApiClient>();
final db = getIt<Database>();
final auth = getIt<AuthService>();

// Use them
await api.fetchData();
await db.save(data);
final user = await auth.login('alice', 'secret');