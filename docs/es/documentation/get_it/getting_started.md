---
title: Primeros pasos con get_it
prev:
  text: 'Qué hacer con cada paquete'
  link: '/es/getting_started/what_to_do_with_which_package'
next:
  text: 'Registro de Objetos'
  link: '/es/documentation/get_it/object_registration'
---

<div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 2rem;">
  <img src="/images/get_it.svg" alt="get_it logo" width="100" />
  <h1 style="margin: 0;">Primeros Pasos</h1>
</div>

::: tip 🤖 Desarrollo Asistido por IA
get_it incluye **archivos de skills de IA** en su directorio `skills/`. Ayudan a los asistentes de código con IA a generar código correcto de get_it. [Más información →](/es/misc/ai_skills)
:::

<strong>get_it</strong> es un Service Locator simple y rápido para Dart y Flutter que te permite acceder a cualquier objeto que registres desde cualquier parte de tu app sin necesitar `BuildContext` o árboles de widgets complejos.

<strong>Beneficios clave:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Extremadamente rápido</strong> - Búsqueda O(1) usando Map de Dart</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Fácil de probar</strong> - Cambia implementaciones por mocks en pruebas</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>No necesita BuildContext</strong> - Accede desde cualquier lugar en tu app (UI, lógica de negocio, donde sea)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Tipado seguro</strong> - Verificación de tipos en tiempo de compilación</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Sin generación de código</strong> - Funciona sin build_runner</li>
</ul>

<strong>Casos de uso comunes:</strong>
- Acceder a servicios como clientes API, bases de datos o autenticación desde cualquier lugar
- Gestionar estado global de la app (view models, managers, BLoCs)
- Cambiar fácilmente implementaciones para pruebas

![Flujo de datos get_it](/images/get-it-flow.svg)

> Únete a nuestro servidor de Discord para soporte: [https://discord.com/invite/Nn6GkYjzW](https://discord.com/invite/Nn6GkYjzW)

---

## Instalación

Añade get_it a tu `pubspec.yaml`:

```yaml
dependencies:
  get_it: ^8.3.0  # Consulta pub.dev para la última versión
```

---

## Ejemplo Rápido

<strong>Paso 1:</strong> Crea una instancia global de GetIt (típicamente en un archivo separado):


<<< @/../code_samples/lib/get_it/configure_dependencies_example.dart#example

<strong>Paso 2:</strong> Llama a tu función de configuración <strong>antes</strong> de `runApp()`:


<<< @/../code_samples/lib/get_it/main_example.dart#example

<strong>Paso 3:</strong> Accede a tus servicios desde cualquier lugar:


<<< @/../code_samples/lib/get_it/login_page_example.dart#example

<strong>¡Eso es todo!</strong> Sin wrappers de Provider, sin InheritedWidgets, sin necesidad de BuildContext.

---

## Nombrando tu Instancia de GetIt

El patrón estándar es crear una variable global:


<<< @/../code_samples/lib/get_it/code_sample_866f5818.dart#example

<strong>Nombres alternativos que podrías ver:</strong>
- `final sl = GetIt.instance;` (service locator)
- `final locator = GetIt.instance;`
- `final di = GetIt.instance;` (dependency injection)
- `GetIt.instance` o `GetIt.I` (usar directamente sin variable)

<strong>Recomendación:</strong> Usa `getIt` o `di` - ambos son claros y ampliamente reconocidos en la comunidad Flutter.

::: tip Usando con `watch_it`
Si estás usando el paquete [`watch_it`](https://pub.dev/packages/watch_it), ya tienes disponible una instancia global `di` - no necesitas crear la tuya. Solo importa `watch_it` y usa `di` directamente.
:::

::: tip Uso entre Paquetes
`GetIt.instance` devuelve el mismo singleton a través de todos los paquetes en tu proyecto. Crea tu variable global una vez en tu app principal e impórtala en otros lugares.
:::

::: warning Seguridad con Isolates
Las instancias de GetIt no son thread-safe y no pueden compartirse entre isolates. Cada isolate obtendrá su propia instancia de GetIt. Esto significa que los objetos registrados en un isolate no pueden accederse desde otro isolate.
:::

---

## Cuándo Usar Cada Tipo de Registro

`get_it` ofrece tres tipos principales de registro:

| Tipo de Registro | Cuándo se Crea | Tiempo de Vida | Úsalo Cuando |
|-------------------|--------------|----------|----------|
| [<strong>registerSingleton</strong>](/es/documentation/get_it/object_registration#singleton) | Inmediatamente | Permanente | El servicio se necesita al inicio, rápido de crear |
| [<strong>registerLazySingleton</strong>](/es/documentation/get_it/object_registration#lazysingleton) | Primer acceso | Permanente | El servicio no siempre se necesita, costoso de crear |
| [<strong>registerFactory</strong>](/es/documentation/get_it/object_registration#factory) | Cada llamada a `get()` | Temporal | Necesitas una nueva instancia cada vez (diálogos, objetos temporales) |

<strong>Ejemplos:</strong>


<<< @/../code_samples/lib/get_it/configure_dependencies.dart#example

<strong>Mejor práctica:</strong> Usa `registerSingleton()` si tu objeto se va a usar de todos modos y no requiere recursos significativos para crearlo - es el enfoque más simple. Solo usa `registerLazySingleton()` cuando necesites retrasar una inicialización costosa o para servicios que no siempre se necesitan.

---

## Accediendo a Servicios

El parámetro de tipo genérico que proporcionas al registrar es el que se usa cuando accedes a un objeto después de registrarlo. **Si no lo proporcionas, Dart lo inferirá del tipo de implementación:**

Obtén tus servicios registrados usando `getIt<Tipo>()`:


<<< @/../code_samples/lib/get_it/accessing_services_example.dart#example

::: tip Sintaxis Abreviada
`getIt<Tipo>()` es la abreviatura de `getIt.get<Tipo>()`. ¡Ambas funcionan igual - usa la que prefieras!
:::

---

## Registrando Clases Concretas vs Interfaces

<strong>La mayoría del tiempo, registra tus clases concretas directamente:</strong>


<<< @/../code_samples/lib/get_it/configure_dependencies_example_1.dart#example

Esto es más simple y hace que la navegación del IDE a la implementación sea más fácil.

<strong>Solo usa interfaces abstractas cuando esperes múltiples implementaciones:</strong>


<<< @/../code_samples/lib/get_it/configure_dependencies_example_2.dart#example

<strong>Cuándo usar interfaces:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Múltiples implementaciones (producción vs prueba, diferentes proveedores)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Implementaciones específicas de plataforma (móvil vs web)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Feature flags para cambiar implementaciones</li>
</ul>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ No uses "solo porque sí" - crea fricción de navegación en tu IDE</li>
</ul>

```dart
// Sin parámetro de tipo - Dart infiere StripePaymentProcessor
getIt.registerSingleton(StripePaymentProcessor());
getIt<PaymentProcessor>(); // ❌️ Error - no registrado como PaymentProcessor

// Con parámetro de tipo - registra explícitamente como PaymentProcessor
getIt.registerSingleton<PaymentProcessor>(StripePaymentProcessor());
getIt<PaymentProcessor>(); // ✅ Funciona - registrado como PaymentProcessor
```

### Cambiando Implementaciones

Un patrón común es cambiar entre implementaciones reales y simuladas usando registro condicional:


<<< @/../code_samples/lib/get_it/conditional_registration_example.dart#example

Debido a que ambas implementaciones están registradas como `<PaymentProcessor>`, el resto de tu código permanece sin cambios - siempre solicita `getIt<PaymentProcessor>()` independientemente de qué implementación esté registrada.

---

## Organizando tu Código de Configuración

Para apps más grandes, divide el registro en grupos lógicos:


<<< @/../code_samples/lib/get_it/configure_dependencies_example_3.dart#example

Mira [¿Dónde debería poner mi código de configuración de get_it?](/es/documentation/get_it/faq#donde-deberia-poner-mi-codigo-de-configuracion-de-get_it) para más patrones.

---

## ¿Quieres Menos Código Repetitivo? ¡Prueba Injectable!

**Injectable** es un paquete de generación de código que automatiza tu configuración de `get_it`. Si te encuentras escribiendo mucho código de registro, injectable podría ser para ti.

### Cómo Funciona

En lugar de registrar manualmente cada servicio:

```dart
void configureDependencies() {
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<Database>(() => Database());
  getIt.registerLazySingleton<AuthService>(() => AuthService(getIt(), getIt()));
}
```

Solo anota tus clases:

```dart
@lazySingleton
class ApiClient { }

@lazySingleton
class Database { }

@lazySingleton
class AuthService {
  AuthService(ApiClient api, Database db); // ¡Auto-inyectado!
}
```

Ejecuta build_runner e injectable genera todo el código de registro por ti.

### Configuración Rápida

1. Agrega dependencias:
```yaml
dependencies:
  get_it: ^8.3.0
  injectable: ^2.3.2

dev_dependencies:
  injectable_generator: ^2.6.1
  build_runner: ^2.4.0
```

2. Anota tu configuración principal:
```dart
@InjectableInit()
void configureDependencies() => getIt.init();
```

3. Ejecuta la generación de código:
```bash
flutter pub run build_runner build
```

### Cuándo Usar Injectable

**Usa injectable si:**
- Tienes muchos servicios para registrar
- Quieres resolución automática de dependencias
- Prefieres anotaciones sobre configuración manual
- Te sientes cómodo con generación de código

**Quédate con `get_it` simple si:**
- Prefieres registro explícito y visible
- Quieres evitar build_runner en tu flujo de trabajo
- Tienes un número pequeño de servicios
- Quieres control total sobre el orden y la lógica de registro

¡Ambos enfoques usan la misma instancia de `GetIt` y tienen rendimiento en tiempo de ejecución idéntico!

### Aprende Más

Visita [injectable en pub.dev](https://pub.dev/packages/injectable) para documentación completa y características avanzadas como:
- Registros específicos por ambiente (dev/prod)
- Dependencias pre-resueltas
- Registro de módulos
- Anotaciones personalizadas

::: tip Soporte de Injectable
Injectable es un paquete separado mantenido por un autor diferente. Si encuentras problemas con injectable, por favor repórtalos en el [repositorio de GitHub de injectable](https://github.com/Milad-Akarie/injectable/issues).
:::

---

## Siguientes Pasos

Ahora que entiendes los básicos, explora estos temas:

<strong>Conceptos Principales:</strong>
- [Registro de Objetos](/es/documentation/get_it/object_registration) - Todos los tipos de registro en detalle
- [Scopes](/es/documentation/get_it/scopes) - Gestiona el tiempo de vida de servicios para login/logout, características
- [Objetos Asíncronos](/es/documentation/get_it/async_objects) - Maneja servicios con inicialización asíncrona
- [Pruebas](/es/documentation/get_it/testing) - Prueba tu código que usa get_it

<strong>Características Avanzadas:</strong>
- [Registros Múltiples](/documentation/get_it/multiple_registrations) - Sistemas de plugins, observadores, middleware
- [Patrones Avanzados](/documentation/get_it/advanced) - Instancias con nombre, conteo de referencias, utilidades

<strong>Ayuda:</strong>
- [FAQ](/es/documentation/get_it/faq) - Preguntas comunes y solución de problemas
- [Ejemplos](/examples/get_it/get_it) - Ejemplos de código del mundo real

---

## ¿Por qué get_it?

<details>
<summary>Haz clic para aprender sobre la motivación detrás de get_it</summary>

A medida que tu app crece, necesitas separar la lógica de negocio del código de UI. Esto hace que tu código sea más fácil de probar y mantener. ¿Pero cómo accedes a estos servicios desde tus widgets?

<strong>Enfoques tradicionales y sus limitaciones:</strong>

<strong>InheritedWidget / Provider:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Requiere `BuildContext` (no disponible en la capa de negocio)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Añade complejidad al árbol de widgets</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Difícil de acceder desde tareas en segundo plano, isolates</li>
</ul>

<strong>Singletons Simples:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ No puedes cambiar la implementación para pruebas</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Acoplamiento fuerte a clases concretas</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Sin gestión del ciclo de vida</li>
</ul>

<strong>Contenedores IoC/DI:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Inicio lento (basados en reflexión)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ "Mágicos" - difícil de entender de dónde vienen los objetos</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ La mayoría no funcionan con Flutter (sin reflexión)</li>
</ul>

<strong>get_it resuelve estos problemas:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Accede desde cualquier lugar sin BuildContext</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Fácil de simular para pruebas (registra interfaz, cambia implementación)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Extremadamente rápido (sin reflexión, solo búsqueda en Map)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Claro y explícito (ves exactamente qué está registrado)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Gestión del ciclo de vida (scopes, disposal)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Funciona en Dart puro y Flutter</li>
</ul>

<strong>Patrón Service Locator:</strong>

get_it implementa el patrón Service Locator - desacopla la interfaz (clase abstracta) de la implementación concreta mientras permite acceso desde cualquier lugar.

Para una comprensión más profunda, lee el artículo clásico de Martin Fowler: [Inversion of Control Containers and the Dependency Injection pattern](https://martinfowler.com/articles/injection.html)

</details>
