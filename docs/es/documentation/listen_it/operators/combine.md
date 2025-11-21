# Operators de Combinación

Los operators de combinación te permiten fusionar múltiples ValueListenables en un único observable, actualizándose cuando cualquier fuente cambia.

## combineLatest()

Combina dos ValueListenables usando una función combinadora. El resultado se actualiza cuando cualquiera de las fuentes cambia.

### Uso Básico

<<< @/../code_samples/lib/listen_it/combine_latest.dart#example

### Cómo Funciona

`combineLatest()` crea un nuevo ValueListenable que:
1. Mantiene el último valor de ambas fuentes
2. Llama a la función combinadora cuando cualquiera de las fuentes cambia
3. Notifica a los listeners con el resultado combinado

### Parámetros de Tipo

`combineLatest<TIn2, TOut>()` recibe dos parámetros de tipo:
- `TIn2` - Tipo del segundo ValueListenable
- `TOut` - Tipo del resultado combinado

```dart
final ageNotifier = ValueNotifier<int>(25);
final nameNotifier = ValueNotifier<String>('John');

// Combinar int y String en un tipo personalizado
final user = ageNotifier.combineLatest<String, User>(
  nameNotifier,
  (int age, String name) => User(age: age, name: name),
);
```

### Casos de Uso Comunes

::: details Validación de Formularios

```dart
final email = ValueNotifier<String>('');
final password = ValueNotifier<String>('');

final isValid = email.combineLatest<String, bool>(
  password,
  (e, p) => e.contains('@') && p.length >= 8,
);

ValueListenableBuilder<bool>(
  valueListenable: isValid,
  builder: (context, valid, _) => ElevatedButton(
    onPressed: valid ? _submit : null,
    child: Text('Submit'),
  ),
);
```
:::

::: details Valores Computados

```dart
final quantity = ValueNotifier<int>(1);
final price = ValueNotifier<double>(9.99);

final total = quantity.combineLatest<double, double>(
  price,
  (qty, p) => qty * p,
);

print(total.value); // 9.99

quantity.value = 3;
print(total.value); // 29.97
```
:::

::: details UI Condicional

```dart
final isDarkMode = ValueNotifier<bool>(false);
final fontSize = ValueNotifier<double>(14.0);

final textStyle = isDarkMode.combineLatest<double, TextStyle>(
  fontSize,
  (dark, size) => TextStyle(
    color: dark ? Colors.white : Colors.black,
    fontSize: size,
  ),
);
```
:::

::: details Estado de Múltiples Fuentes

```dart
final isLoading = ValueNotifier<bool>(false);
final hasError = ValueNotifier<bool>(false);

final uiState = isLoading.combineLatest<bool, UIState>(
  hasError,
  (loading, error) {
    if (loading) return UIState.loading;
    if (error) return UIState.error;
    return UIState.ready;
  },
);
```
:::

### Combinando Más de Dos Fuentes

Para combinar 3-6 ValueListenables, usa `combineLatest3` hasta `combineLatest6`:

```dart
final source1 = ValueNotifier<int>(1);
final source2 = ValueNotifier<int>(2);
final source3 = ValueNotifier<int>(3);

final sum = source1.combineLatest3<int, int, int>(
  source2,
  source3,
  (a, b, c) => a + b + c,
);

print(sum.value); // 6
```

Similarmente disponibles: `combineLatest4`, `combineLatest5`, `combineLatest6`

### Cuándo Usar combineLatest()

Usa `combineLatest()` cuando:
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Necesites valores de 2-6 ValueListenables</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Quieras actualizar cuando cualquier fuente cambie</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Necesites combinar valores en un nuevo tipo</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Estés implementando estado derivado o propiedades computadas</li>
</ul>

## mergeWith()

Fusiona cambios de valor de múltiples ValueListenables del mismo tipo. Se actualiza cuando cualquier fuente cambia, emitiendo el valor de esa fuente.

### Uso Básico

<<< @/../code_samples/lib/listen_it/merge_with.dart#example

### Cómo Funciona

`mergeWith()` crea un nuevo ValueListenable que:
1. Se suscribe a la fuente principal y todas las fuentes en la lista
2. Cuando cualquier fuente cambia, emite el valor actual de esa fuente
3. Todas las fuentes deben ser del mismo tipo

```dart
final source1 = ValueNotifier<int>(1);
final source2 = ValueNotifier<int>(2);
final source3 = ValueNotifier<int>(3);

final merged = source1.mergeWith([source2, source3]);

print(merged.value); // 1 (valor inicial de source1)

source2.value = 20;
print(merged.value); // 20 (source2 cambió)

source3.value = 30;
print(merged.value); // 30 (source3 cambió)

source1.value = 10;
print(merged.value); // 10 (source1 cambió)
```

### Casos de Uso Comunes

::: details Múltiples Fuentes de Eventos

```dart
final userInput = ValueNotifier<String>('');
final apiResult = ValueNotifier<String>('');
final cacheData = ValueNotifier<String>('');

// Reaccionar a actualizaciones de cualquier fuente
final dataStream = userInput.mergeWith([apiResult, cacheData]);

dataStream.listen((data, _) => updateUI(data));
```
:::

::: details Múltiples Disparadores

```dart
final saveButton = ValueNotifier<DateTime?>(null);
final autoSave = ValueNotifier<DateTime?>(null);
final shortcutKey = ValueNotifier<DateTime?>(null);

// Guardar disparado por cualquier acción
final saveTrigger = saveButton.mergeWith([autoSave, shortcutKey]);

saveTrigger.listen((timestamp, _) {
  if (timestamp != null) performSave();
});
```
:::

::: details Agregando Fuentes Similares

```dart
final sensor1 = ValueNotifier<double>(0.0);
final sensor2 = ValueNotifier<double>(0.0);
final sensor3 = ValueNotifier<double>(0.0);

// Monitorear cualquier cambio de sensor
final anySensorChange = sensor1.mergeWith([sensor2, sensor3]);

anySensorChange.listen((value, _) => checkThreshold(value));
```
:::

### combineLatest() vs mergeWith()

| Característica | combineLatest() | mergeWith() |
|---------|-----------------|-------------|
| **Número de fuentes** | 2-6 | 1 + N (array) |
| **Tipos de fuentes** | Pueden ser diferentes | Deben ser del mismo tipo |
| **Tipo de salida** | Personalizado (vía combinador) | Mismo tipo que la fuente |
| **Usar para** | Combinar valores diferentes | Fusionar eventos similares |
| **Valor de salida** | Resultado de la función combinadora | Valor de la fuente que cambió |

**Ejemplo: Dos estados de carga**

```dart
final isLoadingData = ValueNotifier<bool>(false);
final isLoadingUser = ValueNotifier<bool>(false);

// combineLatest - combina ambos valores con lógica (operación OR)
final isLoading = isLoadingData.combineLatest<bool, bool>(
  isLoadingUser,
  (dataLoading, userLoading) => dataLoading || userLoading,
);

isLoadingData.value = true;
print(isLoading.value); // true (datos cargando)

isLoadingUser.value = true;
print(isLoading.value); // true (ambos cargando)

isLoadingData.value = false;
print(isLoading.value); // true (usuario aún cargando)

// mergeWith - solo toma el que cambió
final anyLoading = isLoadingData.mergeWith([isLoadingUser]);

isLoadingData.value = true;
print(anyLoading.value); // true (de isLoadingData)

isLoadingUser.value = false;
print(anyLoading.value); // false (de isLoadingUser - ¡no es lo que quieres!)

isLoadingData.value = false;
print(anyLoading.value); // false (de isLoadingData)
```

**Diferencia clave:** `combineLatest()` aplica lógica a **ambos** valores, mientras que `mergeWith()` solo emite la fuente que cambió - ¡haciéndolo incorrecto para este caso de uso!

### Cuándo Usar mergeWith()

Usa `mergeWith()` cuando:
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Tengas múltiples fuentes del mismo tipo</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Quieras reaccionar a cambios de cualquier fuente</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ No necesites combinar valores, solo monitorear cualquier cambio</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Estés agregando streams de eventos similares</li>
</ul>

## Encadenando con Otros Operators

Los operators de combinación funcionan bien con otros operators:

```dart
final firstName = ValueNotifier<String>('');
final lastName = ValueNotifier<String>('');

firstName
    .combineLatest<String, String>(
      lastName,
      (first, last) => '$first $last',
    )
    .where((name) => name.trim().isNotEmpty)
    .map((name) => name.toUpperCase())
    .listen((name, _) => print(name));
```

## Ejemplo del Mundo Real

Total de carrito de compras con impuestos:

```dart
final subtotal = ValueNotifier<double>(0.0);
final taxRate = ValueNotifier<double>(0.1);

final total = subtotal.combineLatest<double, double>(
  taxRate,
  (sub, rate) => sub * (1 + rate),
);

// Usar en UI
ValueListenableBuilder<double>(
  valueListenable: total,
  builder: (context, value, _) => Text('Total: \$${value.toStringAsFixed(2)}'),
);
```

## Próximos Pasos

- [Aprende sobre operators de transformación →](/documentation/listen_it/operators/transform)
- [Aprende sobre operators de filtrado →](/documentation/listen_it/operators/filter)
- [Aprende sobre operators basados en tiempo →](/documentation/listen_it/operators/time)
