# Accediendo a Características de `get_it`

Esta guía muestra cómo acceder a características de `get_it` desde dentro de widgets `watch_it`. Para explicaciones detalladas de cada característica de `get_it`, ver la [documentación de `get_it`](/documentation/get_it/getting_started.md).

## Scopes con pushScope

Los scopes de `get_it` crean registros temporales que se limpian automáticamente. Perfecto para estado específico de pantalla. Ver [Scopes de `get_it`](/documentation/get_it/scopes.md) para detalles.

### pushScope() - Gestión Automática de Scope

`pushScope()` crea un scope cuando el widget se monta y lo limpia automáticamente al disponerse:

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#pushscope_automatic

**Qué sucede:**
1. El widget se construye por primera vez → Se empuja el scope, se ejecuta el callback `init`
2. Las dependencias se registran en el nuevo scope
3. El widget puede observar dependencias del scope
4. El widget se dispone → El scope se saca automáticamente, se ejecuta el callback `dispose`

### Caso de Uso: Estado Específico de Pantalla

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#screen_specific_state

## Instancias con Nombre

Observa instancias con nombre específicas desde `get_it`. Ver [Instancias con Nombre de `get_it`](/documentation/get_it/object_registration.md#named-instances) para detalles de registro.

### Observar Instancias con Nombre

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#watching_named_instances

**Casos de uso:**
- Múltiples configuraciones (dev/prod)
- Feature flags
- Variantes de A/B testing

## Inicialización Async

Maneja inicialización compleja donde las dependencias async deben estar listas antes de que la app inicie. Ver [Objetos Async de `get_it`](/documentation/get_it/async_objects.md) para detalles de registro.

### isReady - Dependencia Individual

Verifica si una dependencia async específica está lista:

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#isready_single_dependency

### allReady - Múltiples Dependencias

Espera a que todas las dependencias async se completen:

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#allready_multiple_dependencies

### Observar Progreso de Inicialización

<<< @/../code_samples/lib/watch_it/advanced_integration_patterns.dart#watching_initialization_progress

## Ver También

- [Documentación de Scopes de `get_it`](/documentation/get_it/scopes.md)
- [Objetos Async de `get_it`](/documentation/get_it/async_objects.md)
- [Instancias con Nombre de `get_it`](/documentation/get_it/object_registration.md#named-instances)
- [Best Practices](/documentation/watch_it/best_practices.md)
