# Observando Commands con `watch_it`

Una de las combinaciones más poderosas en el ecosistema `flutter_it` es usar `watch_it` para observar commands de `command_it`. Los commands son objetos `ValueListenable` que exponen su estado (`isRunning`, `value`, `errors`) como propiedades `ValueListenable`, haciéndolos naturalmente observables por `watch_it`. Este patrón proporciona gestión de estado reactiva y declarativa para operaciones async con estados de carga automáticos, manejo de errores y actualizaciones de resultado.

::: tip Aprende Sobre Commands Primero
Si eres nuevo en `command_it`, empieza con la guía [command_it Getting Started](/documentation/command_it/getting_started.md) para entender cómo funcionan los commands.
:::

## ¿Por Qué `watch_it` + `command_it`?

Los commands encapsulan operaciones async y rastrean su estado de ejecución (`isRunning`, `value`, `errors`). `watch_it` permite que tus widgets se reconstruyan reactivamente cuando estos estados cambian, creando una experiencia de usuario fluida sin gestión de estado manual.

**Beneficios:**
- **Estados de carga automáticos** - No necesitas rastrear manualmente booleanos `isLoading`
- **Resultados reactivos** - La UI se actualiza automáticamente cuando el command se completa
- **Manejo de errores incorporado** - Los commands rastrean errores, `watch_it` los muestra
- **Separación limpia** - Lógica de negocio en commands, lógica de UI en widgets
- **Sin boilerplate** - Sin `setState`, sin `StreamBuilder`, sin listeners manuales

## Observando un Command

Un patrón típico es observar tanto el resultado del command como su estado de ejecución como valores separados:

<<< @/../code_samples/lib/watch_it/watch_command_basic_example.dart#example

**Puntos clave:**
- Observa el command mismo para obtener su valor (el resultado)
- Observa `command.isRunning` para obtener el estado de ejecución
- El widget se reconstruye automáticamente cuando cualquiera cambia
- Los commands son objetos `ValueListenable`, por lo que funcionan perfectamente con `watch_it`
- El botón se deshabilita durante la ejecución
- El indicador de progreso se muestra mientras carga

## Observando Errores de Command

Muestra errores observando la propiedad `errors` del command:

<<< @/../code_samples/lib/watch_it/watch_command_errors_example.dart#example

**Patrones de manejo de errores:**
- Mostrar banner de error en la parte superior de la pantalla
- Mostrar mensaje de error inline
- Proporcionar botón de reintentar
- Limpiar errores al reintentar

## Usar Handlers para Efectos Secundarios

Mientras `watch` es para reconstruir UI, usa `registerHandler` para efectos secundarios como navegación o mostrar toasts:

### Handler de Éxito

<<< @/../code_samples/lib/watch_it/command_handler_success_example.dart#example

**Efectos secundarios comunes de éxito:**
- Navegar a otra pantalla
- Mostrar snackbar/toast de éxito
- Disparar otro command
- Registrar evento de analytics

### Handler de Error

<<< @/../code_samples/lib/watch_it/command_handler_error_example.dart#example

**Efectos secundarios comunes de error:**
- Mostrar diálogo de error
- Mostrar snackbar de error
- Registrar error en reporte de crashes
- Lógica de reintentar

## Observando Resultados de Command

La propiedad `results` proporciona un objeto `CommandResult` conteniendo todo el estado del command en un lugar:

<<< @/../code_samples/lib/watch_it/command_results_example.dart#example

**CommandResult contiene:**
- `data` - El valor actual del command
- `isRunning` - Si el command se está ejecutando
- `hasError` - Si ocurrió un error
- `error` - El objeto de error si hay alguno
- `isSuccess` - Si la ejecución tuvo éxito (`!isRunning && !hasError`)

**La extensión `.toWidget()`:**
- `onData` - Construir UI cuando los datos estén disponibles
- `onError` - Construir UI cuando ocurre un error (muestra último resultado exitoso si está disponible)
- `whileRunning` - Construir UI mientras el command se está ejecutando

Este patrón es ideal cuando necesitas manejar todos los estados del command de forma declarativa.

::: tip Otras Propiedades de Command
También puedes observar otras propiedades del command individualmente:
- `command.isRunning` - Estado de ejecución
- `command.errors` - Notificaciones de error
- `command.canRun` - Si el command puede ejecutarse actualmente (combina `!isRunning && !restriction`)
:::

## Encadenar Commands

Usa handlers para encadenar commands juntos:

<<< @/../code_samples/lib/watch_it/command_chaining_example.dart#example

**Patrones de encadenamiento:**
- Crear → Refrescar lista
- Login → Navegar a home
- Eliminar → Refrescar
- Subir → Procesar → Notificar

## Mejores Prácticas

### 1. Watch vs Handler

**Usa `watch` cuando:**
- Necesites reconstruir el widget
- Mostrar indicadores de carga
- Mostrar resultados
- Mostrar mensajes de error inline

**Usa `registerHandler` cuando:**
- Navegación después de éxito
- Mostrar diálogos/snackbars
- Logging/analytics
- Disparar otros commands
- Cualquier efecto secundario que no requiere reconstrucción

### 2. No Hagas Await run()

<<< @/../code_samples/lib/watch_it/command_observing_patterns.dart#dont_await_execute_good

<<< @/../code_samples/lib/watch_it/command_observing_patterns.dart#dont_await_execute_bad

**¿Por qué?** Los commands manejan async internamente. Solo llama `run()` y deja que `watch_it` actualice la UI reactivamente.

### 3. Observa Estado de Ejecución para Carga

<<< @/../code_samples/lib/watch_it/command_observing_patterns.dart#watch_execution_state_good

**Evita rastreo manual:** No uses `setState` y flags booleanos. Deja que commands y `watch_it` manejen el estado reactivamente.

## Patrones Comunes

### Envío de Formulario

<<< @/../code_samples/lib/watch_it/command_observing_patterns.dart#form_submission_pattern

### Pull to Refresh

<<< @/../code_samples/lib/watch_it/command_observing_patterns.dart#pull_to_refresh_pattern

## Ver También

- [command_it Documentation](/documentation/command_it/getting_started.md) - Aprende sobre commands
- [Watch Functions](/documentation/watch_it/watch_functions.md) - Todas las funciones watch
- [Handler Pattern](/documentation/watch_it/handlers.md) - Usar handlers
- [Best Practices](/documentation/watch_it/best_practices.md) - Mejores prácticas generales
