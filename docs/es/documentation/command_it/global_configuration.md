# Configuración Global

Propiedades estáticas que configuran el comportamiento para todos los commands en tu app. Establécelas una vez, típicamente en la función `main()` de tu app antes de llamar `runApp()`.

## Resumen

| Propiedad | Tipo | Por Defecto | Propósito |
|-----------|------|-------------|-----------|
| [**globalExceptionHandler**](#globalexceptionhandler) | `Function?` | `null` | Handler de error global para todos los commands |
| [**globalErrors**](#globalerrors) | `Stream` | N/A | Stream observable de todos los errores enrutados globalmente |
| [**errorFilterDefault**](#errorfilterdefault) | `ErrorFilter` | `GlobalIfNoLocalErrorFilter()` | Filtro de error por defecto |
| [**assertionsAlwaysThrow**](#assertionsalwaysthrow) | `bool` | `true` | AssertionErrors bypasean filtros |
| [**reportAllExceptions**](#reportallexceptions) | `bool` | `false` | Sobrescribir filtros, reportar todos los errores |
| [**detailedStackTraces**](#detailedstacktraces) | `bool` | `true` | Stack traces mejorados |
| [**loggingHandler**](#logginghandler) | `Function?` | `null` | Handler para todas las ejecuciones de commands |
| [**reportErrorHandlerExceptionsToGlobalHandler**](#reporterrorhandlerexceptionstoglobalhandler) | `bool` | `true` | Reportar excepciones de handlers de error |
| [**useChainCapture**](#usechaincapture) | `bool` | `false` | Trazas detalladas experimentales |

## Ejemplo de Setup Completo

Aquí hay un setup típico configurando múltiples propiedades globales:

<<< @/../code_samples/lib/command_it/global_config_main_example.dart#example

## globalExceptionHandler

Handler de error global llamado para todos los errores de commands:

```dart
static void Function(CommandError<dynamic> error, StackTrace stackTrace)?
  globalExceptionHandler;
```

Establécelo una vez en tu función `main()` para manejar errores globalmente:

```dart
void main() {
  Command.globalExceptionHandler = (error, stackTrace) {
    loggingService.logError(error.error, stackTrace);
    Sentry.captureException(error.error, stackTrace: stackTrace);
  };

  runApp(MyApp());
}
```

**Cuándo se llama:**
- Depende de la configuración de ErrorFilter (por defecto: cuando no existen listeners locales)
- Siempre se llama cuando `reportAllExceptions: true`

**Ver:** [Manejo de Errores (Error Handling) - Handler de Error Global](/es/documentation/command_it/error_handling#handler-de-error-global) para documentación completa incluyendo ejemplos de uso, detalles de contexto de error, y patrones.

## globalErrors

Stream observable de todos los errores de commands enrutados al handler global:

```dart
static Stream<CommandError<dynamic>> get globalErrors
```

Perfecto para monitoreo de errores reactivo, analytics, crash reporting, y notificaciones de UI globales:

```dart
// Ejemplo: Toast de error global en widget raíz
class MyApp extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    registerStreamHandler<Stream<CommandError>, CommandError>(
      target: Command.globalErrors,
      handler: (context, snapshot, cancel) {
        if (snapshot.hasData) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${snapshot.data!.error}')),
          );
        }
      },
    );
    return MaterialApp(home: HomePage());
  }
}
```

**Puntos clave:**
- Stream de broadcast (múltiples listeners soportados)
- Emite cuando ErrorFilter enruta errores a handler global
- NO emite para `reportAllExceptions` solo de debug
- Usa con `globalExceptionHandler` para manejo de errores comprehensivo

**Ver:** [Manejo de Errores (Error Handling) - Stream de Errores Globales](/es/documentation/command_it/error_handling#stream-de-errores-globales) para documentación completa incluyendo casos de uso, comportamiento del stream, y patrones de integración.

## errorFilterDefault

ErrorFilter por defecto usado cuando no se especifica filtro individual por command:

```dart
static ErrorFilter errorFilterDefault = const GlobalIfNoLocalErrorFilter();
```

**Por defecto:** `GlobalIfNoLocalErrorFilter()` - Enrutamiento inteligente que intenta handlers locales primero, fallback a global

**Ver:** [Manejo de Errores (Error Handling) - Configuración Global de Errores](/es/documentation/command_it/error_handling#configuracion-global-de-errores) para detalles completos sobre filtros incorporados, filtros personalizados, y configuración.

## assertionsAlwaysThrow

AssertionErrors bypasean ErrorFilters y siempre se relanzan:

```dart
static bool assertionsAlwaysThrow = true;
```

**Por defecto:** `true` (recomendado) - AssertionErrors indican errores de programación y deberían crashear inmediatamente durante desarrollo

**Ver:** [Manejo de Errores (Error Handling) - Configuración Global de Errores](/es/documentation/command_it/error_handling#assertionsalwaysthrow) para detalles completos.

## reportAllExceptions

Asegura que cada error llame a globalExceptionHandler, sin importar la configuración de ErrorFilter:

```dart
static bool reportAllExceptions = false;
```

**Por defecto:** `false`

**Patrón común:**
```dart
// En main.dart
Command.reportAllExceptions = kDebugMode;
```

**Cuándo usar:** Debugging de manejo de errores, modo desarrollo, verificar crash reporting

**Ver:** [Manejo de Errores (Error Handling) - Configuración Global de Errores](/es/documentation/command_it/error_handling#reportallexceptions) para detalles completos sobre cómo funciona, flujo de ejecución, y evitar llamadas duplicadas.

## detailedStackTraces

Limpia stack traces filtrando ruido de framework:

```dart
static bool detailedStackTraces = true;
```

**Por defecto:** `true` (recomendado)

**Qué hace:** Usa el paquete `stack_trace` para filtrar y simplificar stack traces, removiendo frames relacionados con Zone e internos de framework

**Rendimiento:** Overhead mínimo. Solo deshabilita si profiling muestra que es un cuello de botella (raro)

**Ver:** [Manejo de Errores (Error Handling) - Configuración Global de Errores](/es/documentation/command_it/error_handling#detailedstacktraces) para detalles completos sobre qué se filtra y ejemplos.

## loggingHandler

Handler llamado para cada ejecución de command (running, éxito, error):

```dart
static void Function(CommandResult<dynamic, dynamic> result)? loggingHandler;
```

**Por defecto:** `null` (sin logging)

### Ejemplo de Integración de Analytics

<<< @/../code_samples/lib/command_it/global_config_logging_example.dart#example

### Qué Datos Están Disponibles

`CommandResult<TParam, TResult>` proporciona:
- `.isRunning` - Si el command se está ejecutando actualmente
- `.hasData` - Si el command tiene datos de resultado
- `.hasError` - Si el command falló
- `.error` - El objeto de error (si hay)
- `.data` - Los datos del resultado (si hay)
- `.paramData` - Parámetro pasado al command

### Casos de Uso

- **Analytics** - Trackear métricas de ejecución de commands
- **Monitoreo de rendimiento** - Medir tiempo de ejecución de commands
- **Debugging** - Log de toda la actividad de commands
- **Audit trails** - Registrar acciones de usuario

## reportErrorHandlerExceptionsToGlobalHandler

Si un handler de error local lanza una excepción, reportarla a globalExceptionHandler:

```dart
static bool reportErrorHandlerExceptionsToGlobalHandler = true;
```

**Por defecto:** `true` (recomendado)

**Qué hace:** Cuando los handlers de error lanzan, captura la excepción y la envía a `globalExceptionHandler` con el error original almacenado en `CommandError.originalError`

**Por qué importa:** Los handlers de error también pueden tener bugs. Esto previene que código de manejo de errores crashee tu app.

**Ver:** [Manejo de Errores (Error Handling) - Cuando los Handlers de Error Lanzan Excepciones](/es/documentation/command_it/error_handling#cuando-los-handlers-de-error-lanzan-excepciones) y [Configuración Global de Errores](/es/documentation/command_it/error_handling#reporterrorhandlerexceptionstoglobalhandler) para detalles completos y ejemplos.

## useChainCapture

**Experimental:** Preservar stack traces a través de límites async para mostrar dónde se llamaron los commands:

```dart
static bool useChainCapture = false;
```

**Por defecto:** `false`

**Qué hace:**

Cuando está habilitado, preserva el call stack desde donde se invocó el command, incluso cuando la excepción ocurre dentro de una función async. Sin esto, a menudo obtienes un "async gap" - perdiendo el contexto del stack trace que muestra qué código llamó al command.

Usa el mecanismo `Chain.capture()` de Dart para mantener el stack trace completo a través de límites async.

**Ejemplo sin useChainCapture:**
```
#0  ApiClient.fetch (api_client.dart:42)
#1  <async gap>
```

**Ejemplo con useChainCapture:**
```
#0  ApiClient.fetch (api_client.dart:42)
#1  _fetchDataCommand.run (data_manager.dart:156)
#2  DataScreen.build.<anonymous> (data_screen.dart:89)
#3  ... (cadena de llamadas completa preservada)
```

**Estado:** Característica experimental que puede cambiar o ser removida en versiones futuras.

**No recomendado para uso en producción** - puede tener implicaciones de rendimiento.

## Patrones de Configuración Comunes

### Modo Desarrollo

Para máxima visibilidad durante desarrollo:

<<< @/../code_samples/lib/command_it/global_config_development.dart#example

**Características:**
- Reportar TODOS los errores (bypasear filtros)
- Logging verbose para cada command
- Stack traces detallados
- Contexto de error comprehensivo

### Modo Producción

Para producción con integración de crash reporting:

<<< @/../code_samples/lib/command_it/global_config_production.dart#example

**Características:**
- Respetar filtros de error (no reportar todo)
- Enviar errores a servicio de crash reporting
- Stack traces detallados para debugging de problemas de producción
- Sin logging verbose (mantener producción ligera)

### Modo Testing

Para tests unitarios/de integración:

```dart
void setupTestMode() {
  // Deshabilitar todos los handlers para evitar efectos secundarios en tests
  Command.globalExceptionHandler = null;
  Command.loggingHandler = null;

  // Dejar que errores lancen naturalmente para assertions de tests
  Command.reportAllExceptions = false;
  Command.errorFilterDefault = const ErrorHandlerNone();
}
```

## Interacciones de Propiedades

### reportAllExceptions Sobrescribe Filtros de Error

Cuando `reportAllExceptions: true`:
```dart
Command.reportAllExceptions = true;
Command.errorFilterDefault = const LocalErrorFilter(); // ← ¡Ignorado!
```

Cada error aún va a `globalExceptionHandler`, sin importar la configuración del filtro.

### assertionsAlwaysThrow Bypasea Todo

```dart
Command.assertionsAlwaysThrow = true; // Por defecto
Command.errorFilterDefault = const ErrorHandlerNone(); // ← ¡Ignorado para assertions!
```

AssertionErrors siempre se relanzan, incluso si los filtros los silenciarían.

### Reportando Excepciones de Handlers de Error

```dart
Command.reportErrorHandlerExceptionsToGlobalHandler = true;
Command.globalExceptionHandler = (error, stackTrace) {
  // Recibe ambos:
  // 1. Errores normales de commands
  // 2. Excepciones lanzadas por handlers de error locales

  if (error.originalError != null) {
    // Este error vino de un handler de error con bugs
    print('Handler de error lanzó: ${error.error}');
    print('Error original era: ${error.originalError}');
  }
};
```

## Errores Comunes

### ❌️ Olvidar kDebugMode para reportAllExceptions

```dart
// MAL: Siempre reportar todas las excepciones, incluso en producción
Command.reportAllExceptions = true;
```

**Problema:** La app en producción envía cada error a crash reporting, creando ruido.

**Solución:**
```dart
// ✅ Solo en modo debug
Command.reportAllExceptions = kDebugMode;
```

### ❌️ No Acceder a Propiedades de CommandError

```dart
// MAL: Solo usando el objeto de error
Command.globalExceptionHandler = (commandError, stackTrace) {
  Sentry.captureException(commandError.error, stackTrace: stackTrace);
  // ¡Falta contexto valioso!
};
```

**Solución:**
```dart
// ✅ Usar contexto completo de CommandError con Sentry
Command.globalExceptionHandler = (commandError, stackTrace) {
  Sentry.captureException(
    commandError.error,
    stackTrace: stackTrace,
    withScope: (scope) {
      scope.setTag('command', commandError.command ?? 'unknown');
      scope.setContexts('command_context', {
        'parameter': commandError.paramData?.toString(),
        'error_reaction': commandError.errorReaction.toString(),
      });
    },
  );
};
```

### ❌️ Usar loggingHandler para Manejo de Errores

```dart
// MAL: Intentando manejar errores en logging handler
Command.loggingHandler = (result) {
  if (result.hasError) {
    showErrorDialog(result.error); // ¡No hagas esto!
  }
};
```

**Problema:** `loggingHandler` es para observabilidad, no manejo de errores.

**Solución:**
```dart
// ✅ Usa globalExceptionHandler para manejo de errores
Command.globalExceptionHandler = (error, stackTrace) {
  // Maneja errores aquí
};

// ✅ Usa loggingHandler solo para métricas/analytics
Command.loggingHandler = (result) {
  analytics.logEvent('command_executed', parameters: {
    'has_error': result.hasError,
  });
};
```

### ❌️ Deshabilitar detailedStackTraces Prematuramente

```dart
// MAL: Deshabilitando sin medir
Command.detailedStackTraces = false; // "Por rendimiento"
```

**Problema:** El procesamiento de stack trace tiene overhead negligible. Deshabilitarlo hace el debugging más difícil.

**Solución:**
```dart
// ✅ Solo deshabilitar si profiling muestra que es un cuello de botella
Command.detailedStackTraces = true; // Mantener el por defecto
```

## Ver También

- **[Manejo de Errores (Error Handling)](/es/documentation/command_it/error_handling)** — Aprende cómo `errorFilterDefault` y `globalExceptionHandler` funcionan con filtros de error, incluyendo creación de filtros personalizados
- **[Propiedades del Command](/es/documentation/command_it/command_properties)** — Propiedades de nivel de instancia que pueden sobrescribir valores globales por defecto (como filtros de error por command)
- **[Fundamentos de Command](/es/documentation/command_it/command_basics)** — Empieza aquí si eres nuevo en command_it - aprende cómo crear y ejecutar commands antes de configurar globales
- **[Resolución de Problemas](/es/documentation/command_it/troubleshooting)** — Problemas comunes y soluciones, incluyendo problemas de configuración
