---
title: Scopes
---

# Scopes

Los scopes proporcionan **gestión jerárquica del ciclo de vida** para tus objetos de negocio, independiente del árbol de widgets.

::: info Scopes de get_it vs Scoping del Árbol de Widgets (Provider, InheritedWidget)
**Los scopes de get_it son intencionalmente independientes del árbol de widgets.** Gestionan el ciclo de vida de objetos de negocio basándose en el estado de la aplicación (login/logout, sesiones, características), no en la posición del widget.

Para **scoping del tiempo de vida del widget**, usa [`pushScope` de `watch_it`](/documentation/watch_it/getting_started) que automáticamente empuja un scope de get_it durante el tiempo de vida de un widget.
:::

## ¿Qué son los Scopes?

Piensa en los scopes como una **pila de capas de registro**. Cuando registras un tipo en un nuevo scope, este oculta (sombrea) cualquier registro del mismo tipo en scopes inferiores. Hacer pop de un scope automáticamente restaura los registros anteriores y limpia los recursos.

<div class="diagram-dark">

![Visualización de la Pila de Scopes](/images/scopes-stack.svg)

</div>

<div class="diagram-light">

![Visualización de la Pila de Scopes](/images/scopes-stack-light.svg)

</div>

### Cómo Funciona el Shadowing


<<< @/../code_samples/lib/get_it/user.dart#example

El orden de búsqueda es **de arriba hacia abajo** - get_it siempre devuelve la primera coincidencia empezando desde el scope actual.

---

## Cuándo Usar Scopes

### ✅ Casos de Uso Perfectos

**1. Estados de Autenticación**

<<< @/../code_samples/lib/get_it/user_1.dart#example

**2. Gestión de Sesiones**

<<< @/../code_samples/lib/get_it/shopping_cart.dart#example

**3. Feature Flags / Pruebas A-B**

<<< @/../code_samples/lib/get_it/checkout_service_example.dart#example

**4. Aislamiento de Pruebas**

<<< @/../code_samples/lib/get_it/api_client_example.dart#example

---

## Creando y Gestionando Scopes

### Operaciones Básicas de Scope


<<< @/../code_samples/lib/get_it/service_example.dart#example

### Inicialización Asíncrona de Scope

Cuando la configuración del scope requiere operaciones asíncronas (cargar archivos de configuración, establecer conexiones):


<<< @/../code_samples/lib/get_it/tenant_config_example.dart#example

::: tip Dependencias Asíncronas Entre Servicios
Para servicios con inicialización asíncrona que **dependen entre sí**, usa `registerSingletonAsync` con el parámetro `dependsOn` en su lugar. Mira la [documentación de Objetos Asíncronos](/es/documentation/get_it/async_objects) para detalles.
:::

---

## Características Avanzadas de Scope

### Scopes Finales (Prevenir Registros Accidentales)

Previene condiciones de carrera bloqueando un scope después de la inicialización:


<<< @/../code_samples/lib/get_it/service_a_example.dart#example

**Úsalo cuando:**
- Construyas sistemas de plugins donde la configuración del scope debe ser atómica
- Prevenir registro accidental después de la inicialización del scope

### Shadow Change Handlers

Los objetos pueden ser notificados cuando son sombreados o restaurados:


<<< @/../code_samples/lib/get_it/init_example.dart#example

**Casos de uso:**
- Servicios pesados en recursos que deberían pausarse cuando están inactivos
- Servicios con suscripciones que necesitan limpieza/restauración
- Prevenir trabajo duplicado en segundo plano

### Notificaciones de Cambio de Scope

Recibe notificación cuando ocurre cualquier cambio de scope:


<<< @/../code_samples/lib/get_it/code_sample_062bd775.dart#example

**Nota:** `watch_it` maneja automáticamente las reconstrucciones de UI en cambios de scope vía `rebuildOnScopeChanges`.

---

## Ciclo de Vida y Disposal de Scope

### Orden de Disposal

Cuando se hace pop de un scope:

1. **La función dispose del scope** es llamada (si se proporcionó)
2. **Las funciones dispose de objetos** son llamadas en orden inverso de registro
3. **El scope es removido** de la pila

<<< @/../code_samples/lib/get_it/scopes_4c72f192.dart#example


### Implementando la Interfaz Disposable

En lugar de pasar funciones dispose, implementa `Disposable`:


<<< @/../code_samples/lib/get_it/init_example_1.dart#example

### Reset vs Pop


<<< @/../code_samples/lib/get_it/code_sample_39fe26fa.dart#example

---

## Patrones Comunes

### Flujo de Login/Logout


<<< @/../code_samples/lib/get_it/auth_service_example.dart#example

::: details Aplicaciones Multi-Tenant

<<< @/../code_samples/lib/get_it/tenant_manager_example.dart#example
:::

::: details Feature Toggles con Scopes

<<< @/../code_samples/lib/get_it/enable_feature_example.dart#example
:::

::: details Testing con Scopes

Usa scopes para sombrear servicios reales con mocks mientras mantienes el resto de tu configuración DI:

<<< @/../code_samples/lib/get_it/api_client.dart#example

**Beneficios:**
- No necesitas duplicar todos los registros en pruebas
- Solo simula lo necesario (ApiClient, Database)
- Otros servicios usan implementaciones reales
- Limpieza automática vía popScope()
:::

---

## Depurando Scopes

### Verificar el Scope Actual


<<< @/../code_samples/lib/get_it/code_sample_e395f3ff.dart#example

::: details Verificar Scope de Registro

<<< @/../code_samples/lib/get_it/code_sample_661a189f.dart#example
:::

::: details Verificar que Existe un Scope

<<< @/../code_samples/lib/get_it/code_sample_0eb8db1b.dart#example
:::

---

## Mejores Prácticas

### ✅ Haz

- **Nombra tus scopes** para depuración y gestión más fácil
- **Usa el parámetro init** para registrar objetos inmediatamente al empujar el scope
- **Siempre haz await de popScope()** para asegurar limpieza apropiada
- **Implementa Disposable** para limpieza automática en lugar de pasar funciones dispose
- **Usa scopes para el ciclo de vida de lógica de negocio**, no para estado de UI

### ❌️ No Hagas

- **No uses scopes para estado temporal** - usa parámetros o variables en su lugar
- **No olvides hacer pop de scopes** - fugas de memoria si los scopes se acumulan
- **No dependas del orden de scope** para lógica - usa dependencias explícitas
- **No empujes scopes dentro de métodos build** - usa `pushScope` de `watch_it` para scopes ligados a widgets

---

## Scopes Ligados a Widgets con `watch_it`

Para scopes ligados al tiempo de vida del widget, usa **`watch_it`**:


<<< @/../code_samples/lib/get_it/user_profile_page_example.dart#example

Mira la [documentación de `watch_it`](/documentation/watch_it/getting_started) para detalles.

---

## Referencia de API

### Gestión de Scope

| Método | Descripción |
|--------|-------------|
| `pushNewScope({init, scopeName, dispose, isFinal})` | Empuja un nuevo scope con registro inmediato opcional |
| `pushNewScopeAsync({init, scopeName, dispose})` | Empuja scope con inicialización asíncrona |
| `popScope()` | Hace pop del scope actual y dispone objetos |
| `popScopesTill(name, {inclusive})` | Hace pop de todos los scopes hasta el scope nombrado |
| `dropScope(scopeName)` | Elimina scope específico por nombre |
| `resetScope({dispose})` | Limpia los registros del scope actual |
| `hasScope(scopeName)` | Verifica si existe un scope |
| `currentScopeName` | Obtiene el nombre del scope actual (getter) |

### Callbacks de Scope

| Propiedad | Descripción |
|----------|-------------|
| `onScopeChanged` | Llamado cuando se empuja/hace pop de un scope |

### Ciclo de Vida del Objeto

| Interfaz | Descripción |
|-----------|-------------|
| `ShadowChangeHandlers` | Implementa para ser notificado cuando es sombreado |
| `Disposable` | Implementa para limpieza automática |

---

## Ver También

- [Registro de Objetos](/es/documentation/get_it/object_registration) - Cómo registrar objetos
- [Objetos Asíncronos](/es/documentation/get_it/async_objects) - Trabajando con inicialización asíncrona
- [Pruebas](/es/documentation/get_it/testing) - Usando scopes en pruebas
- [`watch_it` pushScope](/documentation/watch_it/getting_started) - Scoping ligado a widgets
