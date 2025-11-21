# Flutter Widget Previews

Esta guía te muestra cómo usar `get_it` con el [widget previewer de Flutter](https://docs.flutter.dev/tools/widget-previewer).

## El Desafío

Cuando usas la anotación `@Preview`, Flutter renderiza tu widget sin llamar a `main()` o ejecutar el código de inicio de tu app. Esto significa:

- `get_it` no ha sido inicializado
- No se han registrado servicios
- Los widgets que llaman a `GetIt.I<SomeService>()` lanzarán errores

Necesitas manejar la inicialización de `get_it` dentro del preview mismo.

## Dos Enfoques

Hay dos formas de inicializar `get_it` para previews, cada una con diferentes compromisos:

1. **Registro Directo** - Patrón simple de verificar y registrar
2. **Widget Wrapper** - Wrapper reutilizable con limpieza automática

Elige según tus necesidades:

| Enfoque | Mejor Para | Pros | Contras |
|----------|----------|------|------|
| Registro Directo | Previews simples, de una sola vez | Control máximo, código mínimo | Sin limpieza automática, guards manuales |
| Widget Wrapper | Configuraciones reutilizables, múltiples previews | Limpieza automática, principio DRY | Configuración ligeramente mayor |

## Enfoque 1: Registro Directo

El enfoque más simple es verificar si los servicios están registrados y registrarlos si no lo están.

### Cómo Funciona

Flutter puede llamar a tu función de preview múltiples veces (en hot reload, etc.), así que proteges contra registro doble usando `isRegistered()`:

<<< @/../code_samples/lib/get_it/preview_direct_check.dart#example

### Cuándo Usar

- **Previews de una sola vez** con dependencias únicas
- **Prototipado rápido** donde quieres resultados inmediatos
- **Control máximo** sobre el timing de inicialización

### Pros y Contras

**Pros:**
- Código mínimo, fácil de entender
- Control completo sobre el orden de registro
- No se necesitan widgets adicionales

**Contras:**
- Verificaciones de guard manuales para cada servicio
- Sin limpieza automática (permanece en `get_it` hasta reset manual)
- Duplicación de código si múltiples previews necesitan la misma configuración

## Enfoque 2: Widget Wrapper

Para mejor organización y reutilización, crea un widget wrapper que maneje inicialización y limpieza automáticamente.

### El Widget Wrapper

Primero, crea un widget wrapper reutilizable:

<<< @/../code_samples/lib/get_it/preview_wrapper_class.dart#example

### Usando el Wrapper

Usa el wrapper con el parámetro `wrapper` de la anotación `@Preview`:

<<< @/../code_samples/lib/get_it/preview_wrapper_usage.dart#example

### Cuándo Usar

- **Múltiples previews** que comparten las mismas dependencias
- **Configuraciones reutilizables** a través de diferentes previews de widgets
- **Limpieza automática** vía `reset()` en dispose
- **Código más limpio** con separación de responsabilidades

### Pros y Contras

**Pros:**
- Limpieza automática cuando el preview es dispuesto
- Reutilizable a través de múltiples previews
- Código de preview más limpio (la configuración está separada)
- Fácil de crear múltiples configuraciones

**Contras:**
- Requiere definición de widget wrapper separada
- La función wrapper debe ser de nivel superior o estática
- Configuración inicial ligeramente mayor

## Probando Diferentes Escenarios

Un uso poderoso del enfoque wrapper es crear diferentes escenarios para el mismo widget:

<<< @/../code_samples/lib/get_it/preview_custom_scenarios.dart#example

Este patrón es excelente para:

- **Probar casos extremos** (estados de error, datos vacíos, carga)
- **Diferentes estados de usuario** (loggeado, desloggeado, invitado)
- **Pruebas de accesibilidad** (diferentes tamaños de fuente, temas)
- **Diseño responsivo** (diferentes tamaños de pantalla con parámetro `size`)

## Ejemplo Completo

Mira la [app de ejemplo de get_it](https://github.com/flutter-it/get_it/blob/master/example/lib/main.dart) para un ejemplo completo funcionando mostrando ambos enfoques.

El ejemplo incluye:
- `preview()` - Enfoque de registro directo
- `previewWithWrapper()` - Enfoque wrapper
- Implementación de `GetItPreviewWrapper` en [preview_wrapper.dart](https://github.com/flutter-it/get_it/blob/master/example/lib/preview_wrapper.dart)

## Consejos y Mejores Prácticas

### Usando Servicios Reales vs Mock

Uno de los beneficios clave de `get_it` es que puedes conectar tus widgets a **servicios reales** en previews, permitiéndote ver tus widgets con datos y comportamiento reales. Solo necesitas asegurar inicialización apropiada:

```dart
// Servicios reales - perfectamente válido si se inicializa apropiadamente
Widget realServicesWrapper(Widget child) {
  return GetItPreviewWrapper(
    init: (getIt) {
      getIt.registerSingleton<ApiClient>(ApiClient(baseUrl: 'https://api.example.com'));
      getIt.registerSingleton<AuthService>(AuthService());
      getIt.registerSingleton<DatabaseService>(DatabaseService());
    },
    child: child,
  );
}
```

Sin embargo, **se recomiendan servicios mock** cuando quieres:
- **Pruebas aisladas** de estados específicos de UI
- **Renderizado rápido** sin retrasos de red/base de datos
- **Escenarios controlados** (estados de error, casos extremos, datos vacíos)

```dart
// Servicios mock - excelente para probar escenarios específicos
getIt.registerSingleton<ApiClient>(MockApiClient()); // Respuestas instantáneas
```

Elige según los objetivos de tu preview: servicios reales para previews estilo integración, mocks para pruebas aisladas de estado de UI.

### Inicialización Async

La inicialización async funciona normalmente en previews. Las funciones factory async se llaman solo una vez, igual que en tu app regular. La clave es usar `allReady()` o `isReady<T>()` en tus widgets para esperar la inicialización:

```dart
Widget asyncPreviewWrapper(Widget child) {
  return GetItPreviewWrapper(
    init: (getIt) {
      // Los registros async funcionan perfectamente - factory llamada una vez
      getIt.registerSingletonAsync<ApiService>(
        () async => ApiService().initialize(),
      );
      getIt.registerSingletonAsync<DatabaseService>(
        () async => DatabaseService().connect(),
      );
    },
    child: child,
  );
}

// En tu widget, espera a que los servicios estén listos
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt.allReady(), // Espera a que todos los async singletons estén listos
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Servicios están listos, úsalos
          final api = getIt<ApiService>();
          return Text(api.data);
        }
        return CircularProgressIndicator(); // Muestra carga
      },
    );
  }
}
```

**Nota:** El entorno de preview está basado en web, así que I/O de archivos (`dart:io`) y plugins nativos no funcionarán, pero llamadas de red y la mayoría de operaciones async funcionan bien.

### Crea Wrappers Reutilizables

Si tienes configuraciones comunes, crea wrappers con nombre:

```dart
// Define una vez
Widget basicAppWrapper(Widget child) => GetItPreviewWrapper(
  init: (getIt) {
    getIt.registerSingleton<ApiClient>(MockApiClient());
    getIt.registerSingleton<AuthService>(MockAuthService());
  },
  child: child,
);

// Reutiliza en todas partes
@Preview(name: 'Widget 1', wrapper: basicAppWrapper)
Widget widget1Preview() => const Widget1();

@Preview(name: 'Widget 2', wrapper: basicAppWrapper)
Widget widget2Preview() => const Widget2();
```

### Combina con Otros Parámetros de Preview

Puedes usar wrappers de `get_it` junto con otras características de preview:

```dart
@Preview(
  name: 'Responsive Dashboard',
  wrapper: myPreviewWrapper,
  size: Size(375, 812), // Tamaño de iPhone 11 Pro
  textScaleFactor: 1.3,  // Prueba de accesibilidad
)
Widget dashboardPreview() => const DashboardWidget();
```

## Solución de Problemas

### "`get_it`: Object/factory with type X is not registered"

Tu función de preview se está llamando antes de que `get_it` sea inicializado. Usa uno de los dos enfoques anteriores para registrar servicios antes de accederlos.

### Preview no se actualiza en hot reload

El `dispose()` del wrapper podría no estar siendo llamado. Intenta detener y reiniciar el preview, o usa el enfoque de registro directo con verificaciones `isRegistered()`.

### Servicios persistiendo entre previews

Si usas registro directo sin limpieza, los servicios permanecen en `get_it`. Ya sea:
- Usa el enfoque wrapper (automático `reset()` en dispose)
- Llama manualmente a `await GetIt.I.reset()` cuando sea necesario
- Usa instancias con nombre separadas para diferentes previews

## Aprende Más

- [Documentación del Widget Previewer de Flutter](https://docs.flutter.dev/tools/widget-previewer)
- [Guía de Pruebas de `get_it`](./testing.md) - Patrones similares para pruebas unitarias
- [Scopes de `get_it`](./scopes.md) - Para necesidades de aislamiento más avanzadas

## Próximos Pasos

- Prueba ambos enfoques en tu proyecto
- Crea funciones wrapper reutilizables para escenarios comunes
- Explora combinar previews con diferentes temas y tamaños
- Revisa el ejemplo completo en el repositorio de get_it
