# Actualizaciones Optimistas

Construye UIs responsivas que se actualizan instantáneamente mientras las operaciones en background se completan. command_it soporta actualizaciones optimistas con dos enfoques: un patrón simple de listener de errores para aprender y casos directos, y `UndoableCommand` para rollback automático en escenarios complejos.

**Beneficios Clave:**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">⚡ <strong>Actualizaciones de UI instantáneas</strong> - Actualiza el estado inmediatamente, sincroniza en background</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">🔄 <strong>Recuperación de errores elegante</strong> - Restaura estado anterior cuando las operaciones fallan</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">🎯 <strong>Elige tu enfoque</strong> - Patrón manual simple o UndoableCommand automático</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">📚 <strong>Complejidad progresiva</strong> - Empieza simple, mejora cuando lo necesites</li>
</ul>

## ¿Por Qué Actualizaciones Optimistas?

Las actualizaciones síncronas tradicionales se sienten lentas:

```dart
// ❌ Tradicional: El usuario espera la respuesta del servidor
Future<void> toggleBookmark(String postId, bool isBookmarked) async {
  // UI muestra spinner de carga...
  await api.updateBookmark(postId, !isBookmarked); // El usuario espera 500ms
  // Finalmente actualiza UI
  bookmarkedPosts.value = !isBookmarked;
}
```

Las actualizaciones optimistas se sienten instantáneas:

```dart
// ✅ Optimista: La UI se actualiza inmediatamente
Future<void> toggleBookmark(String postId, bool isBookmarked) async {
  // Guarda estado actual en caso de que necesitemos rollback
  final previousState = isBookmarked;

  // ¡Actualiza UI inmediatamente - se siente instantáneo!
  bookmarkedPosts.value = !isBookmarked;

  try {
    // Sincroniza con servidor en background
    await api.updateBookmark(postId, !isBookmarked);
  } catch (e) {
    // Rollback en fallo
    bookmarkedPosts.value = previousState;
    showSnackBar('Error al actualizar marcador');
  }
}
```

## Enfoque Simple con Listeners de Error

Antes de sumergirnos en `UndoableCommand`, entendamos el patrón fundamental. Este enfoque te da control total y te ayuda a entender qué está pasando internamente.

### Patrón Básico de Toggle

La idea clave: cuando ocurre un error, **invierte el valor actual** para restaurar el estado anterior, no simplemente recargues del servidor.

Este ejemplo muestra un modelo `Post` con un command de marcador embebido:

<<< @/../code_samples/lib/command_it/optimistic_simple_toggle_example.dart#example

**¿Por qué invertir en lugar de recargar?**

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ No se necesita round-trip al servidor</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Preserva otros cambios concurrentes</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Rollback instantáneo</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Requiere conocer la operación inversa</li>
</ul>

### Patrón de Eliminación

Para eliminaciones, captura el item antes de eliminarlo. Este ejemplo usa [`MapNotifier`](/es/documentation/listen_it/collections/map_notifier) para almacenar todos por ID:

<<< @/../code_samples/lib/command_it/optimistic_simple_delete_example.dart#example

::: tip Pasando el Objeto
Nota que el command acepta `Todo` como parámetro, no solo el ID. Esto permite que el handler de error acceda al todo eliminado via `error.paramData` para restauración. Si solo pasas un ID, necesitarás capturar el objeto en un campo antes de la eliminación (como el patrón `_lastDeleted`) - en cuyo caso `UndoableCommand` sería un mejor enfoque.
:::

### Cuándo Usar el Enfoque Simple

**Bueno para:**
- Aprender actualizaciones optimistas
- Toggles simples (marcadores, likes, archivados)
- Eliminaciones simples
- Cuando quieres control explícito
- Prototipado y entender el patrón

**Limitaciones:**
- Manejo de errores manual para cada command
- Necesitas trackear valores anteriores para estado complejo
- Más duplicación de código entre commands
- Fácil olvidar manejo de errores

## Avanzado: Auto-Rollback con UndoableCommand

Para estado complejo o múltiples operaciones, `UndoableCommand` automatiza el patrón de arriba. Captura estado antes de la ejecución y lo restaura automáticamente en fallo - no se necesita manejo de errores manual.

La restauración automática de estado en fallo está habilitada por defecto:

<<< @/../code_samples/lib/command_it/optimistic_undoable_delete_example.dart#example

**Flujo de Ejecución:**

1. **Durante ejecución**: Tu función se ejecuta y llama `stack.push()` para guardar snapshots de estado
2. **En éxito**: Los snapshots de estado permanecen en el undo stack para potencial undo manual
3. **En fallo** (automático por defecto):
   - El handler `undo` se llama automáticamente con `(stack, reason)`
   - Tu handler de undo llama `stack.pop()` para restaurar el estado anterior
   - El error aún se propaga a los handlers de error

### Patrones de UndoableCommand

#### Patrón 1: Toggle de Estado con Objetos Inmutables

Cuando trabajas con objetos inmutables, el undo stack automáticamente preserva el estado anterior:

<<< @/../code_samples/lib/command_it/optimistic_undoable_toggle_example.dart#example

Como `Todo` es inmutable, hacer push al stack captura un snapshot completo. No necesitas clonar manualmente - la inmutabilidad garantiza que el estado guardado no cambiará.

#### Patrón 2: Operaciones Multi-Paso

Para operaciones con múltiples pasos donde cualquier fallo debe hacer rollback de todo:

<<< @/../code_samples/lib/command_it/optimistic_multistep_example.dart#example

## Undo Manual

`UndoableCommand` soporta operaciones de undo manual llamando al método `undo()` directamente. Deshabilita el rollback automático cuando quieras controlar el undo manualmente:

<<< @/../code_samples/lib/command_it/optimistic_manual_undo_example.dart#example

::: tip Solo Undo Manual
UndoableCommand actualmente solo soporta undo, no redo. El método `undo()` hace pop del último estado del undo stack y lo restaura. Para funcionalidad de redo, necesitarías implementar tu propio redo stack.
:::

## Eligiendo un Enfoque

Ambos enfoques tienen su lugar - elige basándote en tus necesidades y preferencias, no en dogma.

### Usa Listeners de Error Simples Cuando:

- **Aprendiendo**: Quieres entender actualizaciones optimistas desde los principios básicos
- **Operaciones simples**: Toggles o eliminaciones simples donde el inverso es obvio
- **Control explícito**: Prefieres ver exactamente qué pasa en error
- **Prototipado**: Experimentos rápidos antes de comprometerte con un patrón
- **Casos edge**: Lógica de rollback específica que no encaja en el patrón estándar

### Usa UndoableCommand Cuando:

- **Estado complejo**: Múltiples campos cambian juntos y deben hacer rollback atómicamente
- **Consistencia**: Quieres el mismo patrón de rollback en todos los commands
- **Menos boilerplate**: Cansado de escribir listeners de error para cada command
- **Proyectos de equipo**: Estandarizar en rollback automático para prevenir manejo de errores olvidado
- **Operaciones multi-paso**: Flujos de trabajo complejos donde cualquier paso puede fallar

::: tip Enfoque Pragmático
No hay respuesta "correcta" - ambos patrones son válidos. Empieza con el enfoque simple para entender la mecánica, luego mejora a `UndoableCommand` cuando el patrón manual se vuelva tedioso. Incluso puedes mezclar enfoques en la misma app: usa listeners simples para toggles directos y `UndoableCommand` para operaciones complejas.

Para contexto más profundo sobre evitar consejos de programación dogmáticos, ver el artículo de Thomas Burkhart: [Understanding the Problems with Dogmatic Programming Advice](https://blog.burkharts.net/understanding-the-problems-with-dogmatic-programming-advice)
:::

## Cuándo Usar Actualizaciones Optimistas

**Buenos candidatos para actualizaciones optimistas:**

- Operaciones de toggle (completar tarea, like a item, seguir usuario)
- Operaciones de eliminación (remover item, limpiar notificación)
- Ediciones simples (renombrar, actualizar campo único)
- Cambios de estado (marcar como leído, archivar item)

**No recomendado para:**

- Operaciones donde el fallo es común (errores de validación)
- Formularios complejos con múltiples pasos de validación
- Operaciones donde el servidor determina el resultado (flujos de aprobación)
- Transacciones financieras que requieren confirmación

## Manejo de Errores (Error Handling)

El rollback automático funciona con el sistema de manejo de errores de command_it:

<<< @/../code_samples/lib/command_it/optimistic_error_handling_example.dart#example

El error aún se propaga a los handlers de error, así que puedes mostrar feedback apropiado al usuario.

## Ver También

- [Tipos de Command - Commands Undoable](/es/documentation/command_it/command_types#commands-undoable) - Todos los métodos factory y detalles de API
- [Mejores Prácticas - Commands Undoable](/es/documentation/command_it/best_practices#patron-5-commands-undoable-con-rollback-automatico) - Más patrones y recomendaciones
- [Manejo de Errores (Error Handling)](/es/documentation/command_it/error_handling) - Cómo funcionan los errores con rollback automático
- [Keeping Widgets in Sync with Your Data](https://blog.burkharts.net/keeping-widgets-in-sync-with-your-data) - Post de blog original demostrando ambos patrones simple y UndoableCommand
