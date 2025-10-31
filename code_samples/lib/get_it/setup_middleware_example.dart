import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
abstract class RequestMiddleware {
  Future<bool> handle(Request request);
}

class AuthMiddleware implements RequestMiddleware {
  @override
  Future<bool> handle(Request request) async => true;
}

class RateLimitMiddleware implements RequestMiddleware {
  @override
  Future<bool> handle(Request request) async => true;
}

class LoggingMiddleware implements RequestMiddleware {
  @override
  Future<bool> handle(Request request) async => true;
}

class ApiClient {
  Future<Response> send(Request request) async {
    // Execute all middleware in registration order
    final middlewares = getIt.getAll<RequestMiddleware>();
    print('middlewares: $middlewares');
    for (final middleware in middlewares) {
      final canProceed = await middleware.handle(request);
      if (!canProceed) {
        return Response.forbidden();
      }
    }

    return _executeRequest(request);
  }

  Future<Response> _executeRequest(Request request) async {
    return Response(200, '');
  }
}

// #endregion example

void main() {
  // #region example
  getIt.enableRegisteringMultipleInstancesOfOneType();

  // Order matters! First registered = first executed
  getIt.registerSingleton<RequestMiddleware>(AuthMiddleware());
  getIt.registerSingleton<RequestMiddleware>(RateLimitMiddleware());
  getIt.registerSingleton<RequestMiddleware>(LoggingMiddleware());
  // #endregion example
}
