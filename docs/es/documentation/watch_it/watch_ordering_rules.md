# Reglas de Orden de Watch

## La Regla de Oro

**Todas las llamadas a funciones watch deben ocurrir en el MISMO ORDEN en cada construcción.**

Esta es la regla más importante en `watch_it`. Violarla causará errores o comportamiento inesperado.

## ¿Por Qué Importa el Orden?

`watch_it` usa un mecanismo de estado global similar a React Hooks. Cada llamada watch se asigna un índice basado en su posición en la secuencia de construcción. Cuando el widget se reconstruye, `watch_it` espera encontrar los mismos watches en el mismo orden.

**Qué sucede si el orden cambia:**

<div class="emoji-list">

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Errores en tiempo de ejecución</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Datos incorrectos mostrados</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Reconstrucciones inesperadas</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Memory leaks</li>
</ul>

</div>

## Patrón Correcto

✅ Todas las llamadas watch ocurren en el mismo orden cada vez:

<<< @/../code_samples/lib/watch_it/watch_ordering_good_example.dart#example

**Por qué esto es correcto:**
- Línea 17: Siempre observa `todos`
- Línea 20: Siempre observa `isLoading`
- Línea 23-24: Siempre crea y observa `counter`
- El orden nunca cambia, incluso cuando los datos se actualizan

## Violaciones Comunes

### ❌️ Llamadas Watch Condicionales

El error más común es poner llamadas watch dentro de declaraciones condicionales:

<<< @/../code_samples/lib/watch_it/watch_ordering_bad_example.dart#example

**Por qué esto falla:**
- Cuando `show` es false: observa [showDetails, isLoading]
- Cuando `show` es true: observa [showDetails, todos]
- ¡Orden cambia = error!

### ❌️ Watch Dentro de Loops

<<< @/../code_samples/lib/watch_it/watch_ordering_patterns.dart#watch_inside_loops_wrong

### ❌️ Watch en Callbacks

<<< @/../code_samples/lib/watch_it/watch_ordering_patterns.dart#watch_in_callbacks_wrong

## Excepciones Seguras a la Regla

::: tip Entender Cuándo los Condicionales Son Seguros
La regla de ordenamiento solo importa cuando los watches **pueden o no ser llamados en la MISMA ruta de ejecución**.

- **Watches condicionales al final** - seguros porque no hay watches después
- **Returns tempranos** - siempre seguros porque crean rutas de ejecución separadas
:::


### ✅ Watches Condicionales al FINAL

Los watches condicionales son **perfectamente seguros** cuando son los últimos watches en tu build:

```dart
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Estos watches siempre se ejecutan en el mismo orden
    final todos = watchValue((TodoManager m) => m.todos);
    final isLoading = watchValue((TodoManager m) => m.isLoading);

    // ✅ Watch condicional al FINAL - ¡perfectamente seguro!
    if (showDetails) {
      final details = watchValue((TodoManager m) => m.selectedDetails);
      return DetailView(details);
    }

    return ListView(/* ... */);
  }
}
```

**Por qué esto es seguro:**
- Los primeros dos watches siempre se ejecutan en el mismo orden
- El watch condicional es el ¡ÚLTIMO - no hay watches subsiguientes que interrumpir
- En reconstrucción: se mantiene el mismo orden

### ✅ Returns Tempranos Siempre Son Seguros

Los returns tempranos no afectan el orden de watch porque los watches después de ellos nunca se llaman:

```dart
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final isLoading = watchValue((DataManager m) => m.isLoading);

    // ✅ Return temprano - ¡completamente seguro!
    if (isLoading) {
      return CircularProgressIndicator();
    }

    // Este watch solo se ejecuta cuando NO está cargando
    final data = watchValue((DataManager m) => m.data);

    if (data.isEmpty) {
      return Text('No data');
    }

    return ListView(/* ... */);
  }
}
```

**Por qué esto es seguro:**
- Los watches después de returns tempranos simplemente nunca se ejecutan
- No participan en el mecanismo de ordenamiento
- No es posible interrupción del orden

**Principio clave:** El peligro son los watches que **pueden o no ser llamados** en la MISMA ruta de construcción SEGUIDOS por otros watches. Los returns tempranos crean rutas de ejecución separadas, por lo que los watches después de ellos no son parte del ordenamiento para esa ruta.

## Patrones Condicionales Seguros

✅ Llama a TODOS los watches primero, LUEGO usa condiciones:

<<< @/../code_samples/lib/watch_it/conditional_watch_safe_example.dart#example

**Patrón:**
1. Llama a todas las funciones watch en la parte superior de `build()`
2. LUEGO usa lógica condicional con los valores
3. El orden se mantiene consistente

### Ejemplos de Patrones Seguros

<<< @/../code_samples/lib/watch_it/watch_ordering_patterns.dart#safe_pattern_conditional

<<< @/../code_samples/lib/watch_it/watch_ordering_patterns.dart#safe_pattern_list_iteration

## Resolución de Problemas

### Error: "Watch ordering violation detected!"

**Mensaje de error completo:**
```
Watch ordering violation detected!

You have conditional watch calls (inside if/switch statements) that are
causing watch_it to retrieve the wrong objects on rebuild.

Fix: Move ALL conditional watch calls to the END of your build method.
Only the LAST watch call can be conditional.
```

**Qué sucedió:**
- Tienes un watch dentro de una declaración `if`
- Este watch está **seguido por otros watches**
- En la reconstrucción, la condición cambió, causando que watch_it intente recuperar el tipo incorrecto en esa posición
- Se lanzó un TypeError al intentar hacer cast de la entrada watch

**Solución:**
1. Mueve los watches condicionales al FINAL de tu método build, O
2. Haz que todos los watches sean incondicionales y usa los valores condicionalmente en su lugar

**Tip:** Llama a `enableTracing()` en tu método build para ver las ubicaciones exactas de fuente de las declaraciones watch en conflicto.

## Lista de Verificación de Mejores Prácticas

✅ **HACER:**
- Llamar a todos los watches en la parte superior de `build()` cuando sea posible
- Usar llamadas watch incondicionales para watches que necesitan ejecutarse en todas las rutas
- Almacenar valores en variables, usar variables condicionalmente
- Observar la lista completa, iterar sobre valores
- Usar watches condicionales al final (después de todos los otros watches)
- Usar returns tempranos libremente - siempre son seguros

❌️ **NO HACER:**
- Poner watches en declaraciones `if` **cuando estén seguidos por otros watches**
- Poner watches en loops
- Poner watches en callbacks

## Avanzado: Por Qué Esto Sucede

`watch_it` usa una variable global `_watchItState` que rastrea:
- El widget actual siendo construido
- Índice de la llamada watch actual
- Lista de suscripciones watch previas

Cuando llamas a `watch()`:
1. `watch_it` incrementa el índice
2. Verifica si la suscripción en ese índice existe
3. Si sí, la reutiliza
4. Si no, crea una nueva suscripción

Si el orden cambia:
- El índice 0 espera la suscripción A, obtiene la suscripción B
- Las suscripciones se filtran o se mezclan
- Todo se rompe

Esto es similar a las reglas de React Hooks por la misma razón.

## Ver También

- [Getting Started](/documentation/watch_it/getting_started.md) - Uso básico de `watch_it`
- [Watch Functions](/documentation/watch_it/watch_functions.md) - Todas las funciones watch
- [Best Practices](/documentation/watch_it/best_practices.md) - Patrones generales
- [Debugging & Troubleshooting](/documentation/watch_it/debugging_tracing.md) - Problemas comunes
