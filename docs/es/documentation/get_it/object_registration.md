---
title: Registro de Objetos
---

# Registro de Objetos

get_it ofrece diferentes tipos de registro que controlan cuándo se crean los objetos y cuánto tiempo viven. Elige el tipo correcto según tus necesidades.

## Referencia Rápida

| Tipo | Cuándo se Crea | Cuántas Instancias | Tiempo de Vida | Mejor Para |
|------|--------------|-------------------|----------|----------|
| <strong>Singleton</strong> | Inmediatamente | Una | Permanente | Rápido de crear, necesario al inicio |
| <strong>LazySingleton</strong> | Primer acceso | Una | Permanente | Costoso de crear, no siempre necesario |
| <strong>Factory</strong> | Cada `get()` | Muchas | Por solicitud | Objetos temporales, nuevo estado cada vez |
| <strong>Cached Factory</strong> | Primer acceso + después del GC | Reutilizado mientras está en memoria | Hasta que es recolectado por el GC | Optimización de rendimiento |

---

## Singleton


<<< @/../code_samples/lib/get_it/t_example_signature.dart#example

Pasas una instancia de `T` que <strong>siempre</strong> será devuelta en las llamadas a `get<T>()`. La instancia se crea <strong>inmediatamente</strong> cuando la registras.

<strong>Parámetros:</strong>
- `instance` - La instancia a registrar
- `instanceName` - Nombre opcional para registrar múltiples instancias del mismo tipo
- `signalsReady` - Si es true, esta instancia debe señalizar cuándo está lista (usado con inicialización asíncrona)
- `dispose` - Función de limpieza opcional llamada al desregistrar o resetear

<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/configure_dependencies_example_4.dart#example

<strong>Cuándo usar Singleton:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Servicio necesario al inicio de la app</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Rápido de crear (sin inicialización costosa)</li>
</ul>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Evita para inicialización lenta (usa LazySingleton en su lugar)</li>
</ul>

---

## LazySingleton


<<< @/../code_samples/lib/get_it/function_example_signature.dart#example

Pasas una función factory que devuelve una instancia de `T`. La función <strong>solo se llama en el primer acceso</strong> a `get<T>()`. Después de eso, siempre se devuelve la misma instancia.

<strong>Parámetros:</strong>
- `factoryFunc` - Función que crea la instancia
- `instanceName` - Nombre opcional para registrar múltiples instancias del mismo tipo
- `dispose` - Función de limpieza opcional llamada al desregistrar o resetear
- `onCreated` - Callback opcional invocado después de que la instancia es creada
- `useWeakReference` - Si es true, usa referencia débil (permite recolección de basura si no se usa)

<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/configure_dependencies_example_5.dart#example

<strong>Cuándo usar LazySingleton:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Servicios costosos de crear (base de datos, cliente HTTP, etc.)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Servicios no siempre necesarios para cada usuario</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Cuando necesites retrasar la inicialización</li>
</ul>

---

::: tip Tipos Concretos vs Interfaces
Puedes registrar clases concretas o interfaces abstractas. <strong>Registra clases concretas directamente</strong> a menos que esperes múltiples implementaciones (ej., producción vs prueba, diferentes proveedores). Esto mantiene tu código más simple y la navegación del IDE más fácil.
:::

## Factory


<<< @/../code_samples/lib/get_it/t_example_1_signature.dart#example

Pasas una función factory que devuelve una <strong>NUEVA instancia</strong> de `T` cada vez que llamas `get<T>()`. A diferencia de los singletons, obtienes un objeto diferente cada vez.

<strong>Parámetros:</strong>
- `factoryFunc` - Función que crea nuevas instancias
- `instanceName` - Nombre opcional para registrar múltiples factories del mismo tipo

<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/configure_dependencies_example_6.dart#example

<strong>Cuándo usar Factory:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Objetos temporales (diálogos, formularios, contenedores de datos temporales)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Objetos que necesitan estado fresco cada vez</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Objetos con ciclo de vida corto</li>
</ul>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Evita para objetos costosos de crear usados frecuentemente (considera Cached Factory)</li>
</ul>

---

## Pasando Parámetros a Factories

En algunos casos, necesitas pasar valores a factories al llamar `get()`. get_it soporta hasta dos parámetros:


<<< @/../code_samples/lib/get_it/code_sample_30935190_signature.dart#example

<strong>Ejemplo con dos parámetros:</strong>


<<< @/../code_samples/lib/get_it/code_sample_42c18049.dart#example

<strong>Ejemplo con un parámetro:</strong>

Si solo necesitas un parámetro, pasa `void` como el segundo tipo:


<<< @/../code_samples/lib/get_it/code_sample_8a892376.dart#example

<strong>¿Por qué dos parámetros?</strong>

Dos parámetros cubren escenarios comunes como widgets de Flutter que necesitan tanto `BuildContext` como un objeto de datos, o servicios que necesitan tanto configuración como valores en tiempo de ejecución.

::: warning Seguridad de Tipos
Los parámetros se pasan como `dynamic` pero se verifican en tiempo de ejecución para coincidir con los tipos registrados (`P1`, `P2`). Las discordancias de tipo lanzarán un error.
:::

---

## Cached Factories

Las cached factories son una <strong>optimización de rendimiento</strong> que se sitúa entre las factories regulares y los singletons. Crean una nueva instancia en la primera llamada pero la cachean con una referencia débil, devolviendo la instancia cacheada mientras todavía esté en memoria (lo que significa que alguna parte de tu app todavía mantiene una referencia a ella).


<<< @/../code_samples/lib/get_it/code_sample_773e24bb_signature.dart#example

<strong>Cómo funciona:</strong>
1. Primera llamada: Crea nueva instancia (como factory)
2. Llamadas subsecuentes: Devuelve instancia cacheada si todavía está en memoria (como singleton)
3. Si es recolectada por el GC (sin referencias mantenidas por tu app): Crea nueva instancia otra vez (como factory)
4. Para versiones con parámetros: También verifica si los parámetros coinciden antes de reutilizar

<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/code_sample_135f1ef6.dart#example

<strong>Con parámetros:</strong>


<<< @/../code_samples/lib/get_it/code_sample_1a719c02.dart#example

<strong>Cuándo usar cached factories:</strong>

✅ <strong>Buenos casos de uso:</strong>
- <strong>Objetos pesados recreados frecuentemente</strong>: Parsers, formateadores, calculadoras
- <strong>Escenarios sensibles a la memoria</strong>: Quieres limpieza automática pero prefieres reutilización
- <strong>Objetos con inicialización costosa</strong>: Conexiones a base de datos, lectores de archivos
- <strong>Objetos de tiempo de vida corto a medio</strong>: Activos por un tiempo pero no para siempre

❌️ <strong>No uses cuando:</strong>
- El objeto siempre debería ser nuevo (usa factory regular)
- El objeto debería vivir para siempre (usa singleton/lazy singleton)
- El objeto mantiene estado crítico que no debe reutilizarse

<strong>Características de rendimiento:</strong>

| Tipo | Costo de Creación | Memoria | Reutilización |
|------|---------------|--------|-------|
| Factory | Cada llamada | Baja (GC inmediato) | Nunca |
| <strong>Cached Factory</strong> | Primera llamada + después del GC | Media (ref. débil) | Mientras está en memoria |
| Lazy Singleton | Solo primera llamada | Alta (permanente) | Siempre |

<strong>Ejemplo de comparación:</strong>


<<< @/../code_samples/lib/get_it/json_parser.dart#example

::: tip Gestión de Memoria
Las cached factories usan <strong>referencias débiles</strong>, lo que significa que la instancia cacheada puede ser recolectada por el garbage collector cuando ninguna otra parte de tu código mantiene una referencia a ella. Esto proporciona gestión automática de memoria mientras te beneficias de la reutilización.
:::

---

## Registrando Múltiples Implementaciones

get_it soporta múltiples formas de registrar más de una instancia del mismo tipo. Esto es útil para sistemas de plugins, manejadores de eventos y arquitecturas modulares donde necesitas recuperar todas las implementaciones de un tipo particular.

::: tip Aprende Más
Mira el capítulo [Registros Múltiples](/documentation/get_it/multiple_registrations) para documentación comprehensiva que cubre:
- Diferentes enfoques para registrar múltiples instancias
- Por qué se requiere habilitación explícita para registros sin nombre
- Cómo se comportan `get<T>()` vs `getAll<T>()` de forma diferente
- Registros con nombre vs sin nombre
- Comportamiento de scope con `fromAllScopes`
- Patrones del mundo real (plugins, observadores, middleware)
:::

---

## Gestionando Registros

### Verificando si un Tipo está Registrado

Puedes probar si un tipo o instancia ya está registrada:


<<< @/../code_samples/lib/get_it/code_sample_3ddc0f1f_signature.dart#example

<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/code_sample_1c1d87ec.dart#example

### Desregistrando Servicios

Puedes remover un tipo registrado de get_it, opcionalmente llamando a una función de disposal:


<<< @/../code_samples/lib/get_it/function_example_1_signature.dart#example

<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/code_sample_91535ee8.dart#example

::: tip
La función de disposal sobrescribe cualquier función de disposal que hayas proporcionado durante el registro.
:::

### Reseteando Lazy Singletons

A veces quieres resetear un lazy singleton (forzar recreación en el siguiente acceso) sin desregistrarlo:


<<< @/../code_samples/lib/get_it/function_example_2_signature.dart#example

<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/code_sample_2ba32f12.dart#example

<strong>Cuándo usar:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Refrescar datos cacheados (después de login/logout)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Testing - resetear estado entre pruebas</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Desarrollo - recargar configuración</li>
</ul>

::: tip Resetear Todos los Lazy Singletons
Si necesitas resetear <strong>todos</strong> los lazy singletons a la vez (en lugar de uno a la vez), usa `resetLazySingletons()` que soporta control de scope y operaciones en lote. Mira la [documentación de resetLazySingletons()](/documentation/get_it/advanced#reset-all-lazy-singletons-resetlazysingletons) para detalles.
:::

### Reseteando Todos los Registros

Limpia todos los tipos registrados (útil para pruebas o cierre de la app):


<<< @/../code_samples/lib/get_it/reset_example_signature.dart#example

<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/code_sample_14c31d5c.dart#example

::: warning Importante
- Los registros se limpian en <strong>orden inverso</strong> (último registrado, primero dispuesto)
- Esto es <strong>async</strong> - siempre haz `await`
- Las funciones de disposal registradas durante la configuración serán llamadas (a menos que `dispose: false`)
:::

<strong>Casos de uso:</strong>
- Entre pruebas unitarias (`tearDown` o `tearDownAll`)
- Antes del cierre de la app
- Cambiando entornos completamente

### Sobrescribiendo Registros

Por defecto, get_it previene registrar el mismo tipo dos veces (atrapa bugs). Para permitir sobrescritura:


<<< @/../code_samples/lib/get_it/logger_example.dart#example

::: warning Usa con Moderación
Permitir reasignación hace que los bugs sean más difíciles de atrapar. Prefiere usar [scopes](/es/documentation/get_it/scopes) en su lugar para sobrescrituras temporales (especialmente en pruebas).
:::

### Saltar Registro Doble (Solo Testing)

En pruebas, ignora silenciosamente el registro doble en lugar de lanzar un error:


<<< @/../code_samples/lib/get_it/logger_example_1.dart#example
