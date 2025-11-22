# Observando Múltiples Valores

Cuando tu widget necesita datos de múltiples `ValueListenables`, tienes varias estrategias para elegir. Cada enfoque tiene diferentes compromisos en términos de claridad de código, frecuencia de reconstrucción y rendimiento.

## Los Dos Enfoques Principales

### Enfoque 1: Llamadas Watch Separadas

Observa cada valor por separado - el widget se reconstruye cuando **CUALQUIER** valor cambia:

<<< @/../code_samples/lib/watch_it/multiple_values_separate_watches.dart#example

**Cuándo usar:**
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Los valores no están relacionados</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Lógica de UI simple</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Todos los valores son necesarios para el renderizado</li>
</ul>

**Comportamiento de reconstrucción:** El widget se reconstruye cuando **cualquiera** de los tres valores cambia.

### Enfoque 2: Combinación en la Capa de Datos

Combina múltiples valores usando operators de `listen_it` en tu manager - el widget se reconstruye solo cuando el **resultado combinado** cambia:

<<< @/../code_samples/lib/watch_it/multiple_values_combine_latest_form.dart#manager

<<< @/../code_samples/lib/watch_it/multiple_values_combine_latest_form.dart#widget

**Cuándo usar:**
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Los valores están relacionados/dependientes</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Necesitas un resultado computado</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Quieres reducir reconstrucciones</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Lógica de validación compleja</li>
</ul>

**Comportamiento de reconstrucción:** El widget se reconstruye solo cuando `isValid` cambia, no cuando los valores individuales de email o password cambian (a menos que afecte la validez).

## Patrón: Validación de Formularios con combineLatest

Uno de los casos de uso más comunes para combinar valores es la validación de formularios:

**El Problema:** Quieres habilitar un botón de envío solo cuando TODOS los campos del formulario son válidos.

**Sin combinar:** El widget se reconstruye en cada pulsación de tecla en cualquier campo, incluso si el estado de validación no cambia.

**Con combinación:** El widget se reconstruye solo cuando el estado general de validación cambia (inválido ↔ válido o viceversa).

Ver el ejemplo de formulario anterior para el patrón completo.

## Patrón: Combinando 3+ Valores

Para más de 2 valores, usa `combineLatest3`, `combineLatest4`, hasta `combineLatest6`:

<<< @/../code_samples/lib/watch_it/multiple_values_combine_latest3_user.dart#manager

<<< @/../code_samples/lib/watch_it/multiple_values_combine_latest3_user.dart#widget

**Beneficio clave:** Los tres valores (firstName, lastName, avatarUrl) pueden cambiar independientemente, pero el widget solo se reconstruye cuando el objeto computado `UserDisplayData` cambia.

## Patrón: Usar mergeWith para Fuentes de Eventos

Cuando tienes múltiples fuentes de eventos del **mismo tipo** que deberían disparar la misma acción, usa `mergeWith`:

<<< @/../code_samples/lib/watch_it/multiple_values_merge_with_events.dart#manager

<<< @/../code_samples/lib/watch_it/multiple_values_merge_with_events.dart#widget

**Diferencia con combineLatest:**
- `combineLatest`: Combina **tipos diferentes** en un nuevo valor computado
- `mergeWith`: Fusiona fuentes del **mismo tipo** en un solo stream de eventos

## Comparación: Cuándo Usar Cada Enfoque

Veamos ambos enfoques lado a lado con la misma clase Manager:

<<< @/../code_samples/lib/watch_it/multiple_values_comparison_example.dart#manager

<<< @/../code_samples/lib/watch_it/multiple_values_comparison_example.dart#separate_watches

<<< @/../code_samples/lib/watch_it/multiple_values_comparison_example.dart#combined_watch

**Pruébalo:** Cuando incrementas value1 de -1 a 0:
- `SeparateWatchesWidget` se reconstruye (el valor cambió)
- `CombinedWatchWidget` **no se reconstruye** (ambos todavía no son positivos)

### Tabla de Decisión

| Escenario | Usar Watches Separados | Usar Combinación |
|----------|---------------------|---------------|
| Valores no relacionados (nombre, email, avatar) | ✅ Más simple | ❌️ Innecesario |
| Resultado computado (firstName + lastName) | ❌️ Reconstruye innecesariamente | ✅ Mejor |
| Validación de formularios (¿todos los campos válidos?) | ❌️ Reconstruye en cada tecla | ✅ Mucho mejor |
| Valores independientes todos necesarios en UI | ✅ Natural | ❌️ Más complejo |
| Sensible al rendimiento con cambios frecuentes | ❌️ Más reconstrucciones | ✅ Menos reconstrucciones |

## watchIt() vs Múltiples watchValue()

La elección entre `watchIt()` en un `ChangeNotifier` y múltiples llamadas `watchValue()` depende de tus patrones de actualización.

### Enfoque 1: watchIt() - Observar ChangeNotifier Completo

<<< @/../code_samples/lib/watch_it/multiple_values_watch_it_vs_watch_value.dart#watch_it_approach

**Cuándo usar:**
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Necesitas **la mayoría/todas** las propiedades en tu UI</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Las propiedades se **actualizan juntas** (actualizaciones por lotes)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Diseño simple - una llamada notifyListeners() actualiza todo</li>
</ul>

**Compromiso:** El widget se reconstruye incluso si solo una propiedad cambia.

### Enfoque 2: Múltiples ValueNotifiers

<<< @/../code_samples/lib/watch_it/multiple_values_watch_it_vs_watch_value.dart#better_design

**Cuándo usar:**
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Las propiedades se actualizan **independientemente** y **frecuentemente**</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Solo muestras un **subconjunto** de propiedades en cada widget</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Quieres control granular sobre las reconstrucciones</li>
</ul>

**Compromiso:** Si múltiples propiedades se actualizan juntas, obtienes múltiples reconstrucciones. En tales casos:
- **Mejor: Usa ChangeNotifier en su lugar** y llama `notifyListeners()` una vez después de todas las actualizaciones
- **Alternativa: Usa `watchPropertyValue()`** para reconstruir solo cuando el VALOR específico de la propiedad cambia, no en cada llamada notifyListeners

### Enfoque 3: watchPropertyValue() - Actualizaciones Selectivas

Si necesitas observar un ChangeNotifier pero solo te importan cambios específicos de valor de propiedad:

```dart
class SettingsWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    // Solo se reconstruye cuando el VALOR de darkMode cambia
    // (no en cada llamada notifyListeners)
    final darkMode = watchPropertyValue((UserSettings s) => s.darkMode);

    return Switch(
      value: darkMode,
      onChanged: (value) => di<UserSettings>().setDarkMode(value),
    );
  }
}
```

**Cuándo usar:**
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ ChangeNotifier tiene muchas propiedades</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Solo necesitas una o pocas propiedades</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Otras propiedades cambian frecuentemente pero no te importan</li>
</ul>

**Beneficio clave:** Se reconstruye solo cuando el **valor** de `s.darkMode` cambia, ignorando notificaciones sobre cambios de otras propiedades.

## Seguridad: Caché Automático en Funciones Selectoras

::: tip Seguro Usar Operators en Selectores
Puedes usar de forma segura operators de `listen_it` como `combineLatest()` dentro de funciones selectoras de `watchValue()`, `watchStream()`, `watchFuture()`, y otras funciones watch. El valor predeterminado `allowObservableChange: false` asegura que la cadena de operator se crea una vez y se cachea.
:::

<<< @/../code_samples/lib/watch_it/multiple_values_inline_combine_safe.dart#safe_inline_combine

**Cómo funciona (predeterminado `allowObservableChange: false`):**
1. Primera construcción: El selector se ejecuta, crea la cadena `combineLatest()`
2. El resultado se cachea automáticamente
3. Construcciones subsiguientes: Se reutiliza la cadena cacheada
4. Se lanza excepción si la identidad del observable cambia
5. Sin memory leaks, sin creación repetida de cadenas

**Cuándo establecer `allowObservableChange: true`:**
Solo cuando el observable genuinamente necesita cambiar entre construcciones:

<<< @/../code_samples/lib/watch_it/multiple_values_inline_combine_safe.dart#when_to_use_allow_change

**Importante:** Establecer `allowObservableChange: true` innecesariamente causa que el selector se ejecute en **cada** construcción, creando nuevas cadenas de operators cada vez - ¡un memory leak!

## Consideraciones de Rendimiento

### Frecuencia de Reconstrucción

**Watches separados:**
```dart
final value1 = watchValue((M m) => m.value1);  // Reconstruye en cambio de value1
final value2 = watchValue((M m) => m.value2);  // Reconstruye en cambio de value2
final sum = value1 + value2;                    // Computado en build
```
- Reconstrucciones: 2 (una por cada cambio de valor)
- ¡Incluso si `sum` no cambia!

**Watch combinado:**
```dart
final sum = watchValue(
  (M m) => m.value1.combineLatest(m.value2, (v1, v2) => v1 + v2),
);
```
- Reconstrucciones: Solo cuando `sum` realmente cambia
- Menos reconstrucciones = mejor rendimiento

### Cuándo Combinar Realmente Ayuda

Combinar proporciona beneficios reales cuando:
1. **Los valores cambian frecuentemente** pero el resultado cambia raramente
2. **Computación compleja** desde múltiples fuentes
3. **Validación** - muchos campos, resultado binario (válido/inválido)

Combinar proporciona beneficio mínimo cuando:
1. Todos los valores siempre se necesitan en la UI
2. Los valores raramente cambian
3. Las actualizaciones de UI son baratas

## Errores Comunes

### ❌️ Crear Operators Fuera del Selector

<<< @/../code_samples/lib/watch_it/multiple_values_antipatterns.dart#antipattern_create_outside_selector

**Problema:** ¡Crea nueva cadena en **cada** construcción - memory leak!

**Solución:** Crea dentro del selector:

<<< @/../code_samples/lib/watch_it/multiple_values_antipatterns.dart#correct_create_in_selector

### ❌️ Usar allowObservableChange Innecesariamente

<<< @/../code_samples/lib/watch_it/multiple_values_antipatterns.dart#antipattern_unnecessary_allow_change

**Problema:** El selector se ejecuta en cada construcción, creando nuevas cadenas.

**Solución:** Elimina `allowObservableChange: true` a menos que realmente se necesite.

### ❌️ Usar Getter para Valores Combinados

<<< @/../code_samples/lib/watch_it/multiple_values_antipatterns.dart#antipattern_create_in_data_layer

**Problema:** El getter crea nueva cadena en cada acceso.

**Solución:** Usa `late final` para crear una vez.

## Puntos Clave

✅ **Watches separados** son simples y funcionan bien para valores no relacionados todos necesarios en UI

✅ **Combinar en la capa de datos** reduce reconstrucciones cuando se computa desde múltiples fuentes

✅ Usa **`combineLatest()`** para valores dependientes con resultados computados

✅ Usa **`mergeWith()`** para múltiples fuentes de eventos del mismo tipo

✅ **Seguro usar operators en selectores** - caché automático con predeterminado `allowObservableChange: false`

✅ **Nunca establezcas `allowObservableChange: true`** a menos que el observable genuinamente cambie

✅ **Crea observables combinados con `late final`** en managers, no getters

**Siguiente:** Aprende sobre [observar streams y futures](/documentation/watch_it/watching_streams_and_futures.md).

## Ver También

- [More Watch Functions](/documentation/watch_it/more_watch_functions.md) - Detalles de funciones watch individuales
- [listen_it Operators](/documentation/listen_it/operators/overview.md) - Guía completa de operators de combinación
- [combineLatest Documentation](/documentation/listen_it/operators/combine.md) - Uso detallado de combineLatest
- [Best Practices](/documentation/watch_it/best_practices.md) - Patrones de optimización de rendimiento
