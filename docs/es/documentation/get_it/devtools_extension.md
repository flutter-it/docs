---
title: Extensión DevTools
prev:
  text: 'Pruebas'
  link: '/es/documentation/get_it/testing'
next:
  text: 'Flutter Previews'
  link: '/es/documentation/get_it/flutter_previews'
---

<div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 2rem;">
  <img src="/images/get_it.svg" alt="get_it logo" width="100" />
  <h1 style="margin: 0;">Extensión DevTools</h1>
</div>

**`get_it`** incluye una extensión de DevTools que te permite visualizar e inspeccionar todos los objetos registrados en tu app Flutter en ejecución en tiempo real.

<strong>Características clave:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Ver todos los registros</strong> - Ve cada objeto registrado en `get_it` a través de todos los scopes</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Inspeccionar estado de instancia</strong> - Ve la salida de toString() de instancias creadas</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Rastrear detalles de registro</strong> - Tipo, scope, modo, estado async, estado ready, estado de creación</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Actualizaciones en tiempo real</strong> - Se refresca automáticamente cuando los registros cambian (con eventos de depuración habilitados)</li>
</ul>

---

## Configuración

### 1. Habilita Eventos de Depuración

En el `main.dart` de tu app, habilita los eventos de depuración antes de ejecutar tu app:

```dart
void main() {
  GetIt.instance.debugEventsEnabled = true;

  // ... configura tus dependencias
  configureDependencies();

  runApp(MyApp());
}
```

::: tip ¿Por Qué Habilitar Eventos de Depuración?
Cuando `debugEventsEnabled` es `true`, `get_it` envía eventos a DevTools cada vez que los registros cambian, permitiendo que la extensión se actualice automáticamente. Sin esto, necesitarás refrescar manualmente la extensión para ver cambios.
:::

::: warning Solo Modo Debug
La extensión DevTools solo funciona en modo debug. En builds de release, la extensión no está disponible y los eventos de depuración no tienen efecto.
:::

### 2. Ejecuta Tu App en Modo Debug

```bash
flutter run
```

### 3. Abre DevTools en el Navegador

La extensión de `get_it` actualmente **solo funciona en DevTools basado en navegador**, no en DevTools embebido en IDE.

Cuando ejecutes tu app, Flutter mostrará un mensaje como:

```
The Flutter DevTools debugger and profiler is available at: http://127.0.0.1:9100
```

Abre esa URL en tu navegador.

### 4. Habilita la Extensión

1. En DevTools, haz clic en el botón **Extensions** (ícono de pieza de rompecabezas) en la esquina superior derecha
2. Encuentra la extensión `get_it` en la lista y habilítala
3. La pestaña "get_it" aparecerá en la navegación principal de DevTools

### 5. Abre la Pestaña get_it

Haz clic en la pestaña "get_it" para ver todos tus registros.

---

## Entendiendo la Tabla de Registros

La extensión DevTools muestra todos los objetos registrados en una tabla con las siguientes columnas:

![Extensión DevTools de get_it](/images/get_it_devtools_extension.png)
*La extensión DevTools de get_it mostrando todos los objetos registrados en una app en ejecución*

| Columna | Descripción |
|--------|-------------|
| **Type** | El tipo registrado (nombre de clase) |
| **Instance Name** | El nombre de instancia si se usan registros con nombre, de lo contrario vacío |
| **Scope** | El scope al que pertenece este registro (ej., `baseScope` para el scope por defecto) |
| **Mode** | El tipo de registro: `constant` (singleton), `lazy` (lazy singleton), `alwaysNew` (factory), o `cachedFactory` |
| **Async** | Si este es un registro async (`true` para `registerSingletonAsync` y `registerLazySingletonAsync`) |
| **Ready** | Para registros async, si la inicialización está completa |
| **Created** | Si la instancia ha sido creada (false para registros lazy que no han sido accedidos aún) |
| **Instance Details** | La salida de `toString()` de la instancia (si está creada) |

---

## Haciendo los Detalles de Instancia Significativos

Por defecto, el `toString()` de Dart solo muestra el nombre del tipo e ID de instancia (ej., `Instance of 'UserRepository'`). Para ver detalles significativos en la extensión DevTools, **sobrescribe `toString()` en tus clases registradas**:

```dart
class UserRepository {
  final String userId;
  final bool isAuthenticated;

  UserRepository(this.userId, this.isAuthenticated);

  @override
  String toString() {
    return 'UserRepository(userId: $userId, isAuthenticated: $isAuthenticated)';
  }
}
```

Ahora en DevTools, verás:
```
UserRepository(userId: user123, isAuthenticated: true)
```

### Consejos para Buenas Implementaciones de toString()

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Incluye estado clave</strong> - Muestra las propiedades más importantes que te ayudan a entender el estado actual del objeto</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Mantenlo conciso</strong> - Strings largos son difíciles de leer en la tabla. Limítate a la información esencial</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Usa nombres descriptivos</strong> - Haz obvio qué representa cada valor</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Incluye estados enum</strong> - Si tu objeto tiene estados o modos, inclúyelos</li>
</ul>

**Ejemplo para un reproductor de medios:**

```dart
class PlayerManager {
  bool isPlaying;
  String? currentTrack;
  Duration position;
  Duration duration;

  @override
  String toString() {
    final posStr = '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}';
    final durStr = '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

    return 'PlayerManager('
        'playing: $isPlaying, '
        'track: ${currentTrack ?? 'none'}, '
        'position: $posStr/$durStr'
        ')';
  }
}
```

Esto muestra: `PlayerManager(playing: true, track: My Song, position: 2:34/4:15)`

---

## Refrescando la Vista

- **Con eventos de depuración habilitados**: La vista se actualiza automáticamente cuando los registros cambian
- **Sin eventos de depuración**: Haz clic en el botón **Refresh** en la extensión para actualizar manualmente la vista
- **Refresco manual**: Siempre puedes hacer clic en Refresh para asegurar que estás viendo el estado más reciente

---

## Solución de Problemas

### La pestaña get_it no aparece

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">➜ Asegúrate de estar usando <strong>DevTools basado en navegador</strong>, no DevTools embebido en IDE</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">➜ Verifica que la extensión esté <strong>habilitada</strong> en el menú Extensions (ícono de pieza de rompecabezas)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">➜ Asegura que tu app esté ejecutándose en <strong>modo debug</strong></li>
</ul>

### La extensión no muestra registros

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">➜ Asegúrate de haber <strong>registrado objetos</strong> realmente en tu app</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">➜ Haz clic en el <strong>botón Refresh</strong> para actualizar manualmente la vista</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">➜ Verifica que estés viendo la <strong>instancia correcta de DevTools</strong> para tu app en ejecución</li>
</ul>

### La extensión no se auto-actualiza

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">➜ Verifica que <code>debugEventsEnabled = true</code> esté establecido <strong>antes</strong> de cualquier registro</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">➜ Usa el <strong>botón Refresh</strong> manual si las actualizaciones automáticas no funcionan</li>
</ul>

---

## Casos de Uso

### Durante el Desarrollo

- **Verificar registros** - Asegura que todos los servicios requeridos están registrados al inicio
- **Depurar inicialización** - Verifica qué async singletons están ready
- **Inspeccionar estado** - Ve el estado actual de tus servicios y modelos
- **Entender scopes** - Ve qué objetos pertenecen a qué scope

### Durante las Pruebas

- **Verificar configuración de prueba** - Asegura que los mocks están registrados correctamente
- **Depurar pruebas inestables** - Verifica si los objetos se están creando múltiples veces
- **Aislamiento de scope** - Verifica que los scopes de prueba funcionan como se espera

### Durante la Depuración

- **Rastrear bugs** - Inspecciona el estado del servicio cuando ocurren bugs
- **Verificar ciclo de vida** - Verifica si los lazy singletons se crean cuando se espera
- **Monitorear cambios** - Observa cómo cambian los registros mientras navegas tu app

---

## Aprende Más

- [Pruebas con get_it](/es/documentation/get_it/testing) - Aprende cómo probar tus registros de `get_it`
- [Scopes](/es/documentation/get_it/scopes) - Entiende cómo funcionan los scopes
- [Objetos Asíncronos](/es/documentation/get_it/async_objects) - Aprende sobre inicialización async
- [Documentación Oficial de Flutter DevTools](https://docs.flutter.dev/tools/devtools/extensions)
