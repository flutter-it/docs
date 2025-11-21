---
title: Registros Múltiples
---

# Registros Múltiples

`get_it` proporciona dos enfoques diferentes para registrar múltiples instancias del mismo tipo, cada uno adecuado para diferentes casos de uso.

## Resumen de Dos Enfoques

### Enfoque 1: Registro con Nombre (Siempre Disponible)

Registra múltiples instancias del mismo tipo dándole a cada una un nombre único. Esto está <strong>siempre disponible</strong> sin ninguna configuración.


<<< @/../code_samples/lib/get_it/api_client_example_1.dart#example

<strong>Mejor para:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Diferentes configuraciones del mismo tipo (endpoints dev/prod)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Conjunto conocido de instancias accedidas individualmente</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Feature flags (implementación antigua/nueva)</li>
</ul>

### Enfoque 2: Registros Múltiples Sin Nombre (Requiere Opt-In)

Registra múltiples instancias sin nombres y recupéralas todas de una vez con `getAll<T>()`. Requiere opt-in explícito.


<<< @/../code_samples/lib/get_it/plugin.dart#example

<strong>Mejor para:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Sistemas de plugins (los módulos pueden añadir implementaciones)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Patrones de observer/event handler</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Cadenas de middleware</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Cuando no necesitas acceder a instancias individualmente</li>
</ul>

::: tip Puedes Combinar Ambos Enfoques
Los registros con nombre y sin nombre pueden coexistir. `getAll<T>()` devuelve ambos, instancias con nombre y sin nombre.
:::

---

## Registro con Nombre

Todas las funciones de registro aceptan un parámetro `instanceName` opcional. Cada nombre debe ser <strong>único por tipo</strong>.

### Uso Básico


<<< @/../code_samples/lib/get_it/rest_service_example.dart#example

### Funciona con Todos los Tipos de Registro

El registro con nombre funciona con <strong>cada</strong> método de registro:


<<< @/../code_samples/lib/get_it/logger_example_2.dart#example

### Casos de Uso de Registro con Nombre

<strong>Múltiples conexiones a base de datos:</strong>

<<< @/../code_samples/lib/get_it/code_sample_41a16b51.dart#example

---

## Registros Múltiples Sin Nombre

Para sistemas de plugins, observers y middleware donde quieres recuperar <strong>todas</strong> las instancias de una vez sin conocer sus nombres.

### Habilitando Registros Múltiples

Por defecto, `get_it` <strong>previene</strong> registrar el mismo tipo múltiples veces (sin nombres de instancia diferentes) para detectar registros duplicados accidentales, que usualmente son bugs.

Para habilitar registros múltiples del mismo tipo, debes hacer opt-in explícitamente:


<<< @/../code_samples/lib/get_it/code_sample_980d7414.dart#example

<strong>¿Por qué opt-in explícito?</strong>
- <strong>Previene bugs</strong>: Registrar accidentalmente el mismo tipo dos veces usualmente es un error
- <strong>Protección contra cambios breaking</strong>: El código existente no se romperá por cambios de comportamiento no intencionados
- <strong>Intención clara</strong>: Hace obvio que estás usando el patrón de registro múltiple
- <strong>Tipado seguro</strong>: Te fuerza a ser consciente de que el comportamiento de `get<T>()` cambia

::: warning Importante
Una vez habilitada, esta configuración aplica <strong>globalmente</strong> a toda la instancia de `get_it`. No puedes habilitarla solo para tipos específicos.

<strong>Esta característica no puede deshabilitarse una vez habilitada.</strong> Incluso llamar a `getIt.reset()` limpiará todos los registros pero mantendrá esta característica habilitada. Esto es intencional para prevenir cambios breaking accidentales en tu aplicación.
:::

---

## Registrando Múltiples Implementaciones

Después de llamar a `enableRegisteringMultipleInstancesOfOneType()`, puedes registrar el mismo tipo múltiples veces:


<<< @/../code_samples/lib/get_it/plugin_1.dart#example

::: tip Sin Nombre + Con Nombre Juntos
Todos los registros coexisten - tanto sin nombre como con nombre. `getAll<T>()` los devuelve todos.
:::

---

## Recuperando Instancias

### Usando `get<T>()` - Devuelve Solo la Primera

Cuando existen múltiples registros sin nombre, `get<T>()` devuelve <strong>solo la primera</strong> instancia registrada:


<<< @/../code_samples/lib/get_it/plugin_2.dart#example

::: tip Cuándo usar get()
Usa `get<T>()` cuando quieras la implementación "por defecto" o "primaria". ¡Regístrala primero!
:::

### Usando `getAll<T>()` - Devuelve Todas

Para recuperar <strong>todas</strong> las instancias registradas (tanto sin nombre como con nombre), usa `getAll<T>()`:


<<< @/../code_samples/lib/get_it/plugin_example.dart#example

::: tip Alternativa: findAll() para Descubrimiento Basado en Tipos
Mientras que `getAll<T>()` recupera instancias que has registrado explícitamente múltiples veces, `findAll<T>()` encuentra instancias por <strong>coincidencia de tipo</strong> - no se necesita configuración de registro múltiple. Mira [Relacionado: Encontrar Instancias por Tipo](#relacionado-encontrar-instancias-por-tipo) abajo para cuándo usar cada enfoque.
:::

---

## Comportamiento de Scope

`getAll<T>()` proporciona tres opciones de control de scope:

### Solo Scope Actual (Por Defecto)

Por defecto, busca solo en el <strong>scope actual</strong>:


<<< @/../code_samples/lib/get_it/plugin_3.dart#example

::: details Todos los Scopes

Para recuperar de <strong>todos los scopes</strong>, usa `fromAllScopes: true`:

<<< @/../code_samples/lib/get_it/code_sample_07af7c81.dart#example
:::

::: details Scope Nombrado Específico

Para buscar solo en un <strong>scope nombrado específico</strong>, usa `onlyInScope`:

<<< @/../code_samples/lib/get_it/code_sample_e4fa6049.dart#example
:::

::: tip Precedencia de Parámetros
Si se proporcionan tanto `onlyInScope` como `fromAllScopes`, `onlyInScope` tiene precedencia.
:::

Mira la [documentación de Scopes](/es/documentation/get_it/scopes) para más detalles sobre el comportamiento de scope.

---

## Versión Async

Si tienes registros async, usa `getAllAsync<T>()` que espera a que todos los registros se completen:


<<< @/../code_samples/lib/get_it/code_sample_49d4b664.dart#example

::: details Con control de scope

`getAllAsync()` soporta los mismos parámetros de scope que `getAll()`:

<<< @/../code_samples/lib/get_it/code_sample_2cd2b1b0.dart#example
:::

---

## Patrones Comunes

### Sistema de Plugins


<<< @/../code_samples/lib/get_it/configure_dependencies_example_7.dart#example

::: details Event Handlers / Observers

<<< @/../code_samples/lib/get_it/on_app_started_example.dart#example
:::

::: details Cadenas de Middleware / Validator

<<< @/../code_samples/lib/get_it/setup_middleware_example.dart#example
:::

::: details Combinando Registros Sin Nombre y Con Nombre

<<< @/../code_samples/lib/get_it/setup_themes_example.dart#example
:::

---

## Mejores Prácticas

### ✅ Haz

- <strong>Habilita al inicio de la app</strong> antes de cualquier registro
- <strong>Registra la implementación más importante/por defecto primero</strong> (para `get<T>()`)
- <strong>Usa clases base abstractas</strong> como tipos de registro
- <strong>Documenta dependencias de orden</strong> si el orden de middleware/observer importa
- <strong>Usa registros con nombre</strong> para implementaciones de propósito especial que también necesitan acceso individual

### ❌️ No Hagas

- <strong>No habilites a mitad de aplicación</strong> - hazlo durante la inicialización
- <strong>No confíes en `get<T>()`</strong> para recuperar todas las implementaciones - usa `getAll<T>()`
- <strong>No asumas orden de registro</strong> a menos que lo controles
- <strong>No mezcles este patrón con `allowReassignment`</strong> - sirven para propósitos diferentes

---

## Eligiendo el Enfoque Correcto

| Característica | Registro con Nombre | Registro Múltiple Sin Nombre |
|---------|-------------------|------------------------------|
| <strong>Habilitar requerido</strong> | No | Sí (`enableRegisteringMultipleInstancesOfOneType()`) |
| <strong>Patrón de acceso</strong> | Individual por nombre: `get<T>(instanceName: 'name')` | Todas de una vez: `getAll<T>()` devuelve todas |
| <strong>Obtener una</strong> | `get<T>(instanceName: 'name')` | `get<T>()` devuelve la primera |
| <strong>Caso de uso</strong> | Diferentes configuraciones, feature flags | Sistemas de plugins, observers, middleware |
| <strong>Independencia de módulos</strong> | Debe conocer nombres de antemano | Los módulos pueden añadir implementaciones sin conocer las otras |
| <strong>Método de acceso</strong> | Nombres basados en String | Recuperación basada en tipo |

<strong>Cuándo usar registro con nombre:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Diferentes configuraciones (endpoints de API dev/prod)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Feature flags (implementación antigua/nueva)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Conjunto conocido de instancias accedidas individualmente</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Múltiples conexiones a base de datos</li>
</ul>

<strong>Cuándo usar registro múltiple sin nombre:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Arquitectura modular de plugins</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Patrón de observer/event handler</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Cadenas de middleware</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Pipeline de validators/processors</li>
</ul>

<strong>Combinando ambos enfoques:</strong>

Los registros con nombre y sin nombre funcionan juntos sin problemas:


<<< @/../code_samples/lib/get_it/plugin_4.dart#example

---

::: details Cómo Funciona

Esta sección explica los detalles internos de implementación. Entender esto es opcional para usar la característica.

**Estructura de Datos**

`get_it` mantiene dos listas separadas para cada tipo:

<<< @/../code_samples/lib/get_it/__type_registration_example.dart#example

Cuando llamas:
- `getIt.registerSingleton<T>(instance)` → añade a la lista `registrations`
- `getIt.registerSingleton<T>(instance, instanceName: 'name')` → añade al mapa `namedRegistrations`

**Por Qué `get<T>()` Devuelve Solo la Primera**

El método `get<T>()` recupera instancias usando esta lógica:

<<< @/../code_samples/lib/get_it/code_sample_ba79068a.dart#example

Por eso `get<T>()` solo devuelve el primer registro sin nombre, no todos.

**Por Qué `getAll<T>()` Devuelve Todas**

El método `getAll<T>()` combina ambas listas:

<<< @/../code_samples/lib/get_it/code_sample_b1321fa0.dart#example

Esto devuelve cada instancia registrada, sin importar si tiene nombre o no.

**Preservación de Orden**

- <strong>Registros sin nombre</strong>: Preservados en orden de registro (`List`)
- <strong>Registros con nombre</strong>: Preservados en orden de registro (`LinkedHashMap`)
- <strong>Orden de `getAll()`</strong>: Primero sin nombre (en orden), luego con nombre (en orden)

Esto es importante para patrones de middleware/observer donde el orden de ejecución importa.
:::

---

## Referencia de API

### Habilitar

| Método | Descripción |
|--------|-------------|
| `enableRegisteringMultipleInstancesOfOneType()` | Habilita registros múltiples sin nombre del mismo tipo |

### Recuperar

| Método | Descripción |
|--------|-------------|
| `get<T>()` | Devuelve <strong>primer</strong> registro sin nombre |
| `getAll<T>({fromAllScopes})` | Devuelve <strong>todos</strong> los registros (sin nombre + con nombre) |
| `getAllAsync<T>({fromAllScopes})` | Versión async, espera a registros async |

### Parámetros

| Parámetro | Tipo | Por Defecto | Descripción |
|-----------|------|---------|-------------|
| `fromAllScopes` | `bool` | `false` | Si es true, busca en todos los scopes en lugar de solo el actual |
| `onlyInScope` | `String?` | `null` | Si se proporciona, busca solo en el scope nombrado (tiene precedencia sobre `fromAllScopes`) |

---

## Relacionado: Encontrar Instancias por Tipo

Mientras que `getAll<T>()` recupera instancias que has registrado explícitamente múltiples veces, `findAll<T>()` ofrece un enfoque diferente: encontrar instancias por <strong>criterios de coincidencia de tipo</strong>.

<strong>Diferencias clave:</strong>

| Característica | `getAll<T>()` | `findAll<T>()` |
|---------|---------------|----------------|
| <strong>Propósito</strong> | Recuperar múltiples registros explícitos | Encontrar instancias por coincidencia de tipo |
| <strong>Requiere</strong> | `enableRegisteringMultipleInstancesOfOneType()` | Sin configuración especial |
| <strong>Coincide</strong> | Tipo exacto T (con nombres opcionales) | T y subtipos (configurable) |
| <strong>Rendimiento</strong> | Búsqueda O(1) en map | Búsqueda lineal O(n) |
| <strong>Caso de uso</strong> | Sistemas de plugins, registros múltiples conocidos | Encontrar implementaciones, pruebas, introspección |

<strong>Ejemplo de comparación:</strong>


<<< @/../code_samples/lib/get_it/i_logger.dart#example

::: tip Cuándo Usar Cada Uno
- Usa <strong>`getAll()`</strong> cuando explícitamente quieras múltiples instancias del mismo tipo y las recuperarás todas juntas
- Usa <strong>`findAll()`</strong> cuando quieras descubrir instancias por relación de tipo, especialmente para pruebas o depuración
:::

Mira la [documentación de findAll()](/documentation/get_it/advanced#find-all-instances-by-type-findall-t) para detalles comprehensivos sobre coincidencia de tipos, control de scope y opciones avanzadas de filtrado.

---

## Ver También

- [Scopes](/es/documentation/get_it/scopes) - Gestión jerárquica del ciclo de vida y registros específicos de scope
- [Registro de Objetos](/es/documentation/get_it/object_registration) - Diferentes tipos de registro (factories, singletons, etc.)
- [Objetos Asíncronos](/es/documentation/get_it/async_objects) - Usando `getAllAsync()` con registros async
- [Avanzado - findAll()](/documentation/get_it/advanced#find-all-instances-by-type-findall-t) - Descubrimiento de instancias basado en tipo
