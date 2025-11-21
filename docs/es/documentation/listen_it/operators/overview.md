---
title: Operators
---

# Operators

Los operators de ValueListenable son métodos de extensión que te permiten transformar, filtrar, combinar y reaccionar a cambios de valor de forma reactiva y componible.

## Introducción

Las funciones de extensión en `ValueListenable` te permiten trabajar con ellos casi como streams síncronos. Cada operator devuelve un nuevo `ValueListenable` que se actualiza cuando la fuente cambia, permitiéndote construir pipelines de datos reactivos complejos a través del encadenamiento.

## Conceptos Clave

### Encadenables

Cada operator (excepto `listen()`) devuelve un nuevo `ValueListenable`, permitiéndote encadenar múltiples operators juntos:

<<< @/../code_samples/lib/listen_it/chain_operators.dart#example

### Tipado Seguro

Todos los operators mantienen verificación de tipos completa en tiempo de compilación:

```dart
final intNotifier = ValueNotifier<int>(42);

// El tipo se infiere: ValueListenable<String>
final stringNotifier = intNotifier.map<String>((i) => i.toString());

// Error de compilación si los tipos no coinciden
// final badNotifier = intNotifier.map<String>((i) => i); // ❌️ Error
```

### Inicialización Eager

Por defecto, las cadenas de operators usan **inicialización eager** - se suscriben a su fuente inmediatamente, asegurando que `.value` siempre sea correcto incluso antes de añadir listeners. Esto soluciona problemas de valores obsoletos pero usa ligeramente más memoria.

```dart
final source = ValueNotifier<int>(5);
final mapped = source.map((x) => x * 2); // Se suscribe inmediatamente

print(mapped.value); // Siempre correcto: 10

source.value = 7;
print(mapped.value); // Actualizado inmediatamente: 14 ✅
```

Para escenarios con limitaciones de memoria, pasa `lazy: true` para retrasar la suscripción hasta que se añada el primer listener:

```dart
final lazy = source.map((x) => x * 2, lazy: true);
// No se suscribe hasta que se llame a addListener()
```

::: warning Ciclo de Vida de la Cadena
Una vez inicializadas (ya sea eager o después del primer listener), las cadenas de operators mantienen su suscripción a la fuente incluso cuando tienen cero listeners. Esta suscripción persistente es por diseño para eficiencia, pero **puede causar fugas de memoria si las cadenas se crean inline en métodos build**.

Mira la [guía de mejores prácticas](/documentation/listen_it/best_practices) para patrones seguros.
:::

## Operators Disponibles

### Transformación

Transforma valores a diferentes tipos o selecciona propiedades específicas:

- **[map()](/documentation/listen_it/operators/transform#map)** - Transforma valores usando una función
- **[select()](/documentation/listen_it/operators/transform#select)** - Reacciona solo cuando una propiedad seleccionada cambia

### Filtrado

Controla qué valores se propagan a través de la cadena:

- **[where()](/documentation/listen_it/operators/filter)** - Filtra valores basándose en un predicado

### Combinación

Fusiona múltiples ValueListenables juntos:

- **[combineLatest()](/documentation/listen_it/operators/combine#combinelatest)** - Combina dos ValueListenables
- **[mergeWith()](/documentation/listen_it/operators/combine#mergewith)** - Fusiona múltiples ValueListenables

### Basados en Tiempo

Controla el timing de la propagación de valores:

- **[debounce()](/documentation/listen_it/operators/time#debounce)** - Solo propaga después de una pausa
- **[async()](/documentation/listen_it/operators/time#async)** - Difiere actualizaciones al siguiente frame

### Listening

Reacciona a cambios de valor:

- **listen()** - Instala una función handler que se llama en cada cambio de valor

## Patrón de Uso Básico

Todos los operators siguen un patrón similar:

```dart
final source = ValueNotifier<int>(0);

// Crear cadena de operators
final transformed = source
    .where((x) => x > 0)
    .map<String>((x) => x.toString())
    .debounce(Duration(milliseconds: 300));

// Usar con ValueListenableBuilder
ValueListenableBuilder<String>(
  valueListenable: transformed,
  builder: (context, value, _) => Text(value),
);

// O instalar un listener
transformed.listen((value, subscription) {
  print('Valor cambió a: $value');
});
```

### Con watch_it

watch_it v2.0+ proporciona caché automático de selectores, haciendo la creación de cadenas inline completamente segura:

<<< @/../code_samples/lib/listen_it/operators_watch_it.dart#example

El valor por defecto `allowObservableChange: false` cachea el selector, ¡así que la cadena se crea solo una vez!

[Aprende más sobre integración con watch_it →](/documentation/watch_it/getting_started)

## Patrones Comunes

### Transformar Luego Filtrar

```dart
final intNotifier = ValueNotifier<int>(0);

intNotifier
    .map((i) => i * 2)              // Duplicar el valor
    .where((i) => i > 10)            // Solo valores > 10
    .listen((value, _) => print(value));
```

### Seleccionar Luego Debounce

```dart
final userNotifier = ValueNotifier<User>(user);

userNotifier
    .select<String>((u) => u.searchTerm)  // Solo cuando searchTerm cambia
    .debounce(Duration(milliseconds: 300)) // Esperar pausa
    .listen((term, _) => search(term));
```

### Combinar Múltiples Fuentes

```dart
final source1 = ValueNotifier<int>(0);
final source2 = ValueNotifier<String>('');

source1
    .combineLatest<String, Result>(
      source2,
      (int i, String s) => Result(i, s),
    )
    .listen((result, _) => print(result));
```

## Gestión de Memoria

::: danger Importante
**Siempre** crea cadenas fuera de métodos build o usa watch_it para caché automático.

**❌️ NO HAGAS:**
```dart
Widget build(BuildContext context) {
  return ValueListenableBuilder(
    valueListenable: source.map((x) => x * 2), // ¡NUEVA CADENA EN CADA BUILD!
    builder: (context, value, _) => Text('$value'),
  );
}
```

**✅ HAZ:**
```dart
// Opción 1: Crear cadena como campo
late final chain = source.map((x) => x * 2);

Widget build(BuildContext context) {
  return ValueListenableBuilder(
    valueListenable: chain, // Mismo objeto en cada build
    builder: (context, value, _) => Text('$value'),
  );
}

// Opción 2: Usar watch_it (caché automático)
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final value = watchValue((Model m) => m.source.map((x) => x * 2));
    return Text('$value');
  }
}
```
:::

[Lee la guía completa de mejores prácticas →](/documentation/listen_it/best_practices)

## Próximos Pasos

- [Aprende sobre operators de transformación →](/documentation/listen_it/operators/transform)
- [Aprende sobre operators de filtrado →](/documentation/listen_it/operators/filter)
- [Aprende sobre operators de combinación →](/documentation/listen_it/operators/combine)
- [Aprende sobre operators basados en tiempo →](/documentation/listen_it/operators/time)
- [Usando operators con watch_it →](/documentation/watch_it/watching_multiple_values)
