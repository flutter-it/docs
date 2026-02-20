---
next:
  text: 'Your First Watch Functions'
  link: '/documentation/watch_it/your_first_watch_functions'
---

<div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 2rem;">
  <img src="/images/watch_it.svg" alt="watch_it logo" width="100" />
  <h1 style="margin: 0;">Primeros Pasos</h1>
</div>

::: tip 🤖 Desarrollo Asistido por IA
watch_it incluye **archivos de skills de IA** en su directorio `skills/`. Enseñan a las herramientas de IA reglas críticas como el orden de los watch. [Más información →](/es/misc/ai_skills)
:::

<strong>`watch_it`</strong> hace que tus widgets de Flutter se reconstruyan automáticamente cuando los datos cambian. Sin <code>setState</code>, sin <code>StreamBuilder</code>, solo programación reactiva simple construida sobre `get_it`.

<strong>Beneficios clave:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong><a href="/documentation/watch_it/your_first_watch_functions.md">Reconstrucciones automáticas</a></strong> - Los widgets se reconstruyen cuando los datos cambian, sin necesidad de <code>setState</code></li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong><a href="/documentation/watch_it/how_it_works.md">Sin listeners manuales</a></strong> - Suscripción y limpieza automáticas, previene memory leaks</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong><a href="/documentation/watch_it/watching_streams_and_futures.md">Async más simple</a></strong> - Reemplaza <code>StreamBuilder</code>/<code>FutureBuilder</code> con <code>watchStream()</code>/<code>watchFuture()</code></li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong><a href="/documentation/watch_it/handlers.md">Efectos secundarios</a></strong> - Navegación, diálogos, toasts sin reconstruir</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong><a href="/documentation/watch_it/lifecycle.md">Helpers de ciclo de vida</a></strong> - <code>callOnce()</code> para inicialización, <code>createOnce()</code> para controllers</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong><a href="/documentation/watch_it/observing_commands.md">Integración con commands</a></strong> - Observa commands de <code>command_it</code> reactivamente</li>
</ul>

<strong>Casos de uso comunes:</strong>
- Mostrar datos en vivo de managers (todos, perfiles de usuario, configuraciones) sin <code>setState</code>
- Mostrar actualizaciones en tiempo real de streams (mensajes de chat, notificaciones, datos de sensores)
- Navegar o mostrar diálogos en respuesta a cambios de datos
- Mostrar progreso de commands (spinners de carga, mensajes de error, estados de éxito)

![watch_it Data Flow](/images/watch-it-flow.svg)

> Únete a nuestro servidor de soporte en Discord: [https://discord.com/invite/Nn6GkYjzW](https://discord.com/invite/Nn6GkYjzW)

---

## Instalación

Añade watch_it a tu `pubspec.yaml`:

```yaml
dependencies:
  watch_it: ^2.0.0
  get_it: ^8.0.0  # watch_it se construye sobre get_it
```

---

## Ejemplo Rápido

<strong>Paso 1:</strong> Registra tus objetos reactivos con `get_it`:

<<< @/../code_samples/lib/watch_it/counter_simple_example.dart#example

<strong>Paso 2:</strong> Usa `WatchingWidget` y observa tus datos:

¡El widget se reconstruye automáticamente cuando el valor del contador cambia - sin necesidad de `setState`!

<strong>Cómo funciona:</strong>
1. **`WatchingWidget`** - Como `StatelessWidget`, pero con superpoderes reactivos
2. **`watchValue()`** - Observa datos de get_it y se reconstruye cuando cambian
3. **Suscripciones automáticas** - Sin listeners manuales, sin limpieza necesaria

El widget se suscribe automáticamente a los cambios cuando se construye y se limpia cuando se dispone.

---

## Añadiendo a Apps Existentes

¿Ya tienes una app? Solo añade un mixin a tus widgets existentes:

<<< @/../code_samples/lib/watch_it/mixin_simple_example.dart#example

No necesitas cambiar la jerarquía de tus widgets - solo añade `with WatchItMixin` y comienza a usar funciones watch.

## ¿Qué Sigue?

Ahora que has visto lo básico, hay mucho más que `watch_it` puede hacer:

→ **[Your First Watch Functions](/documentation/watch_it/your_first_watch_functions.md)** - Profundiza en `watchValue()` y otras funciones watch

→ **[WatchingWidgets](/documentation/watch_it/watching_widgets.md)** - Aprende qué tipo de widget usar (WatchingWidget, WatchingStatefulWidget, o mixins)

→ **[Watching Streams & Futures](/documentation/watch_it/watching_streams_and_futures.md)** - Reemplaza `StreamBuilder` y `FutureBuilder` con `watchStream()` y `watchFuture()` de una línea

→ **[Lifecycle Functions](/documentation/watch_it/lifecycle.md)** - Ejecuta código una vez con `callOnce()`, crea objetos locales con `createOnce()`, y gestiona disposal

¡La documentación te guiará paso a paso desde ahí!

## ¿Necesitas Ayuda?

- **Documentación:** [flutter-it.dev](https://flutter-it.dev)
- **Discord:** [Únete a nuestra comunidad](https://discord.com/invite/Nn6GkYjzW)
- **GitHub:** [Reporta problemas](https://github.com/escamoteur/watch_it/issues)
