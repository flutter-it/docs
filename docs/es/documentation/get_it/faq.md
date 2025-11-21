---
title: Preguntas Frecuentes
---

# Preguntas Frecuentes

## ¿Por qué necesitamos get_it?

::: details Haz clic para ver la respuesta

<strong>Pregunta:</strong> No entiendo los beneficios de usar get_it o InheritedWidget.

He investigado por qué necesitamos InheritedWidget, esto resuelve el problema de pasar datos. Sin embargo para eso tenemos un sistema de gestión de estado así que no necesitamos InheritedWidget en absoluto.

He investigado get_it y por lo que entiendo si ya estamos usando un sistema de gestión de estado el único beneficio que tendríamos es la capacidad de encapsular los servicios/métodos relacionados con un grupo de widgets en un solo lugar. (inyección de dependencias)

Por ejemplo si tenemos un mapa y un botón de localízame entonces podrían compartir el mismo servicio _locateMe.
Para esto crearíamos una clase abstracta que define el método _locateMe y lo conectaríamos con la inyección de dependencias usando un locator.registerLazySingleton.

¿Pero cuál es el punto? Puedo simplemente crear un archivo methods.dart con el método locateMe sin ninguna clase, podemos solo poner el método en methods.dart lo cual es más rápido y fácil y podemos accederlo desde cualquier lugar.
No estoy seguro de cómo dart funciona internamente, lo que tiene sentido para mí es que registerLazySingleton removería el método _locateMe de la memoria después de que use el método _locateMe. Y si ponemos el método locateMe dentro de un archivo .dart normal sin clases ni nada más, estará siempre en memoria por lo tanto menos performante.
¿Es cierta mi suposición? ¿Hay algo que me esté perdiendo?

---

<strong>Respuesta:</strong> Déjame explicarlo de esta manera, no estás completamente equivocado. Definitivamente puedes usar solo funciones globales y variables globales para hacer que el estado sea accesible a tu UI.

El verdadero poder de la inyección de dependencias viene de usar clases de interfaz abstractas al registrar los tipos. Esto te permite cambiar implementaciones en un momento sin cambiar ninguna otra parte de tu código.
Esto es especialmente útil cuando se trata de escribir pruebas unitarias o pruebas de UI para que puedas fácilmente inyectar objetos mock.

Otro aspecto es el scoping de los objetos. Los inherited widgets así como get_it te permiten sobrescribir objetos registrados basándote en un scope actual. Para inherited widgets este scope está definido por tu posición actual en el árbol de widgets, en get_it puedes empujar y hacer pop de scopes de registros independiente del árbol de widgets.

Los scopes te permiten sobrescribir comportamiento existente o gestionar fácilmente el tiempo de vida y disposal de objetos.

La idea general de cualquier sistema de inyección de dependencias es que tienes un punto definido en tu código donde tienes toda tu configuración y setup.
Además GetIt te ayuda a inicializar tus objetos de negocio síncronos mientras automáticamente se encarga de las dependencias entre tales objetos.

Escribiste que ya estás usando algún tipo de solución de gestión de estado. Lo que probablemente significa que la solución ya ofrece algún tipo de localización de objetos. En este caso probablemente no necesitarás get_it.
Junto con [`watch_it`](/documentation/watch_it/getting_started) sin embargo no necesitas ninguna otra solución de gestión de estado si ya usas get_it.
:::

## Object/factory con tipo X no está registrado - ¿cómo arreglar?

::: details Haz clic para ver la respuesta

<strong>Mensaje de error:</strong> `GetIt: Object/factory with type X is not registered inside GetIt. (Did you forget to register it?)`

Este error significa que estás intentando acceder a un tipo que aún no ha sido registrado. Causas comunes:

<strong>1. Olvidaste registrar el tipo</strong>

<<< @/../code_samples/lib/get_it/code_sample_383c0a19.dart#example

<strong>Solución:</strong> Registra antes de acceder:

<<< @/../code_samples/lib/get_it/main_example_4.dart#example

<strong>2. Orden incorrecto - accediendo antes del registro</strong>

<<< @/../code_samples/lib/get_it/main_example_5.dart#example

<strong>Solución:</strong> Registra primero, usa después:

<<< @/../code_samples/lib/get_it/main_example_6.dart#example

<strong>3. Usando paréntesis en GetIt.instance</strong>

<<< @/../code_samples/lib/get_it/code_sample_6f9d6d83.dart#example

<strong>Solución:</strong> Sin paréntesis - es un getter, no una función:

<<< @/../code_samples/lib/get_it/code_sample_0da49c29.dart#example

<strong>4. Discordancia de tipo - registrado tipo concreto pero accediendo interfaz</strong>

<<< @/../code_samples/lib/get_it/code_sample_6c897c2f.dart#example

<strong>Solución:</strong> Registra con el tipo de interfaz:

<<< @/../code_samples/lib/get_it/code_sample_3b6bf5d9.dart#example

<strong>5. Accediendo en el scope incorrecto</strong>
Si registraste en un scope del que se ha hecho pop, el servicio ya no está disponible.

<strong>Consejos de depuración:</strong>
- Verifica `getIt.isRegistered<MyService>()` para verificar el registro
- Usa `getIt.allReady()` si tienes registros async
- Asegúrate de que el registro ocurre antes de `runApp()` en main()
:::

## Object/factory con tipo X ya está registrado - ¿cómo arreglar?

::: details Haz clic para ver la respuesta

Este error significa que estás intentando registrar el mismo tipo dos veces. Causas comunes:

<strong>1. Llamando función de registro múltiples veces</strong>

<<< @/../code_samples/lib/get_it/main_example_7.dart#example

<strong>Solución:</strong> Solo llama una vez:

<<< @/../code_samples/lib/get_it/main_example_8.dart#example

<strong>2. Registrando dentro de métodos build (problema de hot reload)</strong>
Si registras servicios dentro de `build()` o `initState()`, hot reload lo llamará otra vez.

❌️ <strong>Incorrecto:</strong>

<<< @/../code_samples/lib/get_it/my_app_example.dart#example

✅ <strong>Solución:</strong> Mueve el registro a `main()` antes de `runApp()`:

<<< @/../code_samples/lib/get_it/main_example_9.dart#example

<strong>3. Pruebas re-registrando servicios</strong>
Cada prueba intenta registrar, pero el setup de la prueba anterior no limpió.

<strong>Solución:</strong> Usa scopes en pruebas (mira "[¿Cómo pruebo código que usa get_it?](#como-pruebo-codigo-que-usa-get-it)" más abajo).

<strong>4. Múltiples registros con diferentes nombres de instancia</strong>
Si quieres múltiples instancias del mismo tipo:

<<< @/../code_samples/lib/get_it/api_client_2.dart#example

O usa registros múltiples sin nombre (mira la [documentación de Registros Múltiples](/documentation/get_it/multiple_registrations)).

<strong>Mejor práctica:</strong>
- Registra una vez al inicio de la app en main()
- Usa scopes para login/logout (no unregister/register)
- Usa scopes en pruebas (no reset/re-register)
:::

## ¿Debería usar Singleton o LazySingleton?

::: details Haz clic para ver la respuesta

<strong>registerSingleton()</strong> crea la instancia inmediatamente cuando llamas al método de registro. Usa esto cuando:
- El objeto se necesita al inicio de la app
- La inicialización es rápida y no bloqueante
- Quieres fallar rápido si la construcción falla

<strong>registerLazySingleton()</strong> retrasa la creación hasta la primera llamada a `get()`. Usa esto cuando:
- El objeto podría no ser necesario en cada sesión de la app
- La inicialización es costosa (cómputo pesado, carga de datos grandes)
- Quieres tiempo de inicio de app más rápido

<strong>Ejemplo:</strong>

<<< @/../code_samples/lib/get_it/logger.dart#example

<strong>Cómo elegir:</strong> Usa `registerSingleton()` para servicios rápidos de crear necesarios al inicio. Usa `registerLazySingleton()` para servicios costosos de crear o aquellos que no siempre se necesitan. La mayoría de los servicios de app caen en una categoría u otra basándose en su costo de inicialización.
:::

## ¿Cuál es la diferencia entre Factory y Singleton?

::: details Haz clic para ver la respuesta

<strong>Factory</strong> (`registerFactory()`) crea una <strong>nueva instancia</strong> cada vez que llamas `get<T>()`:

<<< @/../code_samples/lib/get_it/shopping_cart_example.dart#example

<strong>Singleton</strong> (`registerSingleton()` / `registerLazySingleton()`) devuelve la <strong>misma instancia</strong> cada vez:

<<< @/../code_samples/lib/get_it/code_sample_c1d7f5e3.dart#example

<strong>Cuándo usar Factory:</strong>
- Objetos de corta duración (view models para diálogos, calculadoras temporales)
- Objetos con estado por llamada (manejadores de solicitud, procesadores de datos)
- Necesitas múltiples instancias independientes

<strong>Cuándo usar Singleton:</strong>
- Servicios a nivel de app (cliente API, base de datos, servicio de auth)
- Objetos costosos de crear que quieres reutilizar
- Estado compartido a través de tu app

<strong>Consejo pro:</strong> La mayoría de los servicios deberían ser Singletons. Las factories son menos comunes - úsalas solo cuando específicamente necesites múltiples instancias.
:::

## ¿Cómo manejo dependencias circulares?

::: details Haz clic para ver la respuesta

Las dependencias circulares indican un problema de diseño. Aquí están las soluciones:

<strong>1. Usa una interfaz/abstracción (Mejor)</strong>

<<< @/../code_samples/lib/get_it/do_something_example.dart#example

<strong>2. Usa un mediador/event bus</strong>
En lugar de dependencias directas, comunícate a través de eventos:

<<< @/../code_samples/lib/get_it/emit_example.dart#example

<strong>3. Repiensa tu diseño</strong>
Las dependencias circulares a menudo significan:
- Las responsabilidades están mezcladas (dividir en más servicios)
- Falta capa de abstracción
- La lógica debería estar en un tercer servicio que coordina ambos

<strong>Lo que NO hacer:</strong>
❌️ Usar `late` sin inicialización apropiada
❌️ Usar variables globales para romper el ciclo
❌️ Pasar instancia de getIt alrededor
:::

## ¿Por qué obtengo "This instance is not available in GetIt" al llamar signalReady?

::: details Haz clic para ver la respuesta

Este error típicamente ocurre cuando intentas llamar `signalReady(instance)` <strong>antes</strong> de que la instancia esté realmente registrada en GetIt. Esto comúnmente ocurre cuando usas `signalsReady: true` con `registerSingletonAsync`.

<strong>Error común:</strong>

<<< @/../code_samples/lib/get_it/signal_ready_error_example.dart#example

<strong>Por qué falla:</strong> Dentro de la factory async, la instancia aún no ha sido registrada. GetIt solo la añade al registro después de que la factory se completa. Por lo tanto, `signalReady(service)` falla porque GetIt aún no conoce sobre `service`.

<strong>Solución 1 - No uses signalsReady con registerSingletonAsync (recomendado):</strong>

La factory async automáticamente señaliza ready cuando se completa. No necesitas señalización manual:

<<< @/../code_samples/lib/get_it/signal_ready_correct_option1.dart#example

<strong>Solución 2 - Usa registerSingleton con signalsReady:</strong>

Si necesitas señalización manual, registra la instancia síncronamente y señaliza después de que esté en GetIt:

<<< @/../code_samples/lib/get_it/signal_ready_correct_option2.dart#example

<strong>Solución 3 - Implementa la interfaz WillSignalReady:</strong>

GetIt detecta automáticamente esta interfaz y espera la señalización manual:

<<< @/../code_samples/lib/get_it/signal_ready_correct_option3.dart#example

<strong>Cuándo usar cada enfoque:</strong>

- <strong>registerSingletonAsync</strong> - La factory maneja TODA la inicialización, devuelve instancia lista
- <strong>registerSingleton + signalsReady</strong> - La instancia necesita inicialización async DESPUÉS del registro
- <strong>Interfaz WillSignalReady</strong> - Alternativa más limpia al parámetro `signalsReady`

Mira la [documentación de Objetos Asíncronos](/es/documentation/get_it/async_objects#senalizacion-manual-de-ready) para detalles completos.
:::

## ¿Cómo pruebo código que usa get_it?

::: details Haz clic para ver la respuesta

Mira la [documentación de Pruebas](/es/documentation/get_it/testing) comprehensiva para patrones detallados de testing, incluyendo:
- Usar scopes para sombrear servicios con mocks
- Enfoques de testing de integración
- Mejores prácticas para setup y teardown de pruebas
:::

## ¿Dónde debería poner mi código de configuración de get_it?

::: details Haz clic para ver la respuesta

<strong>Principio clave:</strong> Organiza todos los registros en <strong>funciones dedicadas</strong> (no dispersos a través de tu app). Esto te permite reinicializar partes de tu app usando scopes.

<strong>Enfoque simple - función única:</strong>

<<< @/../code_samples/lib/get_it/configure_dependencies_example_9.dart#example

<strong>Mejor enfoque - dividir por característica/scope:</strong>
Divide los registros en funciones separadas que encapsulan la gestión de scope:


<<< @/../code_samples/lib/get_it/configure_core_dependencies_example.dart#example

<strong>Por qué importan las funciones:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Reutilizable</strong> - Llama la misma función al empujar scopes para reinicializar características</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Testeable</strong> - Llama funciones de registro específicas en setup de pruebas</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Organizado</strong> - Separación clara de responsabilidades por característica/capa</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Centralizado</strong> - Toda la lógica de registro en un lugar, no dispersa</li>
</ul>

<strong>No hagas:</strong>
❌️ Dispersar llamadas de registro a través de tu app
❌️ Llamar métodos de registro desde código de widget
❌️ Mezclar registro con lógica de negocio
❌️ Duplicar código de registro para diferentes scopes

Mira la [documentación de Scopes](/es/documentation/get_it/scopes) para más sobre arquitectura basada en scopes.
:::

## ¿Cuándo debería usar Scopes vs unregister/register?

::: details Haz clic para ver la respuesta

Usa <strong>scopes</strong> - están diseñados exactamente para este caso de uso:

<strong>Con Scopes (Recomendado ✅):</strong>

<<< @/../code_samples/lib/get_it/on_login_example.dart#example

<strong>Sin Scopes (No recomendado ❌️):</strong>

<<< @/../code_samples/lib/get_it/on_login.dart#example

<strong>Por qué los scopes son mejores:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Limpieza y restauración automática</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ No puedes olvidar re-registrar servicios originales</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Funciones dispose llamadas automáticamente</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Código más limpio y menos propenso a errores</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Puedes empujar múltiples scopes anidados</li>
</ul>

<strong>Usa unregister cuando:</strong>
- Verdaderamente estás removiendo un servicio permanentemente (raro)
- Estás reseteando durante el ciclo de vida de la app (usa `reset()` en su lugar)

Mira la [documentación de Scopes](/es/documentation/get_it/scopes) para más patrones.
:::

## ¿Puedo usar get_it con generación de código (injectable)?

::: details Haz clic para ver la respuesta

<strong>¡Sí!</strong> El paquete [`injectable`](https://pub.dev/packages/injectable) proporciona generación de código para registros de get_it usando anotaciones.

<strong>Sin injectable (manual):</strong>

<<< @/../code_samples/lib/get_it/configure_dependencies_example_10.dart#example

<strong>Con injectable (generado):</strong>

<<< @/../code_samples/lib/get_it/configure_dependencies_example_11.dart#example

<strong>Cuándo usar injectable:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Apps grandes con muchos servicios (50+)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Prefieres código declarativo sobre imperativo</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Quieres que la inyección de dependencias sea más automática</li>
</ul>

<strong>Cuándo el registro manual está bien:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Apps pequeñas a medianas (< 50 servicios)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Prefieres código explícito y directo</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Quieres evitar el paso de compilación de generación de código</li>
</ul>

<strong>Importante:</strong> injectable es <strong>opcional</strong>. ¡get_it funciona genial sin él! La documentación aquí se enfoca en registro manual, que es más simple de aprender y funciona para la mayoría de las apps.

Mira la [documentación de injectable](https://pub.dev/packages/injectable) si quieres usarlo.
:::

## ¿Cómo paso parámetros a factories?

::: details Haz clic para ver la respuesta

Mira la [documentación de Registro de Objetos](/es/documentation/get_it/object_registration#pasando-parametros-a-factories) para información detallada sobre:
- Usar `registerFactoryParam()` con uno o dos parámetros
- Ejemplos prácticos con diferentes tipos de parámetros
- Patrones alternativos para 3+ parámetros usando objetos de configuración
:::

## get_it vs Provider - ¿cuál debería usar?

::: details Haz clic para ver la respuesta

<strong>Importante:</strong> get_it y Provider sirven <strong>propósitos diferentes</strong>, aunque a menudo se confunden.

<strong>get_it</strong> es un <strong>localizador de servicios</strong> para inyección de dependencias:
- Gestiona instancias de servicio/repositorio
- No específicamente para gestión de estado de UI
- Desacopla interfaz de implementación
- Funciona en cualquier parte de tu app (no atado al árbol de widgets)

<strong>Provider</strong> es para <strong>propagación de estado</strong> por el árbol de widgets:
- Pasa datos/estado a widgets descendientes eficientemente
- Alternativa a InheritedWidget
- Atado a la posición del árbol de widgets
- Principalmente para estado de UI

<strong>¡Puedes usar ambos juntos!</strong>

<<< @/../code_samples/lib/get_it/my_app_example_1.dart#example

<strong>O usa get_it + `watch_it` en su lugar:</strong>

<<< @/../code_samples/lib/get_it/login_page_example_1.dart#example

<strong>Elige:</strong>
- <strong>solo get_it</strong>: Si ya tienes gestión de estado (BLoC, Riverpod, etc.)
- <strong>get_it + `watch_it`</strong>: DI todo en uno + gestión de estado reactiva
- <strong>get_it + Provider</strong>: Si ya estás usando Provider y quieres mejor DI

<strong>Conclusión:</strong> get_it es para localización de servicios, `watch_it` (construido sobre get_it) maneja tanto DI como estado. Provider es ortogonal - puedes usarlo con o sin get_it.

Mira la [documentación de `watch_it`](/documentation/watch_it/getting_started) para la solución completa.
:::

## ¿Cómo re-registro un servicio después de unregister?

::: details Haz clic para ver la respuesta

<strong>¡No uses unregister + register para logout/login!</strong> Usa <strong>scopes</strong> en su lugar (mira la FAQ arriba).

Pero si realmente necesitas desregistrar y re-registrar:

<strong>Patrón problemático:</strong>

<<< @/../code_samples/lib/get_it/on_logout_example.dart#example

<strong>Solución 1: Await unregister</strong>

<<< @/../code_samples/lib/get_it/on_logout_example_1.dart#example

<strong>Solución 2: Usa la función disposing de unregister</strong>

<<< @/../code_samples/lib/get_it/code_sample_9b560463.dart#example

<strong>Solución 3: Resetea lazy singleton en su lugar</strong>
Si quieres mantener el registro pero resetear la instancia:

<<< @/../code_samples/lib/get_it/code_sample_a449e220.dart#example

<strong>Por qué importa el await:</strong>
- Si tu objeto implementa `Disposable` o tiene una función dispose, unregister la llama
- Estas funciones dispose pueden ser `async`
- Si no haces await, el siguiente registro podría ocurrir antes de que el disposal se complete
- Esto causa errores de "already registered"

<strong>Nuevamente, prefiere fuertemente scopes sobre unregister/register:</strong>

<<< @/../code_samples/lib/get_it/code_sample_657c692e.dart#example

¡Mucho más limpio y menos propenso a errores!
:::
