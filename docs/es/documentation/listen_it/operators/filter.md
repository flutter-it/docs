# Operator de Filtrado

El operator `where()` filtra valores basándose en una función predicado, propagando solo los valores que pasan la prueba.

## where()

Crea un ValueListenable filtrado que solo notifica cuando los valores pasan la prueba del predicado.

### Firma

```dart
ValueListenable<T> where(
  bool Function(T) selector, {
  T? fallbackValue,
})
```

**Parámetros:**
- `selector` - Función predicado que determina si un valor debe propagarse
- `fallbackValue` - Valor de fallback opcional a usar como valor inicial si el valor actual no pasa el predicado

### Uso Básico

<<< @/../code_samples/lib/listen_it/where_filter.dart#example

### Cómo Funciona

La función predicado se llama para cada valor de la fuente. Solo los valores donde el predicado devuelve `true` se propagan a los listeners.

```dart
final numbers = ValueNotifier<int>(1);

final evenNumbers = numbers.where((n) => n.isEven);

evenNumbers.listen((value, _) => print('Even: $value'));

numbers.value = 2; // Imprime: Even: 2
numbers.value = 3; // Sin salida (filtrado)
numbers.value = 4; // Imprime: Even: 4
numbers.value = 5; // Sin salida (filtrado)
```

### Casos de Uso Comunes

::: details Validación

```dart
final input = ValueNotifier<String>('');

// Solo propagar strings no vacíos
final validInput = input.where((text) => text.isNotEmpty);

// Solo propagar strings que cumplan requisito de longitud
final longEnoughInput = input.where((text) => text.length >= 3);
```
:::

::: details Filtrado Basado en Estado

```dart
class AppState {
  final bool isOnline;
  final String data;

  AppState(this.isOnline, this.data);
}

final appState = ValueNotifier<AppState>(AppState(true, ''));

// Solo propagar cuando esté online
final onlineData = appState.where((state) => state.isOnline);
```
:::

::: details Filtrado de Rango

```dart
final temperature = ValueNotifier<double>(20.0);

// Solo alertar en temperaturas altas
final highTemp = temperature.where((temp) => temp > 30.0);

highTemp.listen((temp, _) => showAlert('Temperatura alta: $temp'));
```
:::

::: details Combinando Condiciones

```dart
final userAge = ValueNotifier<int>(0);

// Múltiples condiciones
final eligibleAge = userAge.where((age) {
  return age >= 18 && age <= 65;
});
```
:::

### Predicados Dinámicos

El predicado puede referenciar estado externo:

```dart
bool onlyEven = true;

final numbers = ValueNotifier<int>(0);

// El predicado referencia variable externa
final filtered = numbers.where((n) => onlyEven ? n.isEven : true);

// Inicialmente filtra a números pares
numbers.value = 2; // Pasa
numbers.value = 3; // Bloqueado

// Cambiar filtro
onlyEven = false;

// Ahora todos los números pasan
numbers.value = 5; // Pasa
```

### Comportamiento de Valor Inicial

Por defecto, si el valor actual de la fuente no pasa el predicado, aún se convierte en el valor inicial:

```dart
final numbers = ValueNotifier<int>(1); // Número impar

final evenNumbers = numbers.where((n) => n.isEven);

print(evenNumbers.value); // 1 (valor inicial, ¡aunque es impar!)

numbers.value = 2; // Pasa filtro (par)
numbers.value = 3; // Bloqueado (impar)
print(evenNumbers.value); // Todavía 2
```

### Usando fallbackValue

Para manejar casos donde el valor inicial no pasa el predicado, proporciona un `fallbackValue`:

```dart
final numbers = ValueNotifier<int>(1); // Número impar

// Proporcionar fallback para cuando el valor inicial no pasa
final evenNumbers = numbers.where(
  (n) => n.isEven,
  fallbackValue: 0,  // Usar 0 si el valor actual es impar
);

print(evenNumbers.value); // 0 (¡fallback usado!)

numbers.value = 2; // Pasa filtro (par)
print(evenNumbers.value); // 2

numbers.value = 3; // Bloqueado (impar)
print(evenNumbers.value); // Todavía 2 (no 0 - fallback solo se usa en la creación)
```

### Ejemplos Prácticos de fallbackValue

::: details Entrada de Búsqueda con Longitud Mínima

```dart
final searchTerm = ValueNotifier<String>('');

// Usar string vacío como fallback cuando el término de búsqueda es muy corto
final validSearchTerm = searchTerm.where(
  (term) => term.length >= 3,
  fallbackValue: '',
);

validSearchTerm
    .debounce(Duration(milliseconds: 300))
    .listen((term, _) {
      if (term.isEmpty) {
        clearSearchResults();
      } else {
        performSearch(term);
      }
    });
```
:::

::: details Validación de Edad

```dart
final userAge = ValueNotifier<int>(0);

// Usar 0 como fallback para edades inválidas
final adultAge = userAge.where(
  (age) => age >= 18,
  fallbackValue: 0,
);

adultAge.listen((age, _) {
  if (age == 0) {
    showMessage('Debe ser mayor de 18 años');
  } else {
    enableFeature();
  }
});
```
:::

::: details Alertas de Temperatura

```dart
final temperature = ValueNotifier<double>(20.0);

// Usar temperatura segura como fallback
final dangerousTemp = temperature.where(
  (temp) => temp > 35.0 || temp < 5.0,
  fallbackValue: 20.0,  // Temperatura normal
);

dangerousTemp.listen((temp, _) {
  if (temp != 20.0) {
    showTemperatureAlert(temp);
  }
});
```
:::

### Encadenando con Otros Operators

`where()` se encadena comúnmente con operators de transformación:

```dart
final input = ValueNotifier<String>('');

input
    .where((text) => text.length >= 3)      // Mínimo 3 caracteres
    .map((text) => text.toUpperCase())       // Transformar a mayúsculas
    .debounce(Duration(milliseconds: 300))  // Debounce
    .listen((text, _) => search(text));
```

### where() vs select()

| Característica | where() | select() |
|---------|---------|----------|
| **Propósito** | Filtrar valores | Reaccionar a cambios de propiedad |
| **Notifica cuando** | El predicado devuelve true | El valor seleccionado cambia |
| **Valor inicial** | Siempre pasa | Comportamiento normal |
| **Usar para** | Propagación condicional | Actualizaciones específicas de propiedad |

```dart
final user = ValueNotifier<User>(User(age: 16));

// where() - filtra basándose en condición
final adults = user.where((u) => u.age >= 18);
// No notificará para actualizaciones de edad 16, 17

// select() - reacciona a cambios de edad
final age = user.select<int>((u) => u.age);
// Notifica para cada cambio de edad
```

### Cuándo Usar where()

Usa `where()` cuando:
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Necesites filtrar valores basándote en condiciones</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Solo quieras reaccionar a ciertos valores</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Estés implementando lógica de validación</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Necesites filtrar basándote en estado de tiempo de ejecución</li>
</ul>

## Ejemplo del Mundo Real

Entrada de búsqueda con requisito de longitud mínima:

```dart
final searchTerm = ValueNotifier<String>('');

// Sin fallbackValue (compatible hacia atrás)
searchTerm
    .where((term) => term.length >= 3)     // Al menos 3 caracteres
    .debounce(Duration(milliseconds: 300))  // Esperar pausa de escritura
    .listen((term, _) => performSearch(term));

// Con fallbackValue (recomendado para lógica más limpia)
searchTerm
    .where(
      (term) => term.length >= 3,
      fallbackValue: '',  // Indicador claro cuando no hay búsqueda
    )
    .debounce(Duration(milliseconds: 300))
    .listen((term, _) {
      if (term.isEmpty) {
        clearResults();
      } else {
        performSearch(term);
      }
    });
```

## Próximos Pasos

- [Aprende sobre operators de transformación →](/documentation/listen_it/operators/transform)
- [Aprende sobre operators de combinación →](/documentation/listen_it/operators/combine)
- [Aprende sobre operators basados en tiempo →](/documentation/listen_it/operators/time)
