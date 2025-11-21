---
title: Objetos Asíncronos
prev:
  text: 'Registro de Objetos'
  link: '/es/documentation/get_it/object_registration'
next:
  text: 'Scopes'
  link: '/es/documentation/get_it/scopes'
---

# Objetos Asíncronos

## Descripción General

GetIt proporciona soporte comprehensivo para creación e inicialización asíncrona de objetos. Esto es esencial para objetos que necesitan realizar operaciones async durante la creación (conexiones a base de datos, llamadas de red, I/O de archivos) o que dependen de que otros objetos async estén listos primero.

<strong>Capacidades clave:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong><a href="#async-factories">Async Factories</a></strong> - Crea nuevas instancias asíncronamente en cada acceso</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong><a href="#async-singletons">Async Singletons</a></strong> - Crea singletons con inicialización asíncrona</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong><a href="#gestion-de-dependencias">Gestión de Dependencias</a></strong> - Espera automáticamente a dependencias antes de la inicialización</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong><a href="#orquestacion-de-inicio">Orquestación de Inicio</a></strong> - Coordina secuencias complejas de inicialización</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong><a href="#senalizacion-manual-de-ready">Señalización Manual</a></strong> - Control detallado sobre el estado de listo</li>
</ul>

## Referencia Rápida

### Métodos de Registro Asíncrono

| Método | Cuándo se Crea | Cuántas Instancias | Tiempo de Vida | Mejor Para |
|--------|--------------|-------------------|----------|----------|
| [<strong>registerFactoryAsync</strong>](#registerfactoryasync) | Cada `getAsync()` | Muchas | Por solicitud | Operaciones async en cada acceso |
| [<strong>registerCachedFactoryAsync</strong>](#registercachedfactoryasync) | Primer acceso + después del GC | Reutilizado mientras está en memoria | Hasta que es recolectado por el GC | Optimización de rendimiento para operaciones async costosas |
| [<strong>registerSingletonAsync</strong>](#registersingletonasync) | Inmediatamente en el registro | Una | Permanente | Servicios a nivel de app con configuración async |
| [<strong>registerLazySingletonAsync</strong>](#registerlazysingleton) | Primer `getAsync()` | Una | Permanente | Servicios async costosos no siempre necesarios |
| [<strong>registerSingletonWithDependencies</strong>](#singletons-sincronos-con-dependencias) | Después de que las dependencias estén listas | Una | Permanente | Servicios que dependen de otros servicios |

## Async Factories

Las async factories crean una <strong>nueva instancia en cada llamada</strong> a `getAsync()` ejecutando una función factory asíncrona.

### registerFactoryAsync

Crea una nueva instancia cada vez que llamas `getAsync<T>()`.

<<< @/../code_samples/lib/get_it/register_factory_async_signature.dart#example

<strong>Parámetros:</strong>
- `factoryFunc` - Función async que crea y devuelve la instancia
- `instanceName` - Nombre opcional para registrar múltiples factories del mismo tipo

<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/async_factory_basic.dart#example

### registerCachedFactoryAsync

Como `registerFactoryAsync`, pero cachea la instancia con una referencia débil. Devuelve la instancia cacheada si todavía está en memoria; de lo contrario crea una nueva.

<<< @/../code_samples/lib/get_it/register_cached_factory_async_signature.dart#example

<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/async_cached_factory_example.dart#example

### Async Factories con Parámetros

Como las factories regulares, las async factories pueden aceptar hasta dos parámetros.

<<< @/../code_samples/lib/get_it/async_factory_param_signatures.dart#example

<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/async_factory_param_example.dart#example

## Async Singletons

Los async singletons se crean una vez con inicialización asíncrona y viven durante el tiempo de vida del registro (hasta que se desregistren o se haga pop del scope).

### registerSingletonAsync

Registra un singleton con una función factory async que se ejecuta <strong>inmediatamente</strong>. El singleton se marca como listo cuando la función factory se completa (a menos que `signalsReady` sea true).

<<< @/../code_samples/lib/get_it/register_singleton_async_signature.dart#example

<strong>Parámetros:</strong>
- `factoryFunc` - Función async que crea la instancia singleton
- `instanceName` - Nombre opcional para registrar múltiples singletons del mismo tipo
- `dependsOn` - Lista de tipos de los que depende este singleton (espera a que estén listos primero)
- `signalsReady` - Si es true, debes llamar manualmente a `signalReady()` para marcar como listo
- `dispose` - Función de limpieza opcional llamada al desregistrar o resetear
- `onCreated` - Callback opcional invocado después de que la instancia es creada

<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/async_singleton_example.dart#example

::: details Error Común: Usando signalsReady con registerSingletonAsync
<strong>La mayoría del tiempo, NO necesitas `signalsReady: true` con `registerSingletonAsync`.</strong>

La completación de la factory async <strong>automáticamente señaliza ready</strong> cuando retorna. Solo usa `signalsReady: true` si necesitas inicialización multi-etapa donde la factory se completa pero tienes trabajo async adicional antes de que la instancia esté verdaderamente lista.

<strong>Patrón de error común:</strong>

<<< @/../code_samples/lib/get_it/signal_ready_error_example.dart#example

<strong>Por qué falla:</strong> No puedes llamar `signalReady(instance)` desde dentro de la factory porque la instancia aún no está registrada.

<strong>Alternativas correctas:</strong>

<strong>Opción 1 - Dejar que la async factory auto-señalice (recomendado):</strong>

<<< @/../code_samples/lib/get_it/signal_ready_correct_option1.dart#example

<strong>Opción 2 - Usar registerSingleton para señalización post-registro:</strong>

<<< @/../code_samples/lib/get_it/signal_ready_correct_option2.dart#example

<strong>Opción 3 - Implementar la interfaz WillSignalReady:</strong>

<<< @/../code_samples/lib/get_it/signal_ready_correct_option3.dart#example

Mira [Señalización Manual de Ready](#senalizacion-manual-de-ready) para más detalles.
:::

### registerLazySingletonAsync

Registra un singleton con una función factory async que se ejecuta <strong>en el primer acceso</strong> (cuando llamas `getAsync<T>()` por primera vez).

<<< @/../code_samples/lib/get_it/register_lazy_singleton_async_signature.dart#example

<strong>Parámetros:</strong>
- `factoryFunc` - Función async que crea la instancia singleton
- `instanceName` - Nombre opcional para registrar múltiples singletons del mismo tipo
- `dispose` - Función de limpieza opcional llamada al desregistrar o resetear
- `onCreated` - Callback opcional invocado después de que la instancia es creada
- `useWeakReference` - Si es true, usa referencia débil (permite recolección de basura si no se usa)

<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/async_objects_2642b731.dart#example


::: warning Lazy Async Singletons y allReady()
`registerLazySingletonAsync` <strong>no</strong> bloquea `allReady()` porque la función factory no se llama hasta el primer acceso. Sin embargo, una vez accedido, puedes usar `isReady()` para esperar a su completación.
:::

## Accediendo a Objetos Async

::: tip Los Objetos Async se Vuelven Normales Después de la Inicialización
Una vez que un async singleton ha completado la inicialización (has hecho await de `allReady()` o `isReady<T>()`), puedes accederlo como un singleton regular usando `get<T>()` en lugar de `getAsync<T>()`. Los métodos async solo se necesitan durante la fase de inicialización o cuando accedes a async factories.

```dart
// Durante el inicio - espera la inicialización
await getIt.allReady();

// Después de estar listo - accede normalmente (no se necesita await)
final database = getIt<Database>();  // ¡No getAsync!
final apiClient = getIt<ApiClient>();
```
:::

### getAsync()

Recupera una instancia creada por una async factory o espera a que un async singleton complete la inicialización.

<<< @/../code_samples/lib/get_it/async_objects_4c3dc27e_signature.dart#example


<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/async_objects_5324c9ca_signature.dart#example


::: tip Obteniendo Múltiples Instancias Async
Si necesitas recuperar múltiples registros async del mismo tipo, mira el capítulo [Registros Múltiples](/documentation/get_it/multiple_registrations#async-version) para la documentación de `getAllAsync()`.
:::

## Gestión de Dependencias

### Usando dependsOn

El parámetro `dependsOn` asegura el orden de inicialización. Cuando registras un singleton con `dependsOn`, su función factory no se ejecutará hasta que todas las dependencias listadas hayan señalizado ready.

<strong>Ejemplo - Inicialización secuencial:</strong>

<<< @/../code_samples/lib/get_it/async_objects_ae083a64.dart#example


## Singletons Sincrónicos con Dependencias

A veces tienes un singleton regular (sync) que depende de que otros async singletons estén listos primero. Usa `registerSingletonWithDependencies` para este patrón.

<<< @/../code_samples/lib/get_it/async_objects_e093effa_signature.dart#example


<strong>Parámetros:</strong>
- `factoryFunc` - Función <strong>sync</strong> que crea la instancia singleton (llamada después de que las dependencias estén listas)
- `instanceName` - Nombre opcional para registrar múltiples singletons del mismo tipo
- `dependsOn` - Lista de tipos de los que depende este singleton (espera a que estén listos primero)
- `signalsReady` - Si es true, debes llamar manualmente a `signalReady()` para marcar como listo
- `dispose` - Función de limpieza opcional llamada al desregistrar o resetear

<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/async_objects_fc40829b.dart#example


## Orquestación de Inicio

GetIt proporciona varias funciones para coordinar la inicialización async y esperar a que los servicios estén listos.

### allReady()

Devuelve un `Future<void>` que se completa cuando <strong>todos</strong> los async singletons y singletons con `signalsReady` han completado su inicialización.

<<< @/../code_samples/lib/get_it/async_objects_93c1b617_signature.dart#example


<strong>Parámetros:</strong>
- `timeout` - Timeout opcional; lanza `WaitingTimeOutException` si no está listo a tiempo
- `ignorePendingAsyncCreation` - Si es true, solo espera señales manuales, ignora async singletons

<strong>Ejemplo con FutureBuilder:</strong>

<<< @/../code_samples/lib/get_it/async_objects_bbdb298c.dart#example


<strong>Ejemplo con timeout:</strong>

<<< @/../code_samples/lib/get_it/async_objects_864b4c27.dart#example


<strong>Llamando a allReady() múltiples veces:</strong>

Puedes llamar `allReady()` múltiples veces. Después de que el primer `allReady()` se complete, si registras nuevos async singletons, puedes hacer await de `allReady()` otra vez para esperar a los nuevos.

<<< @/../code_samples/lib/get_it/async_objects_28d751fd.dart#example


Este patrón es especialmente útil con scopes donde cada scope necesita su propia inicialización:

<<< @/../code_samples/lib/get_it/async_objects_d0a62ccd.dart#example


### isReady()

Devuelve un `Future<void>` que se completa cuando un singleton <strong>específico</strong> está listo.

<<< @/../code_samples/lib/get_it/async_objects_c603af1e_signature.dart#example


<strong>Parámetros:</strong>
- `T` - Tipo del singleton a esperar
- `instance` - Alternativamente, esperar a un objeto de instancia específico
- `instanceName` - Esperar a registro con nombre
- `timeout` - Timeout opcional; lanza `WaitingTimeOutException` si no está listo a tiempo
- `callee` - Parámetro opcional para depuración (ayuda a identificar quién está esperando)

<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/async_objects_21920847.dart#example


### isReadySync()

Verifica si un singleton está listo <strong>sin esperar</strong> (devuelve inmediatamente).

<<< @/../code_samples/lib/get_it/async_objects_7d06e64a_signature.dart#example


<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/async_objects_96ff9c4e.dart#example


### allReadySync()

Verifica si <strong>todos</strong> los async singletons están listos sin esperar.

<<< @/../code_samples/lib/get_it/async_objects_90ee78c4_signature.dart#example


<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/async_objects_4ef84c96.dart#example


### Dependencias con Nombre usando InitDependency

Si tienes registros con nombre, usa `InitDependency` para especificar tanto el tipo como el nombre de instancia.

<<< @/../code_samples/lib/get_it/async_objects_55d54ef7.dart#example


## Señalización Manual de Ready

A veces necesitas más control sobre cuándo un singleton señaliza que está listo. Esto es útil cuando la inicialización involucra múltiples pasos o callbacks.

### Usando el Parámetro signalsReady

Cuando estableces `signalsReady: true` durante el registro, GetIt no marcará automáticamente el singleton como listo. Debes llamar manualmente a `signalReady()`.

<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/async_objects_f2965023.dart#example


### Usando la Interfaz WillSignalReady

En lugar de pasar `signalsReady: true`, implementa la interfaz `WillSignalReady`. GetIt detecta esto automáticamente y espera la señalización manual.

<<< @/../code_samples/lib/get_it/async_objects_62e38c5b.dart#example


### signalReady()

Señaliza manualmente que un singleton está listo.

<<< @/../code_samples/lib/get_it/async_objects_af1df8a2_signature.dart#example


<strong>Parámetros:</strong>
- `instance` - La instancia que está lista (pasar `null` es legacy y no se recomienda)

<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/async_objects_174d24d3.dart#example


::: tip Característica Legacy
`signalReady(null)` (señal ready global sin una instancia) es una característica legacy de versiones anteriores de GetIt. Se recomienda usar registros async (`registerSingletonAsync`, etc.) o señalización específica de instancia en su lugar. El enfoque de señal global es menos claro sobre qué se está inicializando y no se integra bien con la gestión de dependencias.

<strong>Nota:</strong> El `signalReady(null)` global lanzará un error si tienes cualquier registro async o instancias con `signalsReady: true` que aún no hayan señalizado. La señalización específica de instancia funciona bien junto con registros async.
:::

## Mejores Prácticas

::: details 1. Prefiere registerSingletonAsync para Inicialización de App

Para servicios necesarios al inicio de la app, usa `registerSingletonAsync` (no lazy) para que comiencen a inicializarse inmediatamente.

<<< @/../code_samples/lib/get_it/async_objects_6e8c86b1.dart#example
:::

::: details 2. Usa dependsOn para Expresar Dependencias

Deja que GetIt gestione el orden de inicialización en lugar de orquestar manualmente con `isReady()`.

<<< @/../code_samples/lib/get_it/async_objects_a3cbd191.dart#example
:::

::: details 3. Usa FutureBuilder para Pantallas de Splash

Muestra una pantalla de carga mientras los servicios se inicializan.

<<< @/../code_samples/lib/get_it/async_objects_d275974b.dart#example
:::

::: details 4. Siempre Establece Timeouts para allReady()

Previene que tu app se cuelgue indefinidamente si la inicialización falla.

<<< @/../code_samples/lib/get_it/async_objects_a6be16da.dart#example
:::


## Patrones Comunes

### Patrón 1: Inicialización en Capas

<<< @/../code_samples/lib/get_it/async_objects_65faea06.dart#example

::: details Patrón 2: Inicialización Condicional

<<< @/../code_samples/lib/get_it/async_objects_80efa70c.dart#example
:::

::: details Patrón 3: Seguimiento de Progreso

<<< @/../code_samples/lib/get_it/async_objects_3be0569c.dart#example
:::

::: details Patrón 4: Reintentar en Fallo

<<< @/../code_samples/lib/get_it/async_objects_b64e81ba.dart#example
:::


## Lectura Adicional

- [Post de blog detallado sobre async factories y orquestación de inicio](https://blog.burkharts.net/lets-get-this-party-started-startup-orchestration-with-getit)
- [Documentación de Scopes](/es/documentation/get_it/scopes) - Inicialización async dentro de scopes
- [Documentación de Pruebas](/es/documentation/get_it/testing) - Simulando servicios async en pruebas
