---
title: Pruebas
---

# Pruebas

Probar código que usa get_it requiere diferentes enfoques dependiendo de si estás escribiendo pruebas unitarias, pruebas de widget o pruebas de integración. Esta guía cubre mejores prácticas y patrones comunes.

## Inicio Rápido: El Patrón de Scope (Recomendado)

<strong>Mejor práctica:</strong> Usa <strong>scopes</strong> para sombrear servicios reales con dobles de prueba. Esto es más limpio y mantenible que resetear get_it o usar registro condicional.


<<< @/../code_samples/lib/get_it/main_example_1.dart#example

<strong>Beneficios clave:</strong>
- Solo sobrescribes lo que necesitas para cada prueba
- Limpieza automática entre pruebas
- La misma `configureDependencies()` que en producción

---

## Patrones de Pruebas Unitarias

### Patrón 1: Testing Basado en Scopes (Recomendado)

Usa scopes para inyectar mocks para servicios específicos mientras mantienes el resto de tu grafo de dependencias intacto. Registrar una implementación diferente en un scope funciona de la misma manera - usando el parámetro de tipo genérico para sombrear el registro original.


<<< @/../code_samples/lib/get_it/main_example_2.dart#example

### Patrón 2: Registro Condicional (Alternativa)

En lugar de usar scopes, puedes cambiar implementaciones en tiempo de registro usando un flag:


<<< @/../code_samples/lib/get_it/conditional_registration_example.dart#example

Este enfoque es más simple pero menos flexible que los scopes - debes decidir qué implementación usar antes del registro, y no puedes cambiar fácilmente durante el tiempo de ejecución.

::: tip Shadowing Basado en Tipos
Cuando registras `MockPaymentProcessor` como `<PaymentProcessor>`, get_it usa el **parámetro de tipo** como clave de búsqueda, no la clase concreta. Esto es lo que permite cambiar implementaciones—la misma clave recupera diferentes objetos en diferentes contextos.
:::

### Patrón 3: Inyección por Constructor para Pruebas Unitarias Puras

Para probar clases en completo aislamiento (sin get_it), usa parámetros de constructor opcionales.


<<< @/../code_samples/lib/get_it/user_manager_example.dart#example

<strong>Cuándo usar:</strong>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Probar lógica de negocio pura en aislamiento</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Clases que no necesitan el grafo completo de dependencias</li>
</ul>
<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">❌️ Pruebas estilo integración donde quieres dependencias reales</li>
</ul>

---

## Testing de Widgets

### Probando Widgets que Usan get_it

Los widgets a menudo recuperan servicios de get_it. Usa scopes para proporcionar implementaciones específicas de prueba.


<<< @/../code_samples/lib/get_it/main.dart#example

### Testing con Registros Asíncronos

Si tu app usa `registerSingletonAsync`, asegúrate de que los servicios async estén listos antes de probar.


<<< @/../code_samples/lib/get_it/code_sample_d18eeb0d.dart#example

---

## Testing de Factories

### Probando Registros de Factory

Las factories crean nuevas instancias en cada llamada a `get()` - verifica este comportamiento en las pruebas.


<<< @/../code_samples/lib/get_it/shopping_cart_1.dart#example

### Probando Factories Parametrizadas


<<< @/../code_samples/lib/get_it/code_sample_5f4e16d1.dart#example

---

## Escenarios Comunes de Testing

::: details Escenario 1: Probando Servicio con Múltiples Dependencias

<<< @/../code_samples/lib/get_it/api_client_1.dart#example
:::

::: details Escenario 2: Probando Servicios con Scope

<<< @/../code_samples/lib/get_it/code_sample_2fee2227.dart#example
:::

::: details Escenario 3: Probando Disposal

<<< @/../code_samples/lib/get_it/disposable_service_example.dart#example
:::

---

## Mejores Prácticas

### ✅ Haz

1. <strong>Usa scopes para aislamiento de pruebas</strong>

   <<< @/../code_samples/lib/get_it/testing_f1b668dd_signature.dart#example

2. <strong>Registra dependencias reales una vez en `setUpAll()`</strong>

   <<< @/../code_samples/lib/get_it/testing_c8fe4e9b_signature.dart#example

3. <strong>Sombrea solo lo que necesitas simular</strong>

   <<< @/../code_samples/lib/get_it/testing_8dbacaca_signature.dart#example

4. <strong>Haz await de `popScope()` si los servicios tienen disposal async</strong>

   <<< @/../code_samples/lib/get_it/testing_93df6902_signature.dart#example

5. <strong>Usa `allReady()` para registros async</strong>

   <<< @/../code_samples/lib/get_it/testing_cc70be3d.dart#example

### ❌️ No Hagas

1. <strong>No llames a `reset()` entre pruebas</strong>

   <<< @/../code_samples/lib/get_it/testing_0a7443ea.dart#example

2. <strong>No re-registres todo en cada prueba</strong>

   <<< @/../code_samples/lib/get_it/testing_138c49df_signature.dart#example

3. <strong>No uses `allowReassignment` en pruebas</strong>

   <<< @/../code_samples/lib/get_it/testing_a862f724_signature.dart#example

4. <strong>No olvides hacer pop de scopes en tearDown</strong>

   <<< @/../code_samples/lib/get_it/testing_4bac3b7c_signature.dart#example


---

## Solución de Problemas

### "Object/factory already registered" en pruebas


<strong>Causa:</strong> El scope no se hizo pop en la prueba anterior, o no se esperó a `reset()`.

<strong>Solución:</strong>

<<< @/../code_samples/lib/get_it/testing_ac521152_signature.dart#example


### Los Mocks no se están usando

<strong>Causa:</strong> El mock fue registrado en el scope equivocado o después de que el servicio ya fue creado.

<strong>Solución:</strong> Empuja el scope y registra mocks <strong>antes</strong> de acceder a los servicios:

<<< @/../code_samples/lib/get_it/testing_78522d78_signature.dart#example


### El servicio async no está listo

<strong>Causa:</strong> Intentando acceder a registro async antes de que se complete.

<strong>Solución:</strong>

<<< @/../code_samples/lib/get_it/testing_9153fb06_signature.dart#example


---

## Ver También

- [Scopes](/es/documentation/get_it/scopes) - Documentación detallada de scopes
- [Registro de Objetos](/es/documentation/get_it/object_registration) - Tipos de registro
