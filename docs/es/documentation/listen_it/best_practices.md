---
title: Mejores Prácticas
---

# Mejores Prácticas

Guías para usar listen_it efectivamente y evitar errores comunes.

## Ciclo de Vida de Cadenas

### Inicialización Eager con Suscripciones Persistentes

Las cadenas de operators usan inicialización eager por defecto con suscripciones persistentes:

1. **Las cadenas se suscriben a su fuente inmediatamente** por defecto (inicialización eager)
2. Para optimización de memoria, pasa `lazy: true` para retrasar la suscripción hasta que se añada el primer listener
3. **Una vez suscritas, las cadenas permanecen suscritas** por eficiencia, incluso cuando tienen cero listeners
4. Las cadenas mantienen su suscripción hasta ser dispuestas explícitamente

::: danger Riesgo de Fuga de Memoria
Crear cadenas inline en métodos build crea una **nueva cadena en cada reconstrucción**, cada una permaneciendo suscrita para siempre. ¡Esto causa fugas de memoria!
:::

### Mezclando Lazy y Eager en Cadenas

Cada operator en una cadena es independiente. Puedes mezclar lazy y eager, pero esto puede llevar a comportamiento confuso:

```dart
final source = ValueNotifier<int>(5);
final eager = source.map((x) => x * 2);           // Predeterminado: eager
final lazy = eager.map((x) => x + 1, lazy: true); // Explícito: lazy

source.value = 7;
print(eager.value); // 14 ✅ (eager suscrito, actualiza inmediatamente)
print(lazy.value);  // 11 ⚠️ (¡OBSOLETO! lazy no suscrito aún)

lazy.addListener(() {}); // Suscribir lazy a eager
print(lazy.value);  // 11 ⚠️ (¡AÚN OBSOLETO! No actualiza retroactivamente)

source.value = 10;
print(lazy.value);  // 21 ✅ (AHORA actualiza en el siguiente cambio)
```

**Comportamientos clave:**

- **Eager → Lazy**: La parte eager se actualiza, la parte lazy puede estar obsoleta hasta que se añada listener
- **Lazy → Eager**: Eager se suscribe a lazy inmediatamente, lo que dispara que lazy inicialice toda la cadena
- **Todo eager (predeterminado)**: Toda la cadena se suscribe inmediatamente, `.value` siempre correcto ✅
- **Todo lazy**: La cadena no se suscribe hasta que el final obtiene un listener

::: warning No Mezclar
**Recomendación**: No mezclar. Usa todo-eager (predeterminado, simple) o todo-lazy (optimización de memoria). Mezclar puede causar valores obsoletos difíciles de depurar.
:::

### ❌️️ INCORRECTO: Cadenas en Métodos Build

Nunca crear cadenas inline en métodos build:

#### Inline en Método Build

<<< @/../code_samples/lib/listen_it/chain_incorrect_pattern.dart#build_inline

#### Inline en ValueListenableBuilder

<<< @/../code_samples/lib/listen_it/chain_incorrect_pattern.dart#valueListenableBuilder_inline

**Por qué esto está mal:**
- Nueva cadena creada en **cada reconstrucción**
- Cada cadena se suscribe a la fuente y **nunca se desuscribe**
- Múltiples reconstrucciones = múltiples cadenas filtradas
- El uso de memoria crece indefinidamente

### ✅ CORRECTO: Crear Cadenas Una Vez

Crear cadenas asegurando que se creen solo una vez. Aquí hay tres enfoques seguros:

<<< @/../code_samples/lib/listen_it/chain_correct_pattern.dart#example

**Por qué estos funcionan:**
- **Opción 1**: Cadena creada una vez en `initState()` (¡no en constructor, que se ejecuta en cada reconstrucción!)
- **Opción 2**: `createOnce()` asegura que la cadena se cree solo una vez aunque esté en build
- **Opción 3**: La cadena vive en tu capa de datos (recomendado para apps grandes)
- Todas las opciones reusan el mismo objeto de cadena en cada reconstrucción
- Sin fugas de memoria

::: warning No Crear en Constructor
Nunca crear cadenas en un constructor de StatelessWidget o como inicializadores de campo - el constructor se ejecuta en **cada reconstrucción**, ¡causando la misma fuga de memoria que crear en build!
:::

### ✅ RECOMENDADO: Usar watch_it

El enfoque más seguro es usar watch_it v2.0+, que proporciona caché automático de selectores:

<<< @/../code_samples/lib/listen_it/chain_watch_it_safe.dart#watchValue_safe

**Por qué watch_it es mejor:**
- El `allowObservableChange: false` predeterminado cachea el selector
- Cadena creada solo una vez, aunque esté inline
- Sin gestión manual del ciclo de vida necesaria
- Código limpio y conciso

[Aprende más sobre watch_it →](/documentation/watch_it/getting_started)

## Disposición

### Entendiendo la Recolección de Basura de Cadenas

**Hallazgo Clave**: Las cadenas crean referencias circulares con su fuente, pero el recolector de basura de Dart maneja esto correctamente cuando todo el ciclo se vuelve inalcanzable desde las raíces de GC.

**Cómo funciona**:
- Las cadenas se registran como listeners en su fuente (inmediatamente si es eager, o cuando se añade el primer listener si es lazy)
- Esto crea una referencia circular: `source → listener → chain → source`
- Cuando el objeto contenedor (estado del widget, servicio, etc.) se vuelve inalcanzable, **todo el ciclo se recolecta automáticamente**
- ¡No se necesita disposición manual de cadenas en la mayoría de casos!

### Cuándo NO Se Necesita Disposición de Cadenas

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

2. **Cadena y fuente en objetos diferentes que ambos pueden ser recolectados**
   ```dart
   class DataSource {
     final data = ValueNotifier<int>(0);
     void dispose() => data.dispose();
   }

   class DataProcessor {
     final DataSource source;
     late final processed = source.data.map((x) => x * 2);

     DataProcessor(this.source);

     // No se necesita disposición de cadena - cuando tanto DataProcessor COMO DataSource
     // se vuelven inalcanzables, todo el ciclo se recolecta automáticamente
   }
   ```

   **⚠️ CUIDADO**: Esto solo funciona si **ambos objetos** (el que posee la cadena Y el que posee la fuente) pueden ser recolectados juntos. Si la fuente se mantiene viva en otro lugar (como en `get_it`), ¡debes disponer la cadena manualmente!

3. **Usando watch_it** - gestión automática del ciclo de vida

**Por qué es seguro**: Cuando todo el grafo de objetos (objeto contenedor + fuente + cadena) se vuelve inalcanzable desde las raíces de GC, el recolector de basura de Dart rastrea alcanzabilidad y recolecta todo en el ciclo automáticamente.

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

### Excepción: Fuentes de Larga Vida

**⚠️ Solo disponer cadenas manualmente si:**
- La fuente está registrada en `get_it` u otro service locator
- La fuente se mantiene viva más tiempo del que la cadena debería
- Necesitas romper la conexión del listener explícitamente

```dart
class TemporaryViewModel {
  final globalSource = getIt<ValueNotifier<int>>(); // Fuente de larga vida
  late final chain = globalSource.map((x) => x * 2);

  void dispose() {
    // La fuente permanece viva en get_it, así que eliminar listener de cadena manualmente
    (chain as ChangeNotifier).dispose();
  }
}
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

Siempre disponer cadenas en tests para prevenir fugas de memoria:

```dart
test('ejemplo de test', () {
  final source = ValueNotifier<int>(0);
  final chain = source.map((x) => x * 2);

  // ... código de test ...

  // Limpiar
  (chain as ChangeNotifier).dispose();
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

### 1. Olvidar Disponer

```dart
// ❌️ INCORRECTO: Cadena nunca dispuesta
class MyWidget extends StatefulWidget {
  // ... cadena creada en initState pero nunca dispuesta
}

// ✅ CORRECTO: Siempre disponer
@override
void dispose() {
  if (chain is ChangeNotifier) {
    (chain as ChangeNotifier).dispose();
  }
  super.dispose();
}
```

### 2. Crear Cadenas en Build

```dart
// ❌️ INCORRECTO: Nueva cadena en cada build
Widget build(BuildContext context) {
  return ValueListenableBuilder(
    valueListenable: source.map((x) => x * 2), // ¡FUGA!
    builder: (context, value, _) => Text('$value'),
  );
}

// ✅ CORRECTO: Usar watch_it o crear cadena una vez
late final chain = source.map((x) => x * 2);
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
2. ✅ **Siempre disponer cadenas** cuando termines (excepto con watch_it)
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
