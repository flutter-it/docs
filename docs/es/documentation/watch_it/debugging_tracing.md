# Debugging y Resolución de Problemas

Errores comunes, soluciones, técnicas de debugging y estrategias de resolución de problemas para `watch_it`.

## Errores Comunes

### "Watch ordering violation detected!"

**Mensaje de error:**
```
Watch ordering violation detected!

You have conditional watch calls (inside if/switch statements) that are
causing `watch_it` to retrieve the wrong objects on rebuild.

Fix: Move ALL conditional watch calls to the END of your build method.
Only the LAST watch call can be conditional.
```

**Causa:** Llamadas watch dentro de declaraciones `if` seguidas por otros watches, causando que el orden cambie entre construcciones.

**Solución:** Ver [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) para explicación detallada, ejemplos y patrones seguros.

**Tip de debugging:** Llama a `enableTracing()` en tu método build para ver las ubicaciones exactas de fuente de las declaraciones watch en conflicto.

### "watch() called outside build"

**Mensaje de error:**
```
watch() can only be called inside build()
```

**Causa:** Intentar usar funciones watch en callbacks, constructores u otros métodos.

**Ejemplo:**

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#watch_outside_build_bad

**Solución:** Solo llama funciones watch directamente en `build()`:

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#watch_outside_build_good

### "Type 'X' is not a subtype of type 'Listenable'"

**Mensaje de error:**
```
type 'MyManager' is not a subtype of type 'Listenable'
```

**Causa:** Usar `watchIt<T>()` en un objeto que no es un `Listenable`.

**Ejemplo:**

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#not_listenable_bad

**Solución:** Usa `watchValue()` en su lugar:

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#not_listenable_good_watch_value

O haz que tu manager extienda `ChangeNotifier`:

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#not_listenable_good_change_notifier

### "get_it: Object/factory with type X is not registered"

**Mensaje de error:**
```
get_it: Object/factory with type TodoManager is not registered inside GetIt
```

**Causa:** Intentar observar un objeto que no ha sido registrado en `get_it`.

**Solución:** Regístralo antes de usarlo:

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#not_registered_solution

Ver [Registro de Objetos en get_it](/documentation/get_it/object_registration.md) para todos los métodos de registro.

### El widget no se reconstruye cuando los datos cambian

**Síntomas:**
- Los datos cambian pero la UI no se actualiza
- `print()` muestra nuevos valores pero el widget todavía muestra datos antiguos

**Causas comunes:**

#### 1. No observar los datos

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#not_watching_bad

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#not_watching_good

#### 2. No notificar cambios

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#not_notifying_bad

**Opción 1 - Usar ListNotifier de `listen_it` (recomendado):**

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#not_notifying_good_list_notifier

**Opción 2 - Usar ValueNotifier personalizado con notificación manual:**

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#not_notifying_good_custom_notifier

Ver [Colecciones de listen_it](/documentation/listen_it/collections/introduction.md) para ListNotifier, MapNotifier y SetNotifier.

### Memory leaks - suscripciones no limpiadas

**Síntomas:**
- El uso de memoria crece con el tiempo
- Widgets antiguos todavía reaccionando a cambios
- El rendimiento se degrada

**Causa:** No usar `WatchingWidget` o `WatchItMixin` - hacer suscripciones manuales.

**Solución:** Siempre usa widgets `watch_it`:

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#memory_leak_bad

<<< @/../code_samples/lib/watch_it/debugging_common_errors.dart#memory_leak_good

### registerHandler no se dispara

**Síntomas:**
- El callback del handler nunca se ejecuta
- Los efectos secundarios (navegación, diálogos) no suceden
- No se lanzan errores

**Causas comunes:**

#### 1. Handler registrado después de return condicional

<<< @/../code_samples/lib/watch_it/debugging_registerhandler.dart#handler_registered_after_return_bad

**Solución:** Registra handlers ANTES de cualquier return condicional:

<<< @/../code_samples/lib/watch_it/debugging_registerhandler.dart#handler_registered_before_return_good

#### 2. Widget destruido durante la ejecución del command

Si el widget que contiene el handler se destruye y reconstruye mientras el command se está ejecutando, el handler se re-registrará y puede perder cambios de estado.

**Ejemplo:** Un botón dentro de un widget que se reconstruye al hacer hover:

<<< @/../code_samples/lib/watch_it/handler_lifecycle_example.dart#bad

**Solución:** Mueve el handler a un widget padre estable:

<<< @/../code_samples/lib/watch_it/handler_lifecycle_example.dart#good

## Técnicas de Debugging

### Habilitar Tracing de `watch_it`

Obtén logs detallados de suscripciones watch y ubicaciones de fuente para violaciones de ordenamiento:

```dart
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Llama al inicio del build para habilitar tracing
    enableTracing(
      logRebuilds: true,
      logHandlers: true,
      logHelperFunctions: true,
    );

    final todos = watchValue((TodoManager m) => m.todos);
    // ... resto del build
  }
}
```

**Beneficios:**
- Muestra qué watch disparó la reconstrucción de tu widget
- Muestra ubicaciones exactas de fuente de las llamadas watch
- Ayuda a identificar violaciones de ordenamiento
- Rastrea actividad de reconstrucción
- Muestra ejecuciones de handler

**Caso de uso:** Cuando tu widget se reconstruye inesperadamente, habilita tracing para ver exactamente qué valor observado cambió y disparó la reconstrucción. Esto te ayuda a identificar si estás observando demasiados datos o las propiedades incorrectas.

**Alternativa:** Usa el widget `WatchItSubTreeTraceControl` para habilitar tracing para un subárbol específico:

```dart
// Primero, habilita subtree tracing globalmente (típicamente en main())
enableSubTreeTracing = true;

// Luego envuelve SOLO el widget/pantalla problemático - ¡NO toda la app!
// De lo contrario te ahogarás en logs de cada widget
return Scaffold(
  body: WatchItSubTreeTraceControl(
    logRebuilds: true,        // Requerido: registrar eventos de reconstrucción
    logHandlers: true,        // Requerido: registrar ejecuciones de handler
    logHelperFunctions: true, // Requerido: registrar llamadas de función helper
    child: ProblematicWidget(), // Solo el widget que estás debuggeando
  ),
);
```

**Importante:** Envuelve solo el widget o pantalla específica que causa problemas, no toda tu app. Hacer tracing de toda la app genera cantidades abrumadoras de logs.

**Nota:**
- Puedes anidar múltiples widgets `WatchItSubTreeTraceControl` - se aplican las configuraciones del ancestro más cercano
- Debes establecer `enableSubTreeTracing = true` globalmente para que los controles de subárbol funcionen

### Aislar el problema

Crea reproducción mínima:

<<< @/../code_samples/lib/watch_it/debugging_patterns.dart#isolate_problem

Esto aísla:
- ¿Funciona la suscripción watch?
- ¿Se reconstruye el widget en cambio de datos?
- ¿Hay problemas de ordenamiento?

## Obtener Ayuda

Al reportar problemas:

1. **Reproducción mínima** - Aísla el problema
2. **Versiones** - Versiones de `watch_it`, Flutter, Dart
3. **Mensajes de error** - Stack trace completo
4. **Esperado vs actual** - Qué debería suceder vs qué sucede
5. **Muestra de código** - Ejemplo completo y ejecutable

**Dónde preguntar:**
- **Discord:** [Únete a la comunidad flutter_it](https://discord.gg/ZHYHYCM38h)
- **GitHub Issues:** [issues de watch_it](https://github.com/escamoteur/watch_it/issues)
- **Stack Overflow:** Etiqueta con `flutter` y `watch-it`

## Ver También

- [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) - Restricciones CRÍTICAS
- [Best Practices](/documentation/watch_it/best_practices.md) - Patrones y tips
- [How watch_it Works](/documentation/watch_it/how_it_works.md) - Entender el mecanismo
