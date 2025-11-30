# Mejores Prácticas

Patrones listos para producción, anti-patrones, y guías para usar `command_it` efectivamente.

## Cuándo Usar Commands

### ✅ Usa Commands Para

**Operaciones async con feedback de UI:**

<<< @/../code_samples/lib/command_it/best_practices_when_to_use.dart#async_ui_feedback

**Operaciones que pueden fallar:**

<<< @/../code_samples/lib/command_it/best_practices_when_to_use.dart#operations_can_fail

**Acciones disparadas por usuario:**

<<< @/../code_samples/lib/command_it/best_practices_when_to_use.dart#user_triggered

**Operaciones que necesitan tracking de estado:**
- Estados de carga de botones
- Pull-to-refresh
- Envío de formularios
- Peticiones de red
- I/O de archivos

### ✅ Usa Commands Sync para Input con Operadores

Cuando necesitas aplicar operadores (debounce, map, where) a input de usuario antes de disparar otras operaciones:

<<< @/../code_samples/lib/command_it/best_practices_when_to_use.dart#sync_input_operators

Esto es diferente de simples getters/setters porque:
- Captura input de usuario como un stream de valores
- Usa operadores como `.debounce()` para procesar el stream
- Encadena para disparar otros commands

**Ver también:** El [ejemplo de clima](https://github.com/flutter-it/command_it/blob/main/example/lib/weather_manager.dart) demuestra este patrón con `textChangedCommand`.

### ❌️️ No Uses Commands Para

**Simples getters/setters (sin operadores o encadenamiento):**

<<< @/../code_samples/lib/command_it/best_practices_when_to_use.dart#dont_use_getter

**Cómputos puros sin efectos secundarios:**

<<< @/../code_samples/lib/command_it/best_practices_when_to_use.dart#dont_use_computation

**Cambios de estado inmediatos:**

<<< @/../code_samples/lib/command_it/best_practices_when_to_use.dart#dont_use_toggle

## Patrones de Organización

### Patrón 1: Commands en Managers

<<< @/../code_samples/lib/command_it/best_practices_organization.dart#managers_managers

**Beneficios:**
- Lógica de negocio centralizada
- Fácil testing
- Reutilizable entre widgets
- Propiedad clara

### Patrón 2: Organización Basada en Features

<<< @/../code_samples/lib/command_it/best_practices_organization.dart#feature_based

### Patrón 3: Commands en Data Proxies

Los Commands también pueden vivir en objetos de datos que gestionan sus propias operaciones async. Esto es útil cuando cada item de datos necesita estado de carga independiente:

<<< @/../code_samples/lib/command_it/best_practices_organization.dart#proxy_pattern

**Beneficios:**
- Cada item tiene estado de carga/error independiente
- La lógica de caching vive con los datos
- La UI puede observar estado de item individual
- El manager se mantiene simple (solo crea/cachea proxies)

## Cuándo Usar runAsync()

Como se explica en [Fundamentos de Command](/es/documentation/command_it/command_basics), el patrón central de command es **dispara-y-olvida**: llama `run()` y deja que tu UI observe cambios de estado reactivamente. Sin embargo, hay casos legítimos donde usar `runAsync()` es apropiado y más expresivo que las alternativas.

### ✅ Usa runAsync() Para Flujos de Trabajo Secuenciales

Cuando los commands son parte de un flujo de trabajo async más grande mezclado con otras operaciones async:

<<< @/../code_samples/lib/command_it/best_practices_run_async.dart#async_workflow

**¿Por qué `runAsync()` aquí?** El command es parte de una función async más grande que mezcla ejecución de commands con llamadas async regulares. Usar `runAsync()` mantiene el código lineal y legible.

### ✅ Usa runAsync() Para APIs que Requieren Futures

Cuando interactúas con APIs que requieren un `Future`:

<<< @/../code_samples/lib/command_it/best_practices_run_async.dart#api_futures

### ❌️ No Uses runAsync() para Actualizaciones de UI Simples

<<< @/../code_samples/lib/command_it/best_practices_run_async.dart#dont_use_runasync

### Resumen

**Usa `runAsync()` cuando:**
- ✅ Los commands son parte de un flujo de trabajo async más grande
- ✅ Una API requiere que se retorne un Future
- ✅ El flujo secuencial es más claro con `await` que con `.listen()`

**No uses `runAsync()` cuando:**
- ❌️ Disparando commands desde interacciones de UI (usa `run()`)
- ❌️ Solo quieres observar resultados (usa `watchValue()` o `ValueListenableBuilder`)
- ❌️ El async/await no agrega valor sobre dispara-y-olvida

## Mejores Prácticas de Rendimiento

### Debounce de Input de Texto

<<< @/../code_samples/lib/command_it/best_practices_performance.dart#debounce

### Dispose de Commands Apropiadamente

<<< @/../code_samples/lib/command_it/best_practices_performance.dart#dispose

### Evitar Rebuilds Innecesarios

<<< @/../code_samples/lib/command_it/best_practices_performance.dart#rebuilds

## Mejores Prácticas de Restricciones

### Usa isRunningSync para Dependencias de Commands

<<< @/../code_samples/lib/command_it/best_practices_restriction.dart#isrunningsync

### La Lógica de Restricción Está Invertida

<<< @/../code_samples/lib/command_it/best_practices_restriction.dart#inverted

## Anti-Patrones Comunes

### ❌️️ No Escuchar Errores

<<< @/../code_samples/lib/command_it/best_practices_antipatterns.dart#not_listening_errors

### ❌️️ Try/Catch Dentro de Commands

No uses try/catch dentro de funciones de commands - derrota el sistema de manejo de errores de `command_it`:

<<< @/../code_samples/lib/command_it/best_practices_antipatterns.dart#try_catch_inside

## Ver También

- [Fundamentos de Command](/es/documentation/command_it/command_basics) — Primeros pasos
- [Manejo de Errores (Error Handling)](/es/documentation/command_it/error_handling) — Gestión de errores
- [Testing](/es/documentation/command_it/testing) — Patrones de testing
- [Observando Commands con `watch_it`](/es/documentation/watch_it/observing_commands) — Patrones de UI reactiva
