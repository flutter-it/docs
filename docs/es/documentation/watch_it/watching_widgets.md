# WatchingWidgets

## ¿Por Qué Necesitas Widgets Especiales?

Podrías preguntarte: "¿Por qué no puedo simplemente usar `watchValue()` en un `StatelessWidget` regular?"

**El problema:** `watch_it` necesita engancharse al ciclo de vida de tu widget para:
1. **Suscribirse** a cambios cuando el widget se construye
2. **Desuscribirse** cuando el widget se dispone (prevenir memory leaks)
3. **Reconstruir** el widget cuando los datos cambian

Un `StatelessWidget` regular no le da a `watch_it` acceso a estos eventos del ciclo de vida. Necesitas un widget al que `watch_it` pueda engancharse.

## WatchingWidget - Para Widgets Sin Estado Local

Reemplaza `StatelessWidget` con `WatchingWidget`:

<<< @/../code_samples/lib/watch_it/watching_widgets_patterns.dart#watching_widget_basic

**Usa esto cuando:**
- Escribes nuevos widgets
- No necesitas estado local (`setState`)
- UI reactiva simple

## WatchingStatefulWidget - Para Widgets Con Estado Local

Usa cuando necesites tanto `setState` COMO estado reactivo:

<<< @/../code_samples/lib/watch_it/watching_widgets_patterns.dart#watching_stateful_widget

**Usa esto cuando:**
- Necesitas estado de UI local (toggles de filtro, estado de expansión)
- Mezcla `setState` con actualizaciones reactivas

**Nota:** ¡Tu clase State automáticamente obtiene todas las funciones watch - no se necesita mixin!

**Patrón:** Estado local (`_showCompleted`) para preferencias solo de UI, estado reactivo (`todos`) del manager, y checkboxes llaman de vuelta al manager para actualizar datos.

> **⚠️ Importante:** Con `watch_it`, **raramente necesitarás StatefulWidget más**. La mayoría del estado pertenece en tus managers y se accede reactivamente. Incluso `TextEditingController` y `AnimationController` pueden crearse con `createOnce()` en `WatchingWidget` - ¡no se necesita StatefulWidget! Solo usa StatefulWidget para estado de UI verdaderamente local que requiere `setState`.

## Alternativa: Usar Mixins

Si tienes **widgets existentes** que no quieres cambiar, usa mixins en su lugar:

### Para StatelessWidget Existente

<<< @/../code_samples/lib/watch_it/watching_widgets_patterns.dart#mixin_stateless

### Para StatefulWidget Existente

<<< @/../code_samples/lib/watch_it/watching_widgets_patterns.dart#mixin_stateful

**¿Por qué usar mixins?**
- Mantener jerarquía de clases existente
- Puede usar constructores `const` con `WatchItMixin`
- Cambios mínimos al código existente
- Perfecto para migración gradual

## Guía de Decisión Rápida

**¿Nuevo widget, sin estado local?**
✅ Usa `WatchingWidget`

**¿Nuevo widget CON estado local?**
✅ Usa `WatchingStatefulWidget`

**¿Migrando StatelessWidget existente?**
✅ Añade `with WatchItMixin`

**¿Migrando StatefulWidget existente?**
✅ Añade `with WatchItStatefulWidgetMixin` al StatefulWidget (¡no al State!)

## Patrones Comunes

### Combinar con Otros Mixins

<<< @/../code_samples/lib/watch_it/watching_widgets_patterns.dart#combining_mixins

## Ver También

- [Getting Started](/documentation/watch_it/getting_started.md) - Uso básico de `watch_it`
- [Your First Watch Functions](/documentation/watch_it/your_first_watch_functions.md) - Aprende `watchValue()`
- [Watch Ordering Rules](/documentation/watch_it/watch_ordering_rules.md) - Reglas CRÍTICAS
