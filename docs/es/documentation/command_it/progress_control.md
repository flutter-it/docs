# Control de Progreso

Los Commands soportan **tracking de progreso** integrado, **mensajes de estado**, y **cancelación cooperativa** a través de la clase `ProgressHandle`. Esto te permite proporcionar feedback rico a los usuarios durante operaciones de larga duración como subida de archivos, sincronización de datos, o procesamiento por lotes.

## Resumen

El Control de Progreso proporciona tres capacidades clave:

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Tracking de progreso</strong> - Reporta progreso de operación desde 0.0 (0%) hasta 1.0 (100%)</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Mensajes de estado</strong> - Proporciona actualizaciones de estado legibles durante la ejecución</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Cancelación cooperativa</strong> - Permite que las operaciones sean canceladas elegantemente</li>
</ul>

**Beneficios clave:**

- **Cero overhead** - Commands sin progreso usan notifiers estáticos por defecto (sin costo de memoria)
- **API no-nullable** - Todas las propiedades de progreso disponibles en cada command
- **Type-safe** - Inferencia de tipos completa y verificación en tiempo de compilación
- **Reactivo** - Todas las propiedades son <code>ValueListenable</code> para observación de UI

## Ejemplo Rápido

<<< @/../code_samples/lib/command_it/progress_upload_basic.dart#example

```dart
// En UI (con watch_it):
final progress = watchValue((MyService s) => s.uploadCommand.progress);
final status = watchValue((MyService s) => s.uploadCommand.statusMessage);

LinearProgressIndicator(value: progress)  // 0.0 a 1.0
Text(status ?? '')  // 'Subiendo: 50%'
IconButton(
  onPressed: uploadCommand.cancel,  // Solicitar cancelación
  icon: Icon(Icons.cancel),
)
```

## Creando Commands con Progreso

Usa las variantes factory `WithProgress` para crear commands que reciben un `ProgressHandle`:

### Commands Async con Progreso

<<< @/../code_samples/lib/command_it/progress_factory_variants.dart#main

Las cuatro variantes async están disponibles:

| Método Factory | Firma de Función |
|---------------|-------------------|
| `createAsyncWithProgress` | `(param, handle) async => TResult` |
| `createAsyncNoParamWithProgress` | `(handle) async => TResult` |
| `createAsyncNoResultWithProgress` | `(param, handle) async => void` |
| `createAsyncNoParamNoResultWithProgress` | `(handle) async => void` |

### Commands Undoable con Progreso

Combina capacidad de undo con tracking de progreso:

<<< @/../code_samples/lib/command_it/progress_undoable.dart#example

Las cuatro variantes undoable están disponibles:
- `createUndoableWithProgress<TParam, TResult, TUndoState>()`
- `createUndoableNoParamWithProgress<TResult, TUndoState>()`
- `createUndoableNoResultWithProgress<TParam, TUndoState>()`
- `createUndoableNoParamNoResultWithProgress<TUndoState>()`

## Propiedades de Progreso

Todos los commands (incluso aquellos sin progreso) exponen estas propiedades:

### progress

Valor de progreso observable desde 0.0 (0%) hasta 1.0 (100%):

```dart
final command = Command.createAsyncWithProgress<void, String>(
  (_, handle) async {
    handle.updateProgress(0.0);   // Inicio
    await step1();
    handle.updateProgress(0.33);  // 33%
    await step2();
    handle.updateProgress(0.66);  // 66%
    await step3();
    handle.updateProgress(1.0);   // Completo
    return 'Hecho';
  },
  initialValue: '',
);

// En UI:
final progress = watchValue((MyService s) => s.command.progress);
LinearProgressIndicator(value: progress)  // Barra de progreso de Flutter
```

**Tipo:** <code>ValueListenable&lt;double&gt;</code>
**Rango:** 0.0 a 1.0 (inclusivo)
**Por defecto:** 0.0 para commands sin `ProgressHandle`

### statusMessage

Mensaje de estado observable proporcionando estado de operación legible:

```dart
handle.updateStatusMessage('Descargando...');
handle.updateStatusMessage('Procesando...');
handle.updateStatusMessage(null);  // Limpiar mensaje

// En UI:
final status = watchValue((MyService s) => s.command.statusMessage);
Text(status ?? 'Inactivo')
```

**Tipo:** <code>ValueListenable&lt;String?&gt;</code>
**Por defecto:** `null` para commands sin `ProgressHandle`

### isCanceled

Flag de cancelación observable. La función envuelta debe verificar esto periódicamente y manejar la cancelación cooperativamente:

```dart
final command = Command.createAsyncWithProgress<void, String>(
  (_, handle) async {
    for (int i = 0; i < 100; i++) {
      // Verificar cancelación antes de cada iteración
      if (handle.isCanceled.value) {
        return 'Cancelado en paso $i';
      }

      await processStep(i);
      handle.updateProgress((i + 1) / 100);
    }
    return 'Completo';
  },
  initialValue: '',
);

// En UI:
final isCanceled = watchValue((MyService s) => s.command.isCanceled);
if (isCanceled) Text('Operación cancelada')
```

**Tipo:** <code>ValueListenable&lt;bool&gt;</code>
**Por defecto:** `false` para commands sin `ProgressHandle`

### cancel()

Solicita cancelación cooperativa de la operación. Este método:

- Establece `isCanceled` a `true`
- Limpia `progress` a `0.0`
- Limpia `statusMessage` a `null`

Esto inmediatamente limpia el estado de progreso de la UI, proporcionando feedback visual instantáneo de que la operación fue cancelada.

```dart
// En UI:
IconButton(
  onPressed: command.cancel,
  icon: Icon(Icons.cancel),
)

// O programáticamente:
if (userNavigatedAway) {
  command.cancel();
}
```

**Importante:** Esto **no** detiene forzadamente la ejecución. La función envuelta debe verificar `isCanceled.value` y responder apropiadamente (ej., retornar temprano, lanzar excepción, limpiar recursos).

### resetProgress()

Resetea o inicializa manualmente el estado de progreso:

```dart
// Resetear a valores por defecto (0.0, null, false)
command.resetProgress();

// Inicializar a valores específicos (ej., resumiendo una operación)
command.resetProgress(
  progress: 0.5,
  statusMessage: 'Resumiendo subida...',
);

// Limpiar progreso 100% después de completar
if (command.progress.value == 1.0) {
  await Future.delayed(Duration(seconds: 2));
  command.resetProgress();
}
```

**Parámetros:**
- `progress` - Valor inicial de progreso opcional (0.0-1.0), por defecto 0.0
- `statusMessage` - Mensaje de estado inicial opcional, por defecto null

**Casos de uso:**
- Limpiar progreso 100% de UI después de completación exitosa
- Inicializar commands para resumir desde un punto específico
- Resetear progreso entre ejecuciones manuales
- Preparar estado de command para testing

**Nota:** El progreso se resetea automáticamente al inicio de cada ejecución de `run()`, así que los resets manuales típicamente solo se necesitan para limpieza de UI o resumir operaciones. Adicionalmente, llamar `cancel()` también limpia progress y statusMessage para proporcionar feedback visual inmediato.

## Patrones de Integración

### Con Indicadores de Progreso de Flutter

```dart
// Barra de progreso lineal
final progress = watchValue((MyService s) => s.uploadCommand.progress);
LinearProgressIndicator(value: progress)

// Indicador de progreso circular
CircularProgressIndicator(value: progress)

// Display de progreso personalizado
Text('${(progress * 100).toInt()}% completo')
```

### Con Tokens de Cancelación Externos

La propiedad `isCanceled` es un `ValueListenable`, permitiéndote enviar cancelación a librerías externas como Dio:

<<< @/../code_samples/lib/command_it/progress_dio_integration.dart#example

## Commands Sin Progreso

Los commands creados con factories regulares (sin `WithProgress`) aún tienen propiedades de progreso, pero retornan valores por defecto:

```dart
final command = Command.createAsync<void, String>(
  (_) async => 'Hecho',
  initialValue: '',
);

// Estas propiedades existen pero retornan valores por defecto:
command.progress.value        // Siempre 0.0
command.statusMessage.value   // Siempre null
command.isCanceled.value      // Siempre false
command.cancel()              // Sin efecto (sin progress handle)
```

Este diseño de cero overhead significa:

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ El código de UI siempre puede acceder propiedades de progreso sin verificaciones null</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Sin costo de memoria para commands que no necesitan progreso</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ Fácil agregar progreso a commands existentes después (solo cambia factory)</li>
</ul>

## Testing con MockCommand

MockCommand soporta simulación completa de progreso para testing:

<<< @/../code_samples/lib/command_it/progress_mock_testing.dart#example

**Métodos de progreso de MockCommand:**
- `updateMockProgress(double value)` - Simula actualizaciones de progreso
- `updateMockStatusMessage(String? message)` - Simula actualizaciones de estado
- `mockCancel()` - Simula cancelación

Todos requieren `withProgressHandle: true` en el constructor.

Ver [Testing](testing.md) para más detalles.

## Mejores Prácticas

### SÍ: Verificar cancelación frecuentemente

```dart
// ✅ Bien - verifica antes de cada operación costosa
for (final item in items) {
  if (handle.isCanceled.value) return 'Cancelado';
  await processItem(item);
  handle.updateProgress(progress);
}
```

### NO: Verificar cancelación muy infrecuentemente

```dart
// ❌ Mal - solo verifica una vez al inicio
if (handle.isCanceled.value) return 'Cancelado';
for (final item in items) {
  await processItem(item);  // No puede cancelar durante procesamiento
}
```

## Consideraciones de Rendimiento

**Las actualizaciones de progreso son ligeras** - cada actualización es solo una asignación de ValueNotifier. Sin embargo, evita actualizaciones excesivas:

```dart
// ❌ Potencialmente excesivo - actualiza cada byte
for (int i = 0; i < 1000000; i++) {
  process(i);
  handle.updateProgress(i / 1000000);  // ¡1M actualizaciones de UI!
}

// ✅ Mejor - throttle de actualizaciones
final updateInterval = 1000000 ~/ 100;  // Actualizar cada 1%
for (int i = 0; i < 1000000; i++) {
  process(i);
  if (i % updateInterval == 0) {
    handle.updateProgress(i / 1000000);  // 100 actualizaciones de UI
  }
}
```

Para operaciones de muy alta frecuencia, considera actualizar cada N iteraciones o usar un timer para throttle de actualizaciones.

## Patrones Comunes

### Operaciones Multi-Paso

<<< @/../code_samples/lib/command_it/progress_multi_step.dart#example

### Procesamiento por Lotes con Progreso

<<< @/../code_samples/lib/command_it/progress_batch_processing.dart#example

### Progreso Indeterminado

Para operaciones donde el progreso no puede calcularse:

```dart
final command = Command.createAsyncWithProgress<void, String>(
  (_, handle) async {
    handle.updateStatusMessage('Conectando al servidor...');
    await connect();

    handle.updateStatusMessage('Autenticando...');
    await authenticate();

    handle.updateStatusMessage('Cargando datos...');
    await loadData();

    // No actualiza progreso - UI puede mostrar indicador indeterminado
    return 'Completo';
  },
  initialValue: '',
);

// En UI:
final status = watchValue((MyService s) => s.command.statusMessage);
Column(
  children: [
    CircularProgressIndicator(),  // Indeterminado (sin valor)
    Text(status ?? ''),
  ],
)
```

## Ver También

- [Fundamentos de Command](command_basics.md) - Todos los métodos factory de command
- [Propiedades del Command](command_properties.md) - Otras propiedades observables
- [Testing](testing.md) - Testing de commands con MockCommand
- [Command Builders](command_builders.md) - Patrones de integración de UI
