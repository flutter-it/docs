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

### Ciclo de Vida de la Cadena

Las cadenas de operators se suscriben a su fuente al crearse, **se desconectan cuando se elimina su último listener** y se reconectan con el siguiente. Mientras están desconectadas, `.value` se deriva del valor actual de la fuente al leerlo, así que nunca está obsoleto:

```dart
final source = ValueNotifier<int>(5);
final mapped = source.map((x) => x * 2);

print(mapped.value); // 10

source.value = 7;
print(mapped.value); // 14 ✅ - correcto con o sin listeners
```

Pasa `lazy: true` para retrasar la primera suscripción hasta que se añada el primer listener - una optimización pura de memoria, `.value` sigue siendo correcto:

```dart
final lazy = source.map((x) => x * 2, lazy: true);
print(lazy.value); // derivado al leer, aún sin suscripción
```

::: tip Mantén las Transformaciones Puras
La transformación puede ejecutarse al leer mientras la cadena está desconectada, así que las funciones de transformación no deben tener efectos secundarios.

Mira la [guía de mejores prácticas](/es/documentation/listen_it/best_practices#ciclo-de-vida-de-cadenas) para el ciclo de vida completo.
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

watch_it cachea el selector, así que crear una cadena inline en un selector es seguro - se crea una vez por instancia de widget y se desconecta de su fuente cuando el widget se dispone:

<<< @/../code_samples/lib/listen_it/operators_watch_it.dart#example

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

::: warning Importante
Crea las cadenas una sola vez - fuera de métodos build o dentro de un selector de watch_it. Una cadena creada en `build()` es un objeto nuevo en cada reconstrucción; se desconecta en cuanto pierde sus listeners, así que no hay fuga, pero hace trabajo innecesario.

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
