# Restricciones de Command

Controla cuándo los commands pueden ejecutarse usando condiciones reactivas. Las restricciones permiten **conexión declarativa del comportamiento de commands** - conecta commands al estado de la aplicación o entre sí, y automáticamente se habilitan/deshabilitan basándose en esas condiciones.

**Beneficios clave:**
- **Coordinación reactiva** - Los commands responden a cambios de estado automáticamente
- **Dependencias declarativas** - Encadena commands sin orquestación manual
- **Actualizaciones de UI automáticas** - `canRun` refleja restricciones instantáneamente
- **Lógica centralizada** - Sin verificaciones `if` dispersas por tu código

## Resumen

Los commands pueden ser condicionalmente habilitados o deshabilitados usando el parámetro `restriction`, que acepta un `ValueListenable<bool>`. Esto permite que las restricciones **cambien dinámicamente** después de que el command sea creado - el command automáticamente responde a cambios de estado.

**Concepto clave:** Cuando el valor actual de la restricción es `true`, el command está **deshabilitado**

```dart
Command.createAsyncNoParam<List<Todo>>(
  () => api.fetchTodos(),
  initialValue: [],
  restriction: isLoggedIn.map((logged) => !logged), // deshabilitado cuando NO está logueado
);
```

Cualquier cambio de restricción se refleja en la propiedad `canRun` del command con esta fórmula: `canRun = !isRunning && !restriction`

::: tip Integración de UI
Debido a que `canRun` automáticamente refleja tanto el estado de ejecución como las restricciones, es ideal para habilitar/deshabilitar elementos de UI. Solo observa `canRun` y tus botones automáticamente se habilitan/deshabilitan cuando las condiciones cambian - no se necesita tracking manual de estado.
:::

## Restricción Básica con ValueNotifier

El patrón más común es restringir basándose en estado de aplicación:

<<< @/../code_samples/lib/command_it/restriction_example.dart#example

**Cómo funciona:**
1. Crea un `ValueNotifier<bool>` para trackear estado (`isLoggedIn`)
2. Mapéalo a lógica de restricción: `!logged` significa "restringir cuando NO está logueado"
3. El command automáticamente actualiza la propiedad `canRun`
4. Usa `watchValue()` para observar `canRun` en tu widget
5. El botón automáticamente se deshabilita cuando `canRun` es false

**Importante:** El parámetro restriction espera `ValueListenable<bool>` donde `true` significa "deshabilitado". Porque es un `ValueListenable`, la restricción puede cambiar en cualquier momento - el command automáticamente reacciona y actualiza `canRun` acordemente.

## Encadenando Commands via isRunningSync

Prevén que commands se ejecuten mientras otros commands se ejecutan:

<<< @/../code_samples/lib/command_it/restriction_chaining_example.dart#example

**Cómo funciona:**
1. `saveCommand` usa `loadCommand.isRunningSync` como restricción
2. Mientras carga, `saveCommand` no puede ejecutarse
3. `updateCommand` usa `combineLatest` para combinar ambos estados de ejecución
4. Update está deshabilitado si CUALQUIERA de load O save está ejecutándose
5. Demuestra combinar múltiples restricciones con operadores de listen_it

**¿Por qué isRunningSync?**
- `isRunning` se actualiza asíncronamente para evitar condiciones de carrera en rebuilding de UI
- `isRunningSync` se actualiza inmediatamente
- Previene condiciones de carrera en restricciones
- Usa `isRunning` para UI, `isRunningSync` para restricciones

## Propiedad canRun

`canRun` automáticamente combina estado de ejecución y restricciones:

```dart
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final canRun = watchValue((MyManager m) => m.command.canRun);

    return ElevatedButton(
      onPressed: canRun ? di<MyManager>().command.run : null,
      child: Text('Ejecutar'),
    );
  }
}
```

**canRun es true cuando:**
- El command NO está ejecutándose (`!isRunning`)
- Y la restricción es false (`!restriction`)

Esto es más conveniente que verificar manualmente ambas condiciones.

## Patrones de Restricción

### Restricción Basada en Autenticación

```dart
final isAuthenticated = ValueNotifier<bool>(false);

late final dataCommand = Command.createAsyncNoParam<Data>(
  () => api.fetchSecureData(),
  initialValue: Data.empty(),
  restriction: isAuthenticated.map((auth) => !auth), // deshabilitado cuando no autenticado
);
```

### Restricción Basada en Validación

```dart
final formValid = ValueNotifier<bool>(false);

late final submitCommand = Command.createAsync<FormData, void>(
  (data) => api.submit(data),
  restriction: formValid.map((valid) => !valid), // deshabilitado cuando inválido
);
```

### Múltiples Condiciones

Usa operadores de `ValueListenable` para combinar restricciones:

```dart
final isOnline = ValueNotifier<bool>(true);
final hasPermission = ValueNotifier<bool>(false);

late final syncCommand = Command.createAsyncNoParam<void>(
  () => api.sync(),
  // Deshabilitado cuando offline O sin permiso
  restriction: isOnline.combineLatest(
    hasPermission,
    (online, permission) => !online || !permission,
  ),
);
```

## Restricciones Temporales

Restringe commands durante operaciones específicas:

```dart
class DataManager {
  final isSyncing = ValueNotifier<bool>(false);

  late final deleteCommand = Command.createAsync<String, void>(
    (id) => api.delete(id),
    // No puede eliminar mientras sincroniza
    restriction: isSyncing,
  );

  Future<void> sync() async {
    isSyncing.value = true;
    try {
      await api.syncAll();
    } finally {
      isSyncing.value = false;
    }
  }
}
```

::: tip Aún Más Elegante
Si implementas `sync()` como un command también, puedes usar su `isRunningSync` directamente como restricción - no necesitas gestionar `isSyncing` manualmente. Ver el ejemplo de [Encadenando Commands](#encadenando-commands-via-isrunningsync) arriba.
:::

## Acciones Alternativas con ifRestrictedRunInstead

Cuando un command está restringido, podrías querer tomar una acción alternativa en lugar de silenciosamente no hacer nada. El parámetro `ifRestrictedRunInstead` proporciona un handler de fallback que se ejecuta cuando el command está restringido.

**Casos de uso comunes:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Mostrar diálogo de login cuando el usuario necesita autenticación</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Mostrar mensajes de error explicando por qué la acción no puede realizarse</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Loguear eventos de analytics para intentos restringidos</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Navegar a una pantalla diferente o mostrar un modal</li>
</ul>

<<< @/../code_samples/lib/command_it/restriction_run_instead_example.dart#example

**Cómo funciona:**

1. El handler recibe el parámetro que fue pasado al command
2. Se llama solo cuando `restriction` es `true` (command está deshabilitado)
3. La función envuelta original NO se ejecuta
4. Úsalo para feedback al usuario o flujos alternativos

::: tip Acceso a Parámetros
El handler `ifRestrictedRunInstead` recibe el mismo parámetro que habría sido pasado a la función envuelta. Esto te permite proporcionar feedback consciente del contexto (ej., "Por favor inicia sesión para buscar '{query}'").

**Commands NoParam:** Para commands NoParam (`createAsyncNoParam`, `createSyncNoParam`), el handler `ifRestrictedRunInstead` no tiene parámetro: `void Function()` en lugar de `RunInsteadHandler<TParam>`.
:::

## Restricción vs Verificaciones Manuales

**❌️ Sin restricciones (verificaciones manuales):**

```dart
void handleSave() {
  if (!isLoggedIn.value) return; // Verificación manual
  if (command.isRunning.value) return; // Verificación manual
  command.run();
}
```

**✅ Con restricciones (automático):**

```dart
late final command = Command.createAsync<Data, void>(
  (data) => api.save(data),
  restriction: isLoggedIn.map((logged) => !logged),
);

// UI automáticamente deshabilita cuando está restringido
class SaveWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final canRun = watchValue((MyManager m) => m.command.canRun);

    return ElevatedButton(
      onPressed: canRun ? () => di<MyManager>().command(data) : null,
      child: Text('Guardar'),
    );
  }
}
```

**Beneficios:**
- UI automáticamente refleja estado
- No se necesitan verificaciones manuales
- Lógica centralizada
- Reactivo a cambios de estado

## Errores Comunes

### ❌️ Invertir la lógica de restricción

```dart
// MAL: restriction espera true = deshabilitado
restriction: isLoggedIn, // ¡deshabilitado cuando está logueado (al revés)!
```

```dart
// CORRECTO: negar la condición
restriction: isLoggedIn.map((logged) => !logged), // deshabilitado cuando NO está logueado
```

### ❌️ Usar isRunning para restricciones

```dart
// MAL: actualización async puede causar condiciones de carrera
restriction: otherCommand.isRunning,
```

```dart
// CORRECTO: usar versión síncrona
restriction: otherCommand.isRunningSync,
```

### ❌️ Olvidar disponer fuentes de restricción

```dart
class Manager {
  final customRestriction = ValueNotifier<bool>(false);

  late final command = Command.createAsync<Data, void>(
    (data) => api.save(data),
    restriction: customRestriction,
  );

  void dispose() {
    command.dispose();
    customRestriction.dispose(); // ¡No olvides esto!
  }
}
```

## Ver También

- [Fundamentos de Command](/es/documentation/command_it/command_basics) — Creando y ejecutando commands
- [Propiedades del Command](/es/documentation/command_it/command_properties) — canRun, isRunning, isRunningSync
- [Manejo de Errores (Error Handling)](/es/documentation/command_it/error_handling) — Manejando errores de runtime
- [Operadores de listen_it](/es/documentation/listen_it/operators/overview) — Operadores de ValueListenable
