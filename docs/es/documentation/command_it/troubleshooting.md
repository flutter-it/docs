# Resolución de Problemas

Problemas comunes con command_it y cómo solucionarlos.

::: tip Problema → Diagnóstico → Solución
Esta guía está organizada por **síntomas** que observas. Encuentra tu problema, diagnostica la causa, y aplica la solución.
:::

## UI No Se Actualiza

### El command completa pero la UI no se reconstruye

**Síntomas:**
- El command se ejecuta pero la UI no se actualiza
- Los datos parecen sin cambios
- No hay errores visibles

**Diagnóstico 1:** El command lanzó una excepción

El command podría haber fallado silenciosamente. Verifica si estás escuchando errores:

<<< @/../code_samples/lib/command_it/troubleshooting_ui_not_updating.dart#diagnosis1_bad

**Solución:** Escucha errores o verifica `.results`:

<<< @/../code_samples/lib/command_it/troubleshooting_ui_not_updating.dart#diagnosis1_good

**Diagnóstico 2:** No estás observando el command en absoluto

Verifica si realmente estás observando el valor del command:

<<< @/../code_samples/lib/command_it/troubleshooting_ui_not_updating.dart#diagnosis2_bad

**Solución:** Usa `ValueListenableBuilder` o `watch_it`:

<<< @/../code_samples/lib/command_it/troubleshooting_ui_not_updating.dart#diagnosis2_good

**Ver también:** [Manejo de Errores (Error Handling)](/es/documentation/command_it/error_handling), [documentación de `watch_it`](/es/documentation/watch_it/getting_started)

---

## Problemas de Ejecución de Commands

### El command no se ejecuta / no pasa nada

**Síntomas:**
- Llamar `command('param')` no hace nada
- Sin estado de carga, sin errores, sin resultados

**Diagnóstico:**

Verifica si el command está restringido:

<<< @/../code_samples/lib/command_it/troubleshooting_execution_issues.dart#restriction_diagnosis

**Solución 1:** Verifica el valor de la restricción

<<< @/../code_samples/lib/command_it/troubleshooting_execution_issues.dart#restriction_debug

**Solución 2:** Maneja la ejecución restringida

<<< @/../code_samples/lib/command_it/troubleshooting_execution_issues.dart#restriction_handler

**Ver también:** [Propiedades del Command - Restricciones](/es/documentation/command_it/command_properties#restriccion)

---

### El command está atascado en estado "running"

**Síntomas:**
- `isRunning` se mantiene `true` para siempre
- El indicador de carga nunca desaparece
- El command no se ejecuta de nuevo

**Diagnóstico:**

Verifica si la función async completa:

<<< @/../code_samples/lib/command_it/troubleshooting_execution_issues.dart#stuck_diagnosis

**Causa:** La función async nunca completa

<<< @/../code_samples/lib/command_it/troubleshooting_execution_issues.dart#stuck_cause

**Solución:**

Agrega un timeout para capturar operaciones colgadas:

<<< @/../code_samples/lib/command_it/troubleshooting_execution_issues.dart#stuck_solution

::: tip Los Errores No Causan Estado Atascado
Si tu función async lanza una excepción, el command la captura y resetea `isRunning` a `false`. Los errores no causarán un estado running atascado - solo futures que nunca completan lo harán.
:::

---

## Problemas de Manejo de Errores

### Los errores no se muestran en UI

**Síntomas:**
- El command falla pero la UI no muestra estado de error
- Errores logueados a crash reporter pero no mostrados en UI

**Diagnóstico:**

Verifica si el filtro de error solo enruta a handler global:

<<< @/../code_samples/lib/command_it/troubleshooting_error_handling.dart#global_only_bad

Con `globalHandler`, los errores van a `Command.globalExceptionHandler` pero los listeners de `.errors` y `.results` no son notificados.

**Solución:** Usa un filtro que incluya handler local

<<< @/../code_samples/lib/command_it/troubleshooting_error_handling.dart#local_filter_good

**Ver también:** [Manejo de Errores (Error Handling) - Filtros de Error](/es/documentation/command_it/error_handling#filtros-de-error)

---

## Problemas de Rendimiento

### Demasiados rebuilds / UI lenta

**Síntomas:**
- La UI se reconstruye en cada ejecución de command
- Incluso cuando el resultado es idéntico

**Diagnóstico:**

Por defecto, los commands notifican a listeners en cada ejecución exitosa, incluso si el resultado es idéntico. Esto es intencional - una UI que no se actualiza después de una acción de refresh a menudo es más confusa para los usuarios.

**Solución:** Usa `notifyOnlyWhenValueChanges: true`

Si tu command frecuentemente retorna resultados idénticos y los rebuilds están causando problemas de rendimiento:

<<< @/../code_samples/lib/command_it/troubleshooting_performance.dart#notify_only_when_changes

::: tip Cuándo Usar Esto
Usa `notifyOnlyWhenValueChanges: true` para commands de polling/refresh donde resultados idénticos son comunes. Mantén el valor por defecto (`false`) para acciones disparadas por usuario donde se espera feedback.
:::

---

### El command se ejecuta muy a menudo

**Síntomas:**
- El command se ejecuta múltiples veces inesperadamente
- Viendo llamadas API duplicadas
- Desperdiciando recursos

**Diagnóstico:**

Verifica si estás llamando al command en build:

<<< @/../code_samples/lib/command_it/troubleshooting_command_executes_often.dart#diagnosis_bad

**Solución 1:** Llama solo en handlers de eventos

<<< @/../code_samples/lib/command_it/troubleshooting_command_executes_often.dart#solution1

**Solución 2:** Usa `callOnce` para inicialización

<<< @/../code_samples/lib/command_it/troubleshooting_command_executes_often.dart#solution2

**Solución 3:** Debounce de llamadas rápidas

<<< @/../code_samples/lib/command_it/troubleshooting_command_executes_often.dart#solution3

---

## Memory Leaks

### Los commands no se están disposing

**Síntomas:**
- El uso de memoria crece con el tiempo
- Flutter DevTools muestra listeners incrementándose
- La app se vuelve lenta

**Diagnóstico:**

Verifica si estás disposing commands:

<<< @/../code_samples/lib/command_it/troubleshooting_memory_leaks.dart#diagnosis_bad

**Solución:**

Siempre dispose commands en `dispose()` o `onDispose()`:

<<< @/../code_samples/lib/command_it/troubleshooting_memory_leaks.dart#solution

**Para singletons de `get_it`:**

<<< @/../code_samples/lib/command_it/troubleshooting_memory_leaks.dart#get_it_dispose

---

## Problemas de Integración

### `watch_it` no encuentra el command

**Síntomas:**
- `watchValue` lanza error: "No registered instance found"
- El command funciona con acceso directo pero no con `watch_it`

**Diagnóstico:**

Verifica si el manager está registrado en `get_it`:

<<< @/../code_samples/lib/command_it/troubleshooting_integration.dart#watch_it_not_registered

**Solución:**

Registra el manager en `get_it` antes de usar `watch_it`:

<<< @/../code_samples/lib/command_it/troubleshooting_integration.dart#register_first

**Ver también:** [documentación de `get_it`](/es/documentation/get_it/getting_started)

---

### ValueListenableBuilder no se actualiza

**Síntomas:**
- Usando `ValueListenableBuilder` directamente
- La UI no se actualiza cuando el command completa

**Diagnóstico:**

Error común - creando nueva instancia en cada build:

<<< @/../code_samples/lib/command_it/troubleshooting_integration.dart#vlb_new_instance_bad

**Solución:**

El command debe crearse una vez y reutilizarse:

<<< @/../code_samples/lib/command_it/troubleshooting_integration.dart#vlb_reuse_good

---

## Problemas de Tipos

### CommandResult no tiene data durante loading/error

**Síntomas:**
- Acceder a `result.data` retorna null inesperadamente
- Los datos desaparecen mientras el command se ejecuta
- Datos anteriores desaparecen después de un error

**Diagnóstico:**

Por defecto, `CommandResult.data` solo está disponible después de completación exitosa. Durante loading o después de un error, `.data` es null:

<<< @/../code_samples/lib/command_it/troubleshooting_commandresult_data.dart#diagnosis

**Solución 1:** Usa `includeLastResultInCommandResults: true`

Esto preserva el último resultado exitoso durante estados de loading y error:

<<< @/../code_samples/lib/command_it/troubleshooting_commandresult_data.dart#solution1

**Solución 2:** Verifica estado antes de acceder a data

<<< @/../code_samples/lib/command_it/troubleshooting_commandresult_data.dart#solution2

**Solución 3:** Usa el command directamente (siempre tiene data)

<<< @/../code_samples/lib/command_it/troubleshooting_commandresult_data.dart#solution3

---

### La inferencia de tipos genéricos falla

**Síntomas:**
- Dart no puede inferir tipos de commands
- Necesitas especificar tipos explícitamente en todas partes

**Diagnóstico:**

Command creado sin tipos explícitos:

<<< @/../code_samples/lib/command_it/troubleshooting_type_issues.dart#inference_bad

**Solución:**

Especifica tipos genéricos explícitamente:

<<< @/../code_samples/lib/command_it/troubleshooting_type_issues.dart#inference_good

---

## ¿Aún Tienes Problemas?

1. **Revisa la documentación:** Cada característica de command_it tiene documentación detallada
2. **Busca issues existentes:** [Issues de GitHub de command_it](https://github.com/escamoteur/command_it/issues)
3. **Pregunta en Discord:** [Discord de flutter_it](https://discord.gg/ZHYHYCM38h)
4. **Crea un issue:** Incluye código mínimo de reproducción

**Al reportar issues, incluye:**
- Ejemplo de código mínimo que reproduce el problema
- Comportamiento esperado vs comportamiento actual
- Versión de command_it (`pubspec.yaml`)
- Versión de Flutter (`flutter --version`)
- Cualquier mensaje de error o stack traces
