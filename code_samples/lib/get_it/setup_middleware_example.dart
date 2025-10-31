import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
void main() async {
abstract class RequestMiddleware {
  Future<bool> handle(Request request);
}

void setupMiddleware() {
  getIt.enableRegisteringMultipleInstancesOfOneType();

  // Order matters! First registered = first executed
  getIt.registerSingleton<RequestMiddleware>(AuthMiddleware());
  getIt.registerSingleton<RequestMiddleware>(RateLimitMiddleware());
  getIt.registerSingleton<RequestMiddleware>(LoggingMiddleware());
}

class ApiClient {
  Future<Response> send(Request request) async {
    // Execute all middleware in registration order
    final middlewares = getIt.getAll<RequestMiddleware>();
    for (final middleware in middlewares) {
      final canProceed = await middleware.handle(request);
      if (!canProceed) {
        return Response.forbidden();
      }
    }

    return _executeRequest(request);
  }
}
}
// #endregion example