---
title: ¿Qué hacer con cada paquete?
---

<div class="header-with-logo">
  <div class="header-content">

# ¿Qué hacer con cada paquete?

**flutter_it es un kit de herramientas** - cada paquete resuelve un problema específico. Usa uno, combina varios, o úsalos todos juntos. Esta guía te ayuda a elegir las herramientas correctas para tus necesidades.

  </div>
  <img src="/images/main-logo.svg" alt="flutter_it" width="225" class="header-logo" />
</div>

## Guía Rápida de Decisión

| Necesitas... | Usa este paquete |
|----------------|------------------|
| Acceder a servicios/dependencias desde cualquier parte de tu app | **get_it** |
| Actualizar la UI automáticamente cuando los datos cambian | **`watch_it`** + **get_it** |
| Manejar acciones asíncronas con estados de carga/error | **command_it** |
| Transformar, combinar datos reactivos o usar colecciones observables | **listen_it** |

---

## ¿Por qué estos paquetes?

Una buena arquitectura Flutter sigue principios clave: **separación de responsabilidades**, **única fuente de verdad**, y **testabilidad**. Los paquetes flutter_it te ayudan a implementar estos principios sin la complejidad de los frameworks tradicionales.

> 💡 **¿Nuevo en arquitectura Flutter?** [Salta a los principios de arquitectura detallados](#principios-de-arquitectura) para entender la base.

<div class="diagram-dark">

![Arquitectura flutter_it](/images/architecture-diagram.svg)

</div>

<div class="diagram-light">

![Arquitectura flutter_it](/images/architecture-diagram-light.svg)

</div>

---

## Los Problemas que Resuelve Cada Paquete

### <img src="/images/get_it.svg" alt="get_it" width="50" style="vertical-align: middle; margin-right: 0.5rem; display: inline-block;" />get_it - Accede a cualquier cosa, desde cualquier lugar

**Problema**: ¿Cómo accedo a servicios, lógica de negocio y datos compartidos sin pasarlos a través del árbol de widgets?

**Solución**: Patrón Service Locator - registra una vez, accede desde cualquier lugar sin BuildContext.

**Úsalo cuando**:
- Necesites dependency injection sin el árbol de widgets
- Quieras compartir servicios a través de tu app
- Necesites control sobre el ciclo de vida de objetos (singletons, factories, scopes)
- Quieras probar tu lógica de negocio de forma independiente

**Caso de uso ejemplo**: Acceder a un servicio de API desde cualquier parte de tu app.

![Flujo de datos get_it](/images/get-it-flow.svg?v=2)

[Comienza con get_it →](/es/documentation/get_it/getting_started)

---

### <img src="/images/watch_it.svg" alt="watch_it" width="50" style="vertical-align: middle; margin-right: 0.5rem; display: inline-block;" />`watch_it` - Actualizaciones de UI reactivas

**Problema**: ¿Cómo actualizo mi UI cuando los datos cambian sin setState() o gestión de estado compleja?

**Solución**: Observa ValueListenable/ChangeNotifier y reconstruye automáticamente - casi nunca necesitarás StatefulWidget otra vez.

**Úsalo cuando**:
- Quieras actualizaciones automáticas de UI cuando cambien los datos
- Quieras eliminar el boilerplate de StatefulWidget y setState()
- Necesites reconstrucciones granulares (solo los widgets afectados)
- Estés cansado de gestionar suscripciones manualmente

**Caso de uso ejemplo**: Un widget contador que se reconstruye cuando cambia el conteo.

**Requiere**: get_it para la localización de servicios

![Flujo de datos watch_it](/images/watch-it-flow.svg)

[Comienza con watch_it →](/documentation/watch_it/getting_started)

---

### <img src="/images/command_it.svg" alt="command_it" width="67" style="vertical-align: middle; margin-right: 0.5rem; display: inline-block;" />command_it - Encapsulación inteligente de acciones

**Problema**: ¿Cómo manejo operaciones asíncronas con estados de carga, errores y lógica de habilitación/deshabilitación sin boilerplate repetitivo?

**Solución**: Patrón Command con gestión de estado incluida - maneja excepciones de forma inteligente.

**Úsalo cuando**:
- Tengas operaciones asíncronas (llamadas API, operaciones de base de datos)
- Necesites indicadores de carga y manejo de errores
- Quieras habilitar/deshabilitar acciones basándote en condiciones
- Quieras lógica de acciones reutilizable y testeable

**Caso de uso ejemplo**: Un botón de guardar que muestra estado de carga, maneja errores y puede ser deshabilitado.

![Flujo de datos command_it](/images/command-it-flow.svg)

[Comienza con command_it →](/documentation/command_it/getting_started)

---

### <img src="/images/listen_it.svg" alt="listen_it" width="50" style="vertical-align: middle; margin-right: 0.5rem; display: inline-block;" />listen_it - Primitivas reactivas

**Problema**: ¿Cómo transformo, combino, filtro datos reactivos? ¿Cómo hago colecciones observables?

**Solución**: Operadores al estilo RxDart para ValueNotifier que son fáciles de entender, además de colecciones reactivas (ListNotifier, MapNotifier, SetNotifier).

**Úsalo cuando**:
- Necesites transformar datos de ValueListenable (map, where, debounce)
- Necesites combinar múltiples ValueListenables en uno
- Quieras Listas, Maps o Sets observables que notifiquen los cambios
- Necesites pipelines de datos reactivos sin la complejidad de RxDart

**Caso de uso ejemplo**: Aplicar debounce a una entrada de búsqueda, o un carrito de compras que notifica cambios en los items.

![Flujo de datos listen_it](/images/listen-it-flow.svg)

[Comienza con listen_it →](/documentation/listen_it/listen_it)

---

## Combinaciones Comunes de Paquetes

### Configuración Mínima: [get_it](/es/documentation/get_it/getting_started) + [`watch_it`](/documentation/watch_it/getting_started)
Perfecto para apps que necesitan dependency injection y UI reactiva. Cubre el 90% de las necesidades típicas de una app.

**Ejemplo**: La mayoría de apps CRUD, apps de dashboard, apps con muchos formularios.

### Stack Completo: Los 4 paquetes
Arquitectura reactiva completa con dependency injection, UI reactiva, patrón Command y transformaciones de datos.

**Ejemplo**: Apps complejas con integración de API, actualizaciones en tiempo real y transformaciones de estado sofisticadas.

### Casos de Uso Independientes

Cada paquete funciona de forma independiente:

- **Solo [get_it](/es/documentation/get_it/getting_started)**: Dependency injection simple sin reactividad
- **Solo [listen_it](/documentation/listen_it/listen_it)**: Operadores/colecciones reactivas sin dependency injection
- **Solo [command_it](/documentation/command_it/getting_started)**: Patrón Command para encapsular acciones

---

## Principios de Arquitectura

### ¿Por qué separar tu código en capas?

Los paquetes flutter_it permiten arquitectura limpia resolviendo problemas específicos que surgen cuando separas responsabilidades:

**El Objetivo**: Mantener la lógica de negocio separada de la UI, mantener una única fuente de verdad, hacer todo testeable.

**El Desafío**: Una vez que mueves los datos fuera de los widgets, necesitas:
1. Una forma de acceder a esos datos desde cualquier lugar → **[get_it](/es/documentation/get_it/getting_started)** resuelve esto
2. Una forma de actualizar la UI cuando los datos cambian → **[`watch_it`](/documentation/watch_it/getting_started)** resuelve esto
3. Una forma de manejar operaciones asíncronas limpiamente → **[command_it](/documentation/command_it/getting_started)** resuelve esto
4. Una forma de transformar y combinar datos reactivos → **[listen_it](/documentation/listen_it/listen_it)** resuelve esto

### Separación de responsabilidades

Diferentes partes de tu aplicación deberían tener diferentes responsabilidades:

- **Capa de UI**: Muestra datos y maneja interacciones del usuario
- **Capa de lógica de negocio**: Procesa datos e implementa reglas de la app
- **Capa de servicios**: Se comunica con sistemas externos (APIs, bases de datos, características del dispositivo)

Al separar estas capas, puedes:
- Cambiar una parte sin afectar las otras
- Probar lógica de negocio sin UI
- Reutilizar lógica a través de diferentes pantallas

### Única fuente de verdad

Cada pieza de datos debería vivir exactamente en un lugar. Si tienes una lista de usuarios, debería haber una lista, no múltiples copias a través de diferentes widgets.

Beneficios:
- Los datos se mantienen consistentes a través de tu app
- Las actualizaciones ocurren en un solo lugar
- Más fácil de depurar y mantener

### Testabilidad

Tu app debería estar diseñada para facilitar las pruebas:
- La lógica de negocio puede probarse sin widgets Flutter
- Los servicios pueden simularse (mock) para pruebas unitarias
- La UI puede probarse independientemente con datos de prueba

**Para una discusión comprehensiva**, mira [Practical Flutter Architecture](https://blog.burkharts.net/practical-flutter-architecture).

---

## Siguientes Pasos

**¿Listo para comenzar?** Elige tu primer paquete:

- [Comienza con get_it →](/es/documentation/get_it/getting_started)
- [Comienza con watch_it →](/documentation/watch_it/getting_started)
- [Comienza con command_it →](/documentation/command_it/getting_started)
- [Comienza con listen_it →](/documentation/listen_it/listen_it)

**¿Aún no estás seguro?** Revisa [ejemplos del mundo real](/examples/overview) para ver los paquetes en acción.
