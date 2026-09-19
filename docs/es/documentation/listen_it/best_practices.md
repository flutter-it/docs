---
title: Mejores Prácticas
---

# Mejores Prácticas

Guías para usar listen_it efectivamente y evitar errores comunes.

## Ciclo de Vida de Cadenas

### Attach, Detach y Valores Derivados (v6.0.0+)

Una cadena de operators (`source.map(...)`, `a.combineLatest(b, ...)`, ...) sigue este ciclo de vida:

1. **Attach** - la cadena se suscribe a su(s) fuente(s) cuando se crea (por defecto) o, con `lazy: true`, cuando recibe su primer listener
2. **Detach** - cuando se elimina el *último* listener, la cadena se desuscribe de su(s) fuente(s). En una cadena larga esto se propaga en cascada hasta la fuente original
3. **Re-attach** - el siguiente `addListener` se suscribe de nuevo y refresca el valor almacenado *antes* de registrar el nuevo listener, así no se pierde nada ni se envía ninguna notificación espuria

Mientras una cadena está desconectada, su `.value` se **deriva del valor actual de la fuente al leerlo**, así que nunca está obsoleto:

```dart
final source = ValueNotifier<int>(1);
final doubled = source.map((x) => x * 2);

void listener() {}
doubled.addListener(listener);
doubled.removeListener(listener); // último listener eliminado -> desconectada

source.value = 5;
print(doubled.value); // 10 ✅ derivado al leer, sin suscripción

doubled.addListener(listener); // reconectada, el valor ya está fresco
```

| Operator | `.value` mientras está desconectada |
|---|---|
| `map`, `select` | transformación / selector aplicado al valor actual de la fuente |
| `where` | el valor actual de la fuente si pasa el filtro, si no el último valor que pasó |
| `debounce`, `async` | valor actual de la fuente |
| `combineLatest` | combinador aplicado a los valores actuales de las fuentes |
| `mergeWith` | último valor recibido (no puede saber qué fuente cambió última) |

::: warning Mantén las Transformaciones Puras
Como la transformación puede ejecutarse al leer mientras la cadena está desconectada, las funciones de transformación deben ser puras - sin efectos secundarios, misma entrada → misma salida.
:::

### lazy: true

`lazy: true` solo cambia el paso 1: la primera suscripción ocurre con el primer listener en lugar de en la creación. Antes de eso, `.value` se deriva al leer exactamente igual que en una cadena desconectada, así que `lazy: true` es una optimización pura de memoria sin valores obsoletos. Mezclar operators lazy y eager en una cadena está bien.

```dart
final source = ValueNotifier<int>(5);
final eager = source.map((x) => x * 2);           // conectada al crearse
final lazy = eager.map((x) => x + 1, lazy: true); // se conecta con el primer listener

source.value = 7;
print(eager.value); // 14 ✅
print(lazy.value);  // 15 ✅ derivado al leer
```

### ❌️️ INCORRECTO: Cadenas en Métodos Build

No crees cadenas inline en métodos build:

#### Inline en Método Build

<<< @/../code_samples/lib/listen_it/chain_incorrect_pattern.dart#build_inline

#### Inline en ValueListenableBuilder

<<< @/../code_samples/lib/listen_it/chain_incorrect_pattern.dart#valueListenableBuilder_inline

**Por qué esto está mal:**
- Se crea un nuevo objeto cadena en **cada reconstrucción**
- Cada cadena se conecta a la fuente y trabaja hasta que se descarta
- Es un desperdicio y hace que el comportamiento del widget dependa del momento de la reconstrucción

Desde v6.0.0 esto ya no es una *fuga* de memoria - una cadena descartada se desconecta de la fuente en cuanto pierde sus listeners (o, si nadie la escuchó nunca, con la primera notificación que recibe). Sigue siendo el patrón incorrecto.

### ✅ CORRECTO: Crear Cadenas Una Vez

Crear cadenas asegurando que se creen solo una vez. Aquí hay tres enfoques seguros:

<<< @/../code_samples/lib/listen_it/chain_correct_pattern.dart#example

**Por qué estos funcionan:**
- **Opción 1**: Cadena creada una vez en `initState()` (¡no en constructor, que se ejecuta en cada reconstrucción!)
- **Opción 2**: `createOnce()` asegura que la cadena se cree solo una vez aunque esté en build
- **Opción 3**: La cadena vive en tu capa de datos (recomendado para apps grandes)
- Todas las opciones reusan el mismo objeto de cadena en cada reconstrucción

::: warning No Crear en Constructor
Nunca crear cadenas en un constructor de StatelessWidget o como inicializadores de campo - el constructor se ejecuta en **cada reconstrucción**, ¡que es el mismo problema que crear en build!
:::

### ✅ RECOMENDADO: Usar watch_it

El enfoque más seguro es usar watch_it, que cachea el selector y se desuscribe cuando el widget se dispone:

<<< @/../code_samples/lib/listen_it/chain_watch_it_safe.dart#watchValue_safe

**Por qué watch_it es mejor:**
- El `allowObservableChange: false` predeterminado cachea el selector, así que la cadena se crea solo una vez por instancia de widget
- Cuando el widget se dispone, watch_it elimina su listener y la cadena se desconecta de `m.source`
- Sin gestión manual del ciclo de vida necesaria
- Código limpio y conciso

[Aprende más sobre watch_it →](/es/documentation/watch_it/getting_started)

## Disposición

### Las Cadenas Normalmente No Necesitan Disposición

Una cadena sin listeners no mantiene ninguna suscripción a su fuente, así que se recolecta en cuanto nada la referencia. Y cuando todo el grafo (fuente + cadena) se vuelve inalcanzable, el GC de Dart lo recolecta independientemente de las suscripciones.

**✅ NO necesitas disponer cadenas cuando:**

1. **La fuente es propiedad del mismo objeto que la cadena**
   ```dart
   class CounterService {
     final source = ValueNotifier<int>(0);
     late final doubled = source.map((x) => x * 2);

     void dispose() {
       source.dispose(); // Solo disponer fuente
       // La cadena se recolecta automáticamente cuando el servicio se vuelve inalcanzable
     }
   }
   ```

2. **La fuente vive más que la cadena** (p. ej. está registrada en get_it) - en cuanto la cadena pierde sus listeners se desconecta de la fuente, así que una cadena descartada no mantiene ocupada a la fuente
   ```dart
   class TemporaryViewModel {
     final globalSource = getIt<ValueNotifier<int>>(); // Fuente de larga vida
     late final chain = globalSource.map((x) => x * 2);

     // No se necesita disponer la cadena: cuando el widget que observaba
     // `chain` se dispone, la cadena pierde su último listener y se desconecta
   }
   ```

3. **Usando watch_it** - gestión automática del ciclo de vida

### Cuándo DEBERÍAS Disponer la Fuente

**✅ Siempre disponer la fuente ValueNotifier para:**
- Detener que se llamen handlers
- Liberar recursos mantenidos por la fuente
- Seguir gestión apropiada de recursos

```dart
class MyService {
  final counter = ValueNotifier<int>(0);
  late final doubled = counter.map((x) => x * 2);

  void dispose() {
    counter.dispose(); // Detiene notificaciones y libera recursos
  }
}
```

### Cuándo Disponer una Cadena Explícitamente

Llama a `dispose()` en una cadena solo cuando:
- Quieres terminarla explícitamente **mientras aún tiene listeners**
- Quieres asegurarte de que se cancela un timer de `debounce` pendiente o una actualización `async`

```dart
(chain as ChangeNotifier).dispose();
```

### Disposición de Suscripciones

Siempre cancelar suscripciones creadas con `.listen()`:

<<< @/../code_samples/lib/listen_it/chain_disposal.dart#subscription_disposal

## Mejores Prácticas de Colecciones Reactivas

### Elegir el Modo de Notificación Correcto

**CustomNotifierMode.always** (predeterminado):
- Notifica en cada operación, incluso si el valor no cambia
- Usar cuando no hayas sobrescrito el operador `==`
- Previene confusión de UI al establecer el "mismo" valor

**CustomNotifierMode.normal**:
- Solo notifica cuando el valor realmente cambia (usa comparación `==`)
- Usar cuando hayas implementado igualdad apropiada (operador `==`)
- Más eficiente (menos notificaciones)

**CustomNotifierMode.manual**:
- Sin notificaciones automáticas
- Debes llamar a `notifyListeners()` manualmente
- Usar para escenarios de actualización complejos

```dart
// Predeterminado: modo always (más seguro)
final items = ListNotifier<String>(data: []);

// Modo normal: solo en cambios
final items = ListNotifier<String>(
  data: [],
  notificationMode: CustomNotifierMode.normal,
);

// Modo manual: control explícito
final items = ListNotifier<String>(
  data: [],
  notificationMode: CustomNotifierMode.manual,
);
items.add('item');
items.notifyListeners(); // Notificación explícita
```

### Usar Transacciones para Operaciones Masivas

Agrupar múltiples operaciones en una sola notificación:

```dart
final items = ListNotifier<String>(data: []);

// ❌️ SIN transacción: 3 notificaciones
items.add('item1');
items.add('item2');
items.add('item3');

// ✅ CON transacción: 1 notificación
items.startTransAction();
items.add('item1');
items.add('item2');
items.add('item3');
items.endTransAction();
```

### Acceder a Valores Inmutables

El getter `.value` devuelve una **vista no modificable**:

```dart
final items = ListNotifier<String>(data: ['one']);

// ✅ CORRECTO: Usar métodos de colección
items.add('two');
items.removeAt(0);

// ❌️ INCORRECTO: No modificar .value directamente
items.value.add('three'); // ¡Lanza UnsupportedError!
```

## Mejores Prácticas de Cadenas de Operators

### Mantener Cadenas Legibles

Cadenas largas son poderosas pero pueden volverse difíciles de leer. Considera dividirlas:

```dart
// ❌️ Difícil de leer
final result = source
  .where((x) => x.isNotEmpty)
  .map((x) => x.trim())
  .select<int>((x) => x.length)
  .debounce(Duration(milliseconds: 300))
  .where((len) => len > 3)
  .map((len) => len.toString());

// ✅ Mejor: Dividir en pasos lógicos con nombres descriptivos
final nonEmpty = source.where((x) => x.isNotEmpty);
final trimmed = nonEmpty.map((x) => x.trim());
final length = trimmed.select<int>((x) => x.length);
final debounced = length.debounce(Duration(milliseconds: 300));
final filtered = debounced.where((len) => len > 3);
final display = filtered.map((len) => len.toString());
```

### Usar select() para Propiedades de Objetos

Al trabajar con objetos, usar `select()` para reaccionar solo cuando cambien propiedades específicas:

```dart
final user = ValueNotifier(User(name: 'John', age: 25));

// ❌️ INEFICIENTE: Notifica en CUALQUIER cambio de usuario
final name = user.map((u) => u.name);

// ✅ MEJOR: Solo notifica cuando el nombre realmente cambia
final name = user.select<String>((u) => u.name);
```

### Preferir where() Sobre Lógica Condicional

Filtrar en la fuente en lugar de en el handler:

```dart
final input = ValueNotifier<String>('');

// ❌️ Menos eficiente: Todas las actualizaciones llegan al handler
input.listen((value, _) {
  if (value.length >= 3) {
    search(value);
  }
});

// ✅ Mejor: Filtrar actualizaciones antes de que lleguen al handler
input
  .where((term) => term.length >= 3)
  .listen((value, _) => search(value));
```

## Mejores Prácticas de Testing

### Testear Cadenas de Operators

```dart
test('map operator transforma valores', () {
  final source = ValueNotifier<int>(5);
  final chain = source.map((x) => x * 2);

  expect(chain.value, 10);

  source.value = 3;
  expect(chain.value, 6);

  // Limpiar
  (chain as ChangeNotifier).dispose();
});
```

### Testear Colecciones Reactivas

```dart
test('ListNotifier notifica en add', () {
  final items = ListNotifier<String>(data: []);
  final notifications = <List<String>>[];

  items.listen((list, _) => notifications.add(List.from(list)));

  items.add('item1');
  items.add('item2');

  expect(notifications, [
    ['item1'],
    ['item1', 'item2'],
  ]);
});
```

### Limpiar en Tests

Dispón la fuente en los tests; dispón también la cadena si usa `debounce()` o `async()` para que ningún timer sobreviva al test:

```dart
test('example test', () {
  final source = ValueNotifier<int>(0);
  final chain = source.debounce(Duration(milliseconds: 100));

  // ... código del test ...

  // Limpieza
  (chain as ChangeNotifier).dispose(); // cancela el timer pendiente
  source.dispose();
});
```

## Consejos de Rendimiento

### Evitar Debouncing Excesivo

Solo aplicar debounce cuando sea necesario (entrada de usuario, cambios rápidos):

```dart
// ✅ BUENO: Debounce entrada de usuario
searchTerm
  .debounce(Duration(milliseconds: 300))
  .listen((term, _) => search(term));

// ❌️ INNECESARIO: Debouncing de actualizaciones infrecuentes
userProfile
  .debounce(Duration(seconds: 1)) // El perfil cambia raramente
  .listen((profile, _) => updateUI(profile));
```

### Usar Transacciones para Colecciones

Agrupar operaciones para reducir sobrecarga de notificaciones:

```dart
// ❌️ INEFICIENTE: 1000 notificaciones
for (var i = 0; i < 1000; i++) {
  items.add(i);
}

// ✅ EFICIENTE: 1 notificación
items.startTransAction();
for (var i = 0; i < 1000; i++) {
  items.add(i);
}
items.endTransAction();
```

### Perfilar tus Cadenas

Si el rendimiento es crítico, medir:

```dart
final stopwatch = Stopwatch()..start();
chain.listen((value, _) {
  print('Update took: ${stopwatch.elapsedMicroseconds}μs');
  stopwatch.reset();
});
```

## Errores Comunes

### 1. Crear Cadenas en Build

```dart
// ❌️ INCORRECTO: Nueva cadena en cada build
Widget build(BuildContext context) {
  return ValueListenableBuilder(
    valueListenable: source.map((x) => x * 2), // ¡NUEVA CADENA EN CADA RECONSTRUCCIÓN!
    builder: (context, value, _) => Text('$value'),
  );
}

// ✅ CORRECTO: Usar watch_it o crear la cadena una vez
late final chain = source.map((x) => x * 2);
```

### 2. Efectos Secundarios en Transformaciones

```dart
// ❌️ INCORRECTO: La transformación puede ejecutarse al leer mientras la cadena está desconectada
final logged = source.map((x) {
  analytics.track('value', x); // ¡efecto secundario!
  return x * 2;
});

// ✅ CORRECTO: Mantén las transformaciones puras, haz los efectos secundarios en listen()
final doubled = source.map((x) => x * 2);
doubled.listen((x, _) => analytics.track('value', x));
```

### 3. Modificar .value de Colección Directamente

```dart
// ❌️ INCORRECTO: Lanza error
items.value.add('new'); // ¡UnsupportedError!

// ✅ CORRECTO: Usar métodos de colección
items.add('new');
```

### 4. No Usar select() para Objetos

```dart
final user = ValueNotifier(User(name: 'John', age: 25));

// ❌️ INEFICIENTE: Notifica incluso cuando el nombre no cambia
user.map((u) => u.name).listen((name, _) => print(name));

// ✅ EFICIENTE: Solo notifica cuando el nombre cambia
user.select<String>((u) => u.name).listen((name, _) => print(name));
```

## Resumen

**Puntos clave:**

1. ✅ **Nunca crear cadenas en métodos build** (o usar watch_it para caché automático)
2. ✅ **Mantén las funciones de transformación puras** - pueden ejecutarse al leer mientras una cadena está desconectada
3. ✅ **Usar transacciones** para operaciones masivas de colecciones
4. ✅ **Usar select()** al reaccionar a propiedades de objetos
5. ✅ **Preferir where()** sobre lógica condicional en handlers
6. ✅ **Elegir el modo de notificación correcto** para colecciones
7. ✅ **Testear tus cadenas** y limpiar en tests

**Enfoque recomendado:**
- Usar **watch_it** para widgets (gestión automática del ciclo de vida)
- Usar **clases modelo** para lógica de negocio (disposición manual)
- Usar **transacciones** para actualizaciones masivas
- Usar **select()** para propiedades de objetos

## Próximos Pasos

- [Aprende sobre detalles de operators →](/documentation/listen_it/operators/overview)
- [Aprende sobre colecciones →](/documentation/listen_it/collections/introduction)
- [Ver ejemplos →](/examples/listen_it/listen_it)
- [Únete a Discord para ayuda →](https://discord.com/invite/Nn6GkYjzW)
