# Tipos de Command

Aprende sobre el patrón de funciones factory de `command_it` para crear commands. Entender este patrón hace fácil elegir la factory correcta para tus necesidades.

## ¿Por Qué Funciones Factory?

Los Commands usan **funciones factory estáticas** en lugar de un solo constructor porque:

1. **Seguridad de tipos** - Cada factory acepta exactamente la firma de función correcta:
   - `createAsync<String, List<Todo>>` toma `Future<List<Todo>> Function(String)`
   - `createAsyncNoParam<List<Todo>>` toma `Future<List<Todo>> Function()`
   - Sin riesgo de pasar el tipo de función incorrecto

2. **Simplicidad de implementación** - Diferentes firmas de función (0-2 parámetros, retornos void/no-void) requerirían múltiples parámetros de función opcionales en un constructor, haciéndolo propenso a errores y confuso

3. **Intención clara** - El nombre de la factory te dice exactamente qué estás creando:
   - `createAsyncNoParam<List<Todo>>` es más claro que `Command<void, List<Todo>>()`

## El Patrón de Nomenclatura

Las 12 funciones factory siguen una fórmula simple:

```
create + [Sync|Async|Undoable] + [NoParam] + [NoResult]
```

**Cómo leer los nombres:**
- **Sync/Async/Undoable** - Qué tipo de command (siempre presente)
- **NoParam** - Si está presente, el command NO toma parámetros
- **NoResult** - Si está presente, el command retorna void
- **Partes omitidas** - Si "NoParam" o "NoResult" falta, esa característica ESTÁ presente

**Ejemplos:**

| Nombre de Factory | ¿Tiene Parámetro? | ¿Tiene Resultado? | Tipo |
|-------------------|-------------------|-------------------|------|
| `createAsync<TParam, TResult>` | ✅ Sí (TParam) | ✅ Sí (TResult) | Async |
| `createAsyncNoParam<TResult>` | ❌ No (void) | ✅ Sí (TResult) | Async |
| `createAsyncNoResult<TParam>` | ✅ Sí (TParam) | ❌ No (void) | Async |
| `createSyncNoParamNoResult` | ❌ No (void) | ❌ No (void) | Sync |
| `createUndoable<TParam, TResult, TUndoState>` | ✅ Sí (TParam) | ✅ Sí (TResult) | Undoable |

**Idea clave:** Si "NoParam" o "NoResult" aparece en el nombre, esa característica está AUSENTE. Si se omite, está PRESENTE.

::: tip Los Commands NoResult Aún Notifican a los Listeners
Aunque los commands NoResult retornan `void`, aún notifican a los listeners cuando completan exitosamente. Esto significa que puedes observarlos para disparar actualizaciones de UI, navegación u otros efectos secundarios.

```dart
final saveCommand = Command.createAsyncNoResult<Data>(
  (data) async => await api.save(data),
);

// Aún puedes escuchar la completación
saveCommand.listen((_, __) {
  showSnackbar('¡Guardado exitosamente!');
});

// O usar con watch_it
watchValue(saveCommand, (_, __) {
  // Se llama cuando save completa
});
```

Los Commands son `ValueListenable<TResult>` donde `TResult` es `void` para variantes NoResult - el valor no cambia, pero las notificaciones aún se disparan en la ejecución.
:::

## Referencia de Parámetros

Aquí está la firma completa de `createAsync<TParam, TResult>` - la función factory más común. Todas las otras factories comparten estos mismos parámetros (o un subconjunto):

```dart
static Command<TParam, TResult> createAsync<TParam, TResult>(
  Future<TResult> Function(TParam x) func, {
  required TResult initialValue,
  ValueListenable<bool>? restriction,
  RunInsteadHandler<TParam>? ifRestrictedRunInstead,
  bool includeLastResultInCommandResults = false,
  ErrorFilter? errorFilter,
  ErrorFilterFn? errorFilterFn,
  bool notifyOnlyWhenValueChanges = false,
  String? debugName,
})
```

**Parámetros requeridos:**

- **`func`** - La función async a envolver (parámetro posicional). Toma un parámetro de tipo `TParam` y retorna `Future<TResult>`
- **`initialValue`** - El valor inicial del command antes de la primera ejecución (parámetro nombrado requerido). Los Commands son `ValueListenable<TResult>` y necesitan un valor inmediatamente. **No disponible para commands void** (ver variantes NoResult abajo)

**Parámetros opcionales:**

- **`restriction`** - `ValueListenable<bool>` para habilitar/deshabilitar el command dinámicamente. Cuando es `true`, el command no puede ejecutarse. Ver [Restricciones](/es/documentation/command_it/restrictions)

- **`ifRestrictedRunInstead`** - Función alternativa llamada cuando el command está restringido (ej., mostrar diálogo de login). Ver [Restricciones](/es/documentation/command_it/restrictions)

- **`includeLastResultInCommandResults`** - Cuando es `true`, mantiene el último valor exitoso visible en `CommandResult.data` durante estados de ejecución y error. Por defecto es `false`. Ver [Command Results - includeLastResultInCommandResults](/es/documentation/command_it/command_results#includelastresultincommandresults) para explicación detallada y casos de uso

- **`errorFilter`/`errorFilterFn`** - Configura cómo se manejan los errores (handler local, handler global, o ambos). Ver [Manejo de Errores](/es/documentation/command_it/error_handling)

- **`notifyOnlyWhenValueChanges`** - Cuando es `true`, solo notifica a listeners si el valor realmente cambia. Por defecto notifica en cada ejecución

- **`debugName`** - Identificador para logging y debugging, incluido en mensajes de error

## Diferencias de Variantes

Las 12 funciones factory usan el mismo patrón de parámetros de arriba, con estas variaciones:

**Sync vs Async:**
- **Commands Sync** (`createSync*`):
  - Parámetro de función: `TResult Function(TParam)` (función regular)
  - Ejecutan inmediatamente
  - **Sin soporte de `isRunning`** (accederlo lanza una excepción)
- **Commands Async** (`createAsync*`):
  - Parámetro de función: `Future<TResult> Function(TParam)` (retorna Future)
  - Proporcionan tracking de `isRunning` durante la ejecución

**Variantes NoParam:**
- La firma de función **no tiene parámetro**: `Future<TResult> Function()` en lugar de `Future<TResult> Function(TParam)`
- **`ifRestrictedRunInstead` no tiene parámetro**: `void Function()` en lugar de `RunInsteadHandler<TParam>`

**Variantes NoResult:**
- La función retorna `void`: `Future<void> Function(TParam)` en lugar de `Future<TResult> Function(TParam)`
- **Sin parámetro `initialValue`** (commands void no necesitan valor inicial)
- **Sin parámetro `includeLastResultInCommandResults`** (nada que incluir)

**Commands Undoable:**
- Cubiertos en detalle en la sección de Commands Undoable abajo

## Commands Undoable

Los commands undoable extienden commands async con capacidad de deshacer. Mantienen un `UndoStack<TUndoState>` que almacena snapshots de estado, permitiéndote deshacer operaciones.

**Firma completa:**

```dart
static Command<TParam, TResult> createUndoable<TParam, TResult, TUndoState>(
  Future<TResult> Function(TParam, UndoStack<TUndoState>) func, {
  required TResult initialValue,
  required UndoFn<TUndoState, TResult> undo,
  bool undoOnExecutionFailure = true,
  ValueListenable<bool>? restriction,
  RunInsteadHandler<TParam>? ifRestrictedRunInstead,
  bool includeLastResultInCommandResults = false,
  ErrorFilter? errorFilter,
  ErrorFilterFn? errorFilterFn,
  bool notifyOnlyWhenValueChanges = false,
  String? debugName,
})
```

**Parámetros requeridos:**

- **`func`** - Tu función async que recibe **DOS parámetros**: el parámetro del command (`TParam`) Y el undo stack (`UndoStack<TUndoState>`) donde haces push de snapshots de estado (parámetro posicional)

- **`initialValue`** - El valor inicial del command antes de la primera ejecución (parámetro nombrado requerido)

- **`undo`** - Función handler llamada para realizar la operación de deshacer (parámetro nombrado requerido):
  ```dart
  typedef UndoFn<TUndoState, TResult> = FutureOr<TResult> Function(
    UndoStack<TUndoState> undoStack,
    Object? reason
  )
  ```
  Haz pop del estado del stack y restáuralo. Se llama cuando el usuario manualmente deshace o cuando `undoOnExecutionFailure: true` y la ejecución falla

**Parámetros opcionales:**

- **`undoOnExecutionFailure`** - Cuando es `true` (por defecto), automáticamente llama al handler de undo y restaura el estado si el command falla. Perfecto para actualizaciones optimistas que necesitan rollback en error

**Parámetros de tipo:**

- **`TParam`** - Tipo de parámetro del command (igual que commands regulares)
- **`TResult`** - Tipo de valor de retorno (igual que commands regulares)
- **`TUndoState`** - Tipo de snapshot de estado necesario para deshacer la operación

**Parámetros heredados:**

Todos los otros parámetros (`initialValue`, `restriction`, `errorFilter`, etc.) funcionan igual que en `createAsync` - ver la sección [Referencia de Parámetros](#referencia-de-parametros) arriba.

**Métodos adicionales:**

- **`undo()`** - Manualmente deshace la última operación llamando al handler de undo. El handler de undo recibe el `UndoStack` y puede hacer pop del estado para restaurar valores previos

**Ver también:**
- [Mejores Prácticas - Commands Undoable](/es/documentation/command_it/best_practices#patron-5-commands-undoable-con-rollback-automatico) para ejemplos prácticos
- [Manejo de Errores - Auto-Undo en Fallo](/es/documentation/command_it/error_handling#auto-undo-en-fallo) para patrones de recuperación de errores

## Ver También

- [Fundamentos de Command](/es/documentation/command_it/command_basics) - Ejemplos de uso detallados y patrones
- [Propiedades del Command](/es/documentation/command_it/command_properties) - Entendiendo el estado del command (value, isRunning, canRun, errors)
- [Mejores Prácticas](/es/documentation/command_it/best_practices) - Cuándo usar qué factory y patrones de producción
- [Manejo de Errores](/es/documentation/command_it/error_handling) - Estrategias de gestión de errores
- [Restricciones](/es/documentation/command_it/restrictions) - Patrones dinámicos de habilitar/deshabilitar commands
