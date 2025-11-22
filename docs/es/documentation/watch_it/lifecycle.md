# Funciones de Ciclo de Vida

## callOnce() y onDispose()

Ejecuta una función solo en la primera construcción (incluso en un StatelessWidget), con handler de dispose opcional.

**Firmas del método:**

```dart
void callOnce(
  void Function(BuildContext context) init,
  {void Function()? dispose}
);

void onDispose(void Function() dispose);
```

**Caso de uso típico:** Disparar carga de datos en la primera construcción, luego mostrar resultados con `watchValue`:

<<< @/../code_samples/lib/watch_it/lifecycle_call_once_example.dart#example

## callOnceAfterThisBuild()

Ejecuta un callback una vez después de que se complete la construcción actual. A diferencia de `callOnce()` que se ejecuta inmediatamente durante la construcción, esto se ejecuta en un callback post-frame.

**Firma del método:**

```dart
void callOnceAfterThisBuild(
  void Function(BuildContext context) callback
);
```

**Perfecto para:**
- Navegación después de que las dependencias async estén listas
- Mostrar diálogos o snackbars después del renderizado inicial
- Acceder a dimensiones de RenderBox
- Operaciones que no deberían ejecutarse durante la construcción

**Comportamiento clave:**
- Se ejecuta una vez después de la primera construcción donde se llama esta función
- Se ejecuta en un callback post-frame (después de layout y paint)
- Seguro de usar dentro de condicionales - se ejecutará una vez cuando la condición primero se vuelva verdadera
- No se ejecutará nuevamente en construcciones subsiguientes, incluso si se llama nuevamente

**Ejemplo - Navegar cuando las dependencias estén listas:**

<<< @/../code_samples/lib/watch_it/lifecycle_call_once_after_this_build_example.dart#example

**Contraste con callOnce:**
- `callOnce()`: Se ejecuta inmediatamente durante la construcción (síncrono)
- `callOnceAfterThisBuild()`: Se ejecuta después de que la construcción se complete (callback post-frame)

## callAfterEveryBuild()

Ejecuta un callback después de cada construcción. El callback recibe una función `cancel()` para detener invocaciones futuras.

**Firma del método:**

```dart
void callAfterEveryBuild(
  void Function(BuildContext context, void Function() cancel) callback
);
```

**Casos de uso:**
- Actualizar posición de scroll después de reconstrucciones
- Reposicionar overlays o tooltips
- Realizar mediciones después de cambios de layout
- Sincronizar animaciones con estado de reconstrucción

**Ejemplo - Scroll al principio con cancel:**

<<< @/../code_samples/lib/watch_it/lifecycle_call_after_every_build_example.dart#example

**Importante:**
- El callback se ejecuta después de CADA reconstrucción
- Usa `cancel()` para detener cuando ya no sea necesario
- Se ejecuta en callback post-frame (después de que el layout se complete)

## createOnce y createOnceAsync

Crea un objeto en la primera construcción que se dispone automáticamente cuando el widget se destruye. Ideal para todos los tipos de controllers (`TextEditingController`, `AnimationController`, `ScrollController`, etc.) o estado reactivo local (`ValueNotifier`, `ChangeNotifier`).

**Firmas del método:**

```dart
T createOnce<T extends Object>(
  T Function() factoryFunc,
  {void Function(T)? dispose}
);

AsyncSnapshot<T> createOnceAsync<T>(
  Future<T> Function() factoryFunc,
  {required T initialValue, void Function(T)? dispose}
);
```

<<< @/../code_samples/lib/watch_it/lifecycle_create_once_example.dart#example

**Cómo funciona:**
- En la primera construcción, el objeto se crea con `factoryFunc`
- En construcciones subsiguientes, se retorna la misma instancia
- Cuando el widget se dispone:
  - Si el objeto tiene un método `dispose()`, se llama automáticamente
  - Si necesitas una función de dispose diferente (como `cancel()` en StreamSubscription), pásala como el parámetro `dispose`

**Crear estado local con ValueNotifier:**

<<< @/../code_samples/lib/watch_it/watch_create_once_local_state.dart#example

## createOnceAsync

Ideal para llamadas de función async de una sola vez para mostrar datos, por ejemplo desde algún endpoint backend.

**Firma completa:**

```dart
AsyncSnapshot<T> createOnceAsync<T>(
  Future<T> Function() factoryFunc,
  {required T initialValue, void Function(T)? dispose}
);
```

**Cómo funciona:**
- Retorna `AsyncSnapshot<T>` inmediatamente con `initialValue`
- Ejecuta `factoryFunc` asincrónicamente en la primera construcción
- El widget se reconstruye automáticamente cuando el future se completa
- `AsyncSnapshot` contiene el estado (loading, data, error)
- El objeto se dispone cuando el widget se destruye

<<< @/../code_samples/lib/watch_it/lifecycle_create_once_async_example.dart#example
