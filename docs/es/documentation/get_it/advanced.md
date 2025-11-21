---
title: Avanzado
---

# Avanzado
## Implementando la Interfaz `Disposable`

En lugar de pasar una función de disposal en el registro o al empujar un Scope, desde V7.0 el método `onDispose()` de tu objeto será llamado
si el objeto que registras implementa la interfaz `Disposable`:


<<< @/../code_samples/lib/get_it/disposable_example.dart#example

## Encontrar Todas las Instancias por Tipo: `findAll<T>()`

Encuentra todas las instancias registradas que coincidan con un tipo dado con opciones poderosas de filtrado y coincidencia.


<<< @/../code_samples/lib/get_it/code_sample_12625bd9_signature.dart#example

::: warning Nota de Rendimiento
A diferencia de las búsquedas O(1) basadas en Map de `get_it`, `findAll()` realiza una búsqueda lineal O(n) a través de todos los registros. Usa con moderación en código crítico de rendimiento. El rendimiento puede mejorarse limitando la búsqueda a un solo scope usando `onlyInScope`.
:::

<strong>Parámetros:</strong>

<strong>Coincidencia de Tipo:</strong>
- `includeSubtypes` - Si es true (por defecto), coincide con T y todos los subtipos; si es false, coincide solo con el tipo exacto T

<strong>Control de Scope:</strong>
- `inAllScopes` - Si es true, busca en todos los scopes (por defecto: false, solo scope actual)
- `onlyInScope` - Busca solo en el scope nombrado (tiene precedencia sobre `inAllScopes`)

<strong>Estrategia de Coincidencia:</strong>
- `includeMatchedByRegistrationType` - Coincidir por tipo registrado (por defecto: true)
- `includeMatchedByInstance` - Coincidir por tipo de instancia real (por defecto: true)

<strong>Efectos Secundarios:</strong>
- `instantiateLazySingletons` - Instanciar lazy singletons que coincidan (por defecto: false)
- `callFactories` - Llamar factories que coincidan para incluir sus instancias (por defecto: false)

<strong>Ejemplo - Coincidencia básica de tipos:</strong>


<<< @/../code_samples/lib/get_it/write_example.dart#example

::: details Ejemplo - Incluir lazy singletons

<<< @/../code_samples/lib/get_it/code_sample_4c9aa485.dart#example
:::

::: details Ejemplo - Incluir factories

<<< @/../code_samples/lib/get_it/i_output_example.dart#example
:::

::: details Ejemplo - Coincidencia exacta de tipo

<<< @/../code_samples/lib/get_it/base_logger_example.dart#example
:::

::: details Ejemplo - Tipo de Instancia vs Tipo de Registro

<<< @/../code_samples/lib/get_it/file_output_example.dart#example
:::

::: details Ejemplo - Control de scope

<<< @/../code_samples/lib/get_it/i_output.dart#example
:::

<strong>Casos de uso:</strong>
- Encontrar todas las implementaciones de una interfaz de plugin
- Recopilar todos los validators/processors registrados
- Visualización de grafo de dependencias en tiempo de ejecución
- Pruebas: verificar que todos los tipos esperados están registrados
- Herramientas de migración: encontrar instancias de tipos deprecated

<strong>Reglas de validación:</strong>
- `includeSubtypes=false` requiere `includeMatchedByInstance=false`
- `instantiateLazySingletons=true` requiere `includeMatchedByRegistrationType=true`
- `callFactories=true` requiere `includeMatchedByRegistrationType=true`

<strong>Lanza:</strong>
- `StateError` si `onlyInScope` no existe
- `ArgumentError` si se violan las reglas de validación

## Conteo de Referencias

El conteo de referencias ayuda a gestionar el ciclo de vida de singletons cuando múltiples consumidores podrían necesitar la misma instancia, especialmente útil para escenarios recursivos como navegación.

### El Problema

Imagina una página de detalle que puede ser empujada recursivamente (ej., ver items relacionados, navegar a través de una jerarquía):

```
Home → DetailPage(item1) → DetailPage(item2) → DetailPage(item3)
```

Sin conteo de referencias:
- Primera DetailPage registra `DetailService`
- Segunda DetailPage intenta registrar → Error o debe saltarse el registro
- Primera DetailPage hace pop, dispone el servicio → Rompe las páginas restantes

### La Solución: `registerSingletonIfAbsent` y `releaseInstance`


<<< @/../code_samples/lib/get_it/release_instance_example_signature.dart#example

<strong>Cómo funciona:</strong>
1. Primera llamada: Crea instancia, registra, establece contador de referencia a 1
2. Llamadas subsecuentes: Devuelve instancia existente, incrementa contador
3. `releaseInstance`: Decrementa contador
4. Cuando el contador llega a 0: Desregistra y dispone

### Ejemplo de Navegación Recursiva


<<< @/../code_samples/lib/get_it/detail_service_example.dart#example

<strong>Flujo:</strong>
```
Push DetailPage(item1)      → Crear servicio, cargar datos, refCount = 1
  Push DetailPage(item2)    → Crear servicio, cargar datos, refCount = 1
    Push DetailPage(item1)  → Obtener existente (¡NO recarga!), refCount = 2
    Pop DetailPage(item1)   → Release, refCount = 1 (servicio permanece)
  Pop DetailPage(item2)     → Release, refCount = 0 (servicio dispuesto)
Pop DetailPage(item1)       → Release, refCount = 0 (servicio dispuesto)
```

<strong>Beneficios:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Servicio creado síncronamente (no se necesita factory async)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Carga async disparada en constructor</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Sin carga duplicada para el mismo item (verificado antes de cargar)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Gestión automática de memoria vía conteo de referencias</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Actualizaciones reactivas de UI vía `watch_it` (reconstruye en cambios de estado)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ ChangeNotifier automáticamente dispuesto cuando refCount llega a 0</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Cada itemId únicamente identificado vía `instanceName`</li>
</ul>

<strong>Integración Clave:</strong>
Este ejemplo demuestra cómo <strong>`get_it`</strong> (conteo de referencias) y <strong>`watch_it`</strong> (UI reactiva) funcionan juntos sin problemas para patrones de navegación complejos.

---

### Liberación Forzada: `ignoreReferenceCount`

En casos raros, podrías necesitar forzar el desregistro sin importar el conteo de referencias:


<<< @/../code_samples/lib/get_it/code_sample_2fd612f7.dart#example

::: warning Usa con Precaución
Solo usa `ignoreReferenceCount: true` cuando estés seguro de que ningún otro código está usando la instancia. Esto puede causar crashes si otras partes de tu app aún mantienen referencias.
:::

### Cuándo Usar Conteo de Referencias

✅ <strong>Buenos casos de uso:</strong>
- Navegación recursiva (misma página empujada múltiples veces)
- Servicios necesarios por múltiples características activas simultáneamente
- Estructuras de componentes jerárquicas complejas

❌️ <strong>No uses cuando:</strong>
- Singleton simple que vive durante el tiempo de vida de la app (usa `registerSingleton` regular)
- Relación uno-a-uno widget-servicio (usa scopes)
- Pruebas (usa scopes para sombrear en su lugar)

### Mejores Prácticas

1. <strong>Siempre empareja registro con liberación</strong>: Cada `registerSingletonIfAbsent` debe tener un `releaseInstance` correspondiente
2. <strong>Almacena referencia de instancia</strong>: Mantén la instancia devuelta para que puedas liberar la correcta
3. <strong>Libera en dispose/cleanup</strong>: Ata la liberación al ciclo de vida del widget/componente
4. <strong>Documenta recursos compartidos</strong>: Deja claro cuándo un servicio usa conteo de referencias

---

## Métodos Utilitarios

### Recuperación Segura: `maybeGet<T>()`

Devuelve `null` en lugar de lanzar una excepción si el tipo no está registrado. Útil para dependencias opcionales y feature flags.


<<< @/../code_samples/lib/get_it/code_sample_fdab4a35_signature.dart#example

<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/my_widget_example.dart#example

<strong>Cuándo usar:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Características opcionales que pueden o no estar registradas</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Feature flags (servicio registrado solo cuando la característica está habilitada)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Servicios específicos de plataforma (podrían no existir en todas las plataformas)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Escenarios de degradación elegante</li>
</ul>

<strong>No uses cuando:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ La dependencia es requerida - usa <code>get&lt;T&gt;()</code> para fallar rápido</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ El registro faltante indica un bug - la excepción es útil</li>
</ul>

---

### Renombrado de Instancia: `changeTypeInstanceName()`

Renombra una instancia registrada sin desregistrar y re-registrar (evita disparar funciones de disposal).


<<< @/../code_samples/lib/get_it/code_sample_32653109_signature.dart#example

<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/user_example.dart#example

<strong>Casos de uso:</strong>
- Actualizaciones de perfil de usuario donde el nombre de usuario es el identificador de instancia
- Nombres de entidades dinámicas que pueden cambiar en tiempo de ejecución
- Evitar efectos secundarios de disposal del ciclo unregister/register
- Mantener estado de instancia mientras se actualiza su identificador

::: tip Evita Dispose
A diferencia de `unregister()` + `register()`, esto no dispara funciones de disposal, preservando el estado de la instancia.
:::

---

### Introspección de Lazy Singleton: `checkLazySingletonInstanceExists()`

Verifica si un lazy singleton ha sido instanciado aún (sin disparar su creación).


<<< @/../code_samples/lib/get_it/code_sample_3c73f756_signature.dart#example

<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/code_sample_aa613a22.dart#example

<strong>Casos de uso:</strong>
- Monitoreo de rendimiento (rastrear qué servicios han sido inicializados)
- Inicialización condicional (pre-calentar servicios si no se crearon)
- Probar comportamiento de carga lazy
- Depurar problemas de orden de inicialización

<strong>Ejemplo - Pre-calentamiento:</strong>


<<< @/../code_samples/lib/get_it/pre_warm_critical_services_example.dart#example

---

### Resetear Todos los Lazy Singletons: `resetLazySingletons()`

Resetea todos los lazy singletons instanciados de una vez. Esto limpia sus instancias para que sean recreadas en el siguiente acceso.


<<< @/../code_samples/lib/get_it/reset_lazy_singletons_example_signature.dart#example

<strong>Parámetros:</strong>
- `dispose` - Si es true (por defecto), llama funciones de disposal antes de resetear
- `inAllScopes` - Si es true, resetea lazy singletons a través de todos los scopes
- `onlyInScope` - Resetea solo en el scope nombrado (tiene precedencia sobre `inAllScopes`)

<strong>Ejemplo - Uso básico:</strong>


<<< @/../code_samples/lib/get_it/code_sample_599505d1.dart#example

<strong>Ejemplo - Con scopes:</strong>


<<< @/../code_samples/lib/get_it/code_sample_322e6eda.dart#example

<strong>Casos de uso:</strong>
- Reset de estado entre pruebas
- Logout de usuario (limpiar lazy singletons específicos de sesión)
- Optimización de memoria (resetear cachés que pueden ser recreados)
- Limpieza específica de scope sin hacer pop del scope

<strong>Comportamiento:</strong>
- Solo resetea lazy singletons que han sido <strong>instanciados</strong>
- Los lazy singletons no instanciados <strong>no se afectan</strong>
- Los singletons regulares y factories <strong>no se afectan</strong>
- Soporta funciones de disposal tanto sync como async

---

### Introspección Avanzada: `findFirstObjectRegistration<T>()`

Obtiene metadatos sobre un registro sin recuperar la instancia.


<<< @/../code_samples/lib/get_it/code_sample_f4194899_signature.dart#example

<strong>Ejemplo:</strong>


<<< @/../code_samples/lib/get_it/code_sample_be97525b.dart#example

<strong>Casos de uso:</strong>
- Construir herramientas/utilidades de depuración sobre GetIt
- Visualización de grafo de dependencias en tiempo de ejecución
- Gestión avanzada del ciclo de vida
- Depuración de problemas de registro

---

### Accediendo a un objeto dentro de GetIt por un tipo de tiempo de ejecución

En ocasiones raras podrías enfrentarte con el problema de que no conoces el tipo que quieres recuperar de GetIt en tiempo de compilación, lo que significa que no puedes pasarlo como parámetro genérico. Para esto las funciones `get` tienen un parámetro `type` opcional


<<< @/../code_samples/lib/get_it/code_sample_caa57cf3.dart#example

Ten cuidado de que la variable receptora tenga el tipo correcto y no pases `type` y un parámetro genérico.

### Más de una instancia de GetIt

Aunque no se recomienda, puedes crear tu propia instancia independiente de `GetIt` si no quieres compartir tu locator con algún
otro paquete o porque la física de tu planeta lo demanda :-)


<<< @/../code_samples/lib/get_it/code_sample_e7453700_signature.dart#example

Esta nueva instancia no comparte ningún registro con la instancia singleton.
