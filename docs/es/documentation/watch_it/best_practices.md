# Mejores Prácticas

Patrones listos para producción, tips de rendimiento y estrategias de testing para aplicaciones `watch_it`.

## Patrones de Arquitectura

### Widgets Auto-Contenidos

Los widgets deberían acceder a sus dependencias directamente desde `get_it`, no vía parámetros del constructor.

**❌️ Malo - Pasar managers como parámetros:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#passing_managers_bad

**✅ Bueno - Acceder directamente:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#access_directly_good

**¿Por qué?** Los widgets auto-contenidos son:
- Más fáciles de testear (mock de `get_it`, no parámetros del constructor)
- Más fáciles de refactorizar
- No exponen dependencias internas
- Pueden acceder a múltiples servicios sin explosión de parámetros

### Separar Estado de UI del Estado de Negocio

**Estado de UI local** (entrada de formulario, expansión, selección):

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#local_ui_state

**Estado de negocio** (datos de API, estado compartido):

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#business_state

### Estado Reactivo Local con createOnce

Para estado reactivo local del widget que no necesita registro en `get_it`, combina `createOnce` con `watch`:

<<< @/../code_samples/lib/watch_it/watch_create_once_local_state.dart#example

**Cuándo usar este patrón:**
- El widget necesita su propio estado reactivo local
- El estado debería persistir a través de reconstrucciones (no recreado)
- El estado debería ser dispuesto automáticamente con el widget
- No quieres registrar en `get_it` (verdaderamente local)

**Beneficios clave:**
- `createOnce` crea el notifier una vez y lo dispone automáticamente
- `watch` se suscribe a cambios y dispara reconstrucciones
- No se necesita gestión manual de ciclo de vida

## Optimización de Rendimiento

### Observa Solo Lo Que Necesitas

Observa propiedades específicas, no objetos enteros. El enfoque depende de la estructura de tu manager:

**Para managers con propiedades ValueListenable** - usa `watchValue()`:

**❌️ Malo - Observar manager completo:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#watching_too_much_bad

**✅ Bueno - Observar propiedad ValueListenable específica:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#watch_specific_good

**Para managers ChangeNotifier** - usa `watchPropertyValue()` para reconstruir solo cuando un valor de propiedad específica cambia:

**❌️ Malo - Se reconstruye en cada llamada notifyListeners:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#rebuilds_on_every_settings_bad

**✅ Bueno - Se reconstruye solo cuando el valor de darkMode cambia:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#rebuilds_only_darkmode_good

### Dividir Widgets Grandes

No observes todo en un widget gigante. Divide en widgets más pequeños que observen solo lo que necesitan. Esto asegura que solo los widgets más pequeños se reconstruyan cuando sus datos cambien.

**❌️ Malo - Un widget observa todo:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#one_widget_watches_everything_bad

**✅ Bueno - Cada widget observa sus propios datos:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#split_widgets_good_dashboard

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#split_widgets_good_user_header

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#split_widgets_good_todo_list

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#split_widgets_good_settings_panel

### Constructores Const

::: tip Usa const con tus watching widgets
Los constructores const funcionan con todos los tipos de widget de `watch_it`: `WatchingWidget`, `WatchingStatefulWidget`, y widgets usando `WatchItMixin`. Flutter puede optimizar widgets const para mejor rendimiento de reconstrucción.
:::

## Testing

### Testea Lógica de Negocio Por Separado

Mantén tu lógica de negocio (managers, servicios) separada de los widgets y testéala independientemente:

**Unit test del manager:**
```dart
test('TodoManager filters completed todos', () {
  final manager = TodoManager();
  manager.addTodo('Task 1');
  manager.addTodo('Task 2');
  manager.todos[0].complete();

  expect(manager.completedTodos.length, 1);
  expect(manager.activeTodos.length, 1);
});
```

**Sin dependencias de Flutter = tests rápidos.**

### Testea Widgets con Dependencias Mockeadas

Para widget tests, usa scopes para aislar dependencias. **Crítico:** Debes registrar cualquier objeto que tu widget observe ANTES de llamar a `pumpWidget`:

```dart
testWidgets('TodoListWidget displays todos', (tester) async {
  // Usa un scope para aislamiento de tests
  await GetIt.I.pushNewScope();

  // Registra mocks ANTES de pumpWidget
  final mockManager = MockTodoManager();
  when(mockManager.todos).thenReturn([
    Todo('Task 1'),
    Todo('Task 2'),
  ]);
  GetIt.I.registerSingleton<TodoManager>(mockManager);

  // Ahora crea el widget
  await tester.pumpWidget(MaterialApp(home: TodoListWidget()));

  expect(find.text('Task 1'), findsOneWidget);
  expect(find.text('Task 2'), findsOneWidget);

  // Limpiar scope
  await GetIt.I.popScope();
});
```

**Puntos clave:**
- **Registra objetos observados ANTES de `pumpWidget`** - el widget intentará acceder a ellos durante la primera construcción
- Usa `pushNewScope()` para aislamiento de tests en lugar de `reset()`
- El widget accede a mocks vía `get_it` automáticamente
- Los widgets auto-contenidos son más fáciles de testear - no se necesitan parámetros del constructor

Para estrategias comprehensivas de testing con `get_it`, ver la [Testing Guide](/documentation/get_it/testing.md).

## Organización del Código

### Estructura del Widget

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#widget_structure

## Anti-Patrones

### ❌️ No Accedas a `get_it` en Constructores

**❌️ Malo - Acceder en el constructor:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#dont_access_getit_constructors_bad

**✅ Bueno - Usa callOnce:**

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#dont_access_getit_constructors_good

**¿Por qué?** Los constructores se ejecutan antes de que el widget esté adjunto al árbol, y se llamarán nuevamente cada vez que el widget se recree. Usa `callOnce()` para asegurar que la inicialización suceda solo una vez cuando el widget realmente se construya.

### ❌️ No Violes Reglas de Orden de Watch

::: warning El Orden de Watch es Crítico
Todas las llamadas `watch*`, `callOnce`, `createOnce`, y `registerHandler` deben estar en el mismo orden en cada construcción. Esta es una restricción fundamental del diseño de `watch_it`.

Ver [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) para detalles completos y excepciones seguras.
:::

### ❌️ No Hagas Await de Commands

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#dont_await_execute_bad_anti

<<< @/../code_samples/lib/watch_it/best_practices_patterns.dart#dont_await_execute_good_anti

### ❌️ No Pongas Llamadas Watch en Callbacks

Ver [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) - las llamadas watch deben estar en build(), no en callbacks.

## Debugging

Habilita tracing con `enableTracing()` o `WatchItSubTreeTraceControl` para entender el comportamiento de reconstrucción. Para técnicas de debugging detalladas y resolución de problemas comunes, ver [Debugging & Troubleshooting](/documentation/watch_it/debugging_tracing.md).

## Ver También

- [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) - Restricciones CRÍTICAS
- [Debugging & Troubleshooting](/documentation/watch_it/debugging_tracing.md) - Problemas comunes
- [Observing Commands](/documentation/watch_it/observing_commands.md) - Integración con command_it
- [Testing](/documentation/get_it/testing.md) - Testing con `get_it`
