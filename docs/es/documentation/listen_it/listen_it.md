---
next:
  text: 'Operators'
  link: '/documentation/listen_it/operators/overview'
---

<div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 2rem;">
  <img src="/images/listen_it.svg" alt="listen_it logo" width="100" />
  <h1 style="margin: 0;">listen_it</h1>
</div>

**Primitivas reactivas para Flutter** - colecciones observables y operadores potentes para ValueListenable.

## Descripción General

`listen_it` proporciona dos primitivas reactivas esenciales para el desarrollo en Flutter:

1. **Colecciones Reactivas** - ListNotifier, MapNotifier, SetNotifier que automáticamente notifican a los listeners cuando su contenido cambia
2. **Operadores de ValueListenable** - Métodos de extensión que te permiten transformar, filtrar, combinar y reaccionar a cambios de valor

Estas primitivas trabajan juntas para ayudarte a construir flujos de datos reactivos en tus apps Flutter sin generación de código o frameworks complejos.

![Flujo de datos listen_it](/images/listen-it-flow.svg)

> Únete a nuestro servidor de Discord para soporte: [https://discord.com/invite/Nn6GkYjzW](https://discord.com/invite/Nn6GkYjzW)

::: tip Desarrollo Asistido por IA
listen_it incluye **archivos de skills de IA** en su directorio `skills/`. Ayudan a las herramientas de IA a generar cadenas de operadores y patrones de colecciones correctos. [Más información →](/es/misc/ai_skills)
:::

## Instalación

Añade a tu `pubspec.yaml`:

```yaml
dependencies:
  listen_it: ^5.2.0
```

## Inicio Rápido

### listen() - La Base

Te permite trabajar con un `ValueListenable` (y `Listenable`) como debería ser, instalando una función handler que se llama en cualquier cambio de valor y recibe el nuevo valor como argumento. **Esto te da el mismo patrón que con Streams**, haciéndolo natural y consistente.

```dart
// Para ValueListenable<T>
ListenableSubscription listen(
  void Function(T value, ListenableSubscription subscription) handler
)

// Para Listenable
ListenableSubscription listen(
  void Function(ListenableSubscription subscription) handler
)
```

<<< @/../code_samples/lib/listen_it/listen_basic.dart#example

El `subscription` devuelto puede usarse para desactivar el handler. Como podrías necesitar desinstalar el handler desde dentro del mismo handler, recibes el objeto subscription como segundo parámetro de la función handler.

Esto es particularmente útil cuando quieres que un handler se ejecute solo una vez o un cierto número de veces:

<<< @/../code_samples/lib/listen_it/listen_basic.dart#self_cancel

Para `Listenable` regular (no `ValueListenable`), el handler solo recibe el parámetro subscription ya que no hay valor al cual acceder:

<<< @/../code_samples/lib/listen_it/listen_basic.dart#listenable

::: tip ¿Por qué listen()?
- **Mismo patrón que Streams** - API familiar si has usado Stream.listen()
- **Auto-cancelación** - Los handlers pueden desuscribirse a sí mismos desde dentro del handler
- **Funciona fuera del árbol de widgets** - Para lógica de negocio, servicios, efectos secundarios
- **Múltiples handlers** - Instala múltiples handlers independientes en el mismo Listenable
:::

### Operadores de ValueListenable

Encadena operadores para transformar y reaccionar a cambios de valor:

<<< @/../code_samples/lib/listen_it/chain_operators.dart#example

#### Operadores Disponibles

| Operador | Categoría | Descripción |
|----------|----------|-------------|
| [**listen()**](/documentation/listen_it/operators/overview#listening) | Listening | Instala handlers que reaccionan a cambios (patrón similar a Stream) |
| [**map()**](/documentation/listen_it/operators/transform) | Transformación | Transforma valores a diferentes tipos |
| [**select()**](/documentation/listen_it/operators/transform) | Transformación | Reacciona solo cuando propiedades específicas cambian |
| [**where()**](/documentation/listen_it/operators/filter) | Filtrado | Filtra qué valores se propagan |
| [**debounce()**](/documentation/listen_it/operators/time) | Basado en Tiempo | Retrasa notificaciones hasta que los cambios paren |
| [**async()**](/documentation/listen_it/operators/time) | Basado en Tiempo | Difiere actualizaciones al siguiente frame |
| [**combineLatest()**](/documentation/listen_it/operators/combine) | Combinación | Fusiona 2-6 ValueListenables |
| [**mergeWith()**](/documentation/listen_it/operators/combine) | Combinación | Combina cambios de valor de múltiples fuentes |

### Colecciones Reactivas

Versiones reactivas de List, Map y Set que implementan ValueListenable y automáticamente notifican a los listeners en mutaciones:

<<< @/../code_samples/lib/listen_it/list_notifier_basic.dart#example

Úsalas con `ValueListenableBuilder` para UI reactiva:

<<< @/../code_samples/lib/listen_it/list_notifier_widget.dart#example

O con `watchValue` de [watch_it](/documentation/watch_it/getting_started) para código más limpio:

<<< @/../code_samples/lib/listen_it/list_notifier_watch_it.dart#example

#### Eligiendo la Colección Correcta

| Colección | Úsala Cuando | Casos de Uso Ejemplo |
|------------|----------|-------------------|
| **ListNotifier\<T\>** | El orden importa, duplicados permitidos | Listas de tareas, mensajes de chat, historial de búsqueda |
| **MapNotifier\<K,V\>** | Necesitas búsquedas clave-valor | Preferencias de usuario, cachés, datos de formulario |
| **SetNotifier\<T\>** | Solo elementos únicos, pruebas rápidas de membresía | IDs de elementos seleccionados, filtros activos, etiquetas |

## Cuándo Usar Qué

### Usa Operadores de ValueListenable Cuando:
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Necesites transformar valores (map, select)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Necesites filtrar actualizaciones (where)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Necesites aplicar debounce a cambios rápidos (entradas de búsqueda)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Necesites combinar múltiples ValueListenables</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Estés construyendo pipelines de transformación de datos</li>
</ul>

### Usa Colecciones Reactivas Cuando:
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Necesites una List, Map o Set que notifique listeners en mutaciones</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Quieras actualizaciones automáticas de UI sin llamadas manuales a `notifyListeners()`</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Estés construyendo listas reactivas, cachés o sets en tu capa de UI</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Quieras agrupar múltiples operaciones en una sola notificación</li>
</ul>

## Conceptos Clave

### Colecciones Reactivas

Los tres tipos de colección (ListNotifier, MapNotifier, SetNotifier) extienden sus interfaces estándar de colección de Dart y añaden:

- **Notificaciones Automáticas** - Cada mutación dispara listeners
- **Modos de Notificación** - Controla cuándo se disparan las notificaciones (always, normal, manual)
- **Transacciones** - Agrupa operaciones en notificaciones únicas
- **Valores Inmutables** - Los getters `.value` devuelven vistas no modificables
- **Interfaz ValueListenable** - Funciona con `ValueListenableBuilder` y watch_it

[Aprende más sobre colecciones →](/documentation/listen_it/collections/introduction)

### Operadores de ValueListenable

Los operadores crean cadenas de transformación:

- **Encadenables** - Cada operador devuelve un nuevo ValueListenable
- **Inicialización Lazy** - Las cadenas se suscriben solo cuando se añaden listeners
- **Suscripción Hot** - Una vez suscritas, las cadenas permanecen suscritas
- **Tipado Seguro** - Verificación completa de tipos en tiempo de compilación

[Aprende más sobre operadores →](/documentation/listen_it/operators/overview)

## CustomValueNotifier

Un ValueNotifier con comportamiento de notificación y modos configurables.

### Constructor

```dart
CustomValueNotifier<T>(
  T initialValue, {
  CustomNotifierMode mode = CustomNotifierMode.normal,
  bool asyncNotification = false,
  void Function(Object error, StackTrace stackTrace)? onError,
})
```

**Parámetros:**
- `initialValue` - El valor inicial
- `mode` - Modo de notificación (por defecto: `CustomNotifierMode.normal`)
- `asyncNotification` - Si es true, las notificaciones se difieren asíncronamente para evitar problemas de setState-durante-build
- `onError` - Handler de errores opcional llamado cuando un listener lanza una excepción. Si no se proporciona, las excepciones se reportan vía `FlutterError.reportError()`

### Uso Básico

<<< @/../code_samples/lib/listen_it/custom_value_notifier.dart#example

### Modos de Notificación

CustomValueNotifier soporta tres modos vía el enum `CustomNotifierMode`:

- **normal** (por defecto para CustomValueNotifier) - Solo notifica cuando el valor realmente cambia usando comparación `==`
- **always** - Notifica en cada asignación, incluso si el valor es el mismo
- **manual** - Solo notifica cuando llamas explícitamente a `notifyListeners()`

```dart
final counter = CustomValueNotifier<int>(
  0,
  mode: CustomNotifierMode.normal,  // por defecto
);

counter.value = 0;  // ❌️ Sin notificación (valor sin cambios)
counter.value = 1;  // ✅ Notifica (valor cambió)
```

::: tip Diferentes Valores por Defecto
**CustomValueNotifier** tiene por defecto el modo `normal` para ser un **reemplazo directo de ValueNotifier**, que solo notifica cuando el valor realmente cambia usando comparación `==`.

**Colecciones Reactivas** (ListNotifier, MapNotifier, SetNotifier) tienen por defecto el modo `always` para asegurar actualizaciones de UI en cada operación, incluso cuando los objetos no sobrescriben `==`.

[Aprende más sobre modos de notificación →](/documentation/listen_it/collections/notification_modes)
:::

## Ejemplo del Mundo Real

Combinando operadores y colecciones para búsqueda reactiva:

<<< @/../code_samples/lib/listen_it/search_viewmodel.dart#example

## Integración con el Ecosistema flutter_it

### Con watch_it (¡Recomendado!)

watch_it v2.0+ proporciona **caché automático de selectores**, haciendo la creación de cadenas inline completamente segura:

<<< @/../code_samples/lib/listen_it/chain_watch_it_safe.dart#watchValue_safe

El valor por defecto `allowObservableChange: false` cachea el selector, ¡así que la cadena se crea solo una vez!

[Aprende más sobre integración con watch_it →](/documentation/watch_it/getting_started)

### Con get_it

Registra tus colecciones reactivas y cadenas en get_it para acceso global:

```dart
void configureDependencies() {
  getIt.registerSingleton<ListNotifier<Todo>>(ListNotifier());
  getIt.registerLazySingleton(() => ValueNotifier<String>(''));
}
```

[Aprende más sobre get_it →](/es/documentation/get_it/getting_started)

### Con command_it

command_it usa operadores de listen_it internamente para operaciones de ValueListenable:

```dart
final command = Command.createAsync<String, void>(
  (searchTerm) async => performSearch(searchTerm),
  restriction: searchTerm.where((term) => term.length >= 3),
);
```

[Aprende más sobre command_it →](/documentation/command_it/getting_started)

## Siguientes Pasos

- [Operadores →](/documentation/listen_it/operators/overview)
- [Colecciones →](/documentation/listen_it/collections/introduction)
- [Mejores Prácticas →](/documentation/listen_it/best_practices)
- [Ejemplos →](/examples/listen_it/listen_it)

## Nombres Anteriores del Paquete

- Previamente publicado como `functional_listener` (solo operadores)
- Colecciones reactivas previamente publicadas como `listenable_collections`
- Ambos están ahora unificados en `listen_it` v5.0+
