---
title: Bienvenido a flutter_it
---

<div class="header-with-logo">
  <div class="header-content">

# Crea apps Flutter reactivas de forma sencilla

**Sin generación de código, sin código repetitivo, solo código.**

flutter_it es un **kit modular de herramientas** reactivas para Flutter. Elige lo que necesites, combínalas a medida que creces, o úsalas todas juntas. Cada paquete funciona de forma independiente y se integra perfectamente con los demás.

<div class="consulting-cta">
  <a class="consulting-cta-primary" href="https://calendly.com/burkhartsengineering/30min" target="_blank" rel="noopener">📅 Agenda una llamada</a>
  <a class="consulting-cta-secondary" href="mailto:apps@burkharts.net">✉️ Escríbeme</a>
</div>

  </div>
  <img src="/images/main-logo.svg" alt="flutter_it" width="225" class="header-logo" />
</div>

::: tip 🤖 Desarrollo Asistido por IA
Cada paquete de flutter_it incluye **archivos de skills de IA** que ayudan a Claude Code, Cursor, GitHub Copilot y otras herramientas de IA a generar código correcto. [Más información →](/es/misc/ai_skills)
:::

## ¿Por qué flutter_it?

<ul style="list-style: none; padding-left: 0;">
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Cero build_runner</strong> - Sin generación de código, sin esperar compilaciones</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Dart puro</strong> - Funciona con Flutter estándar, sin magia</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Modular por diseño</strong> - Usa un paquete o combina varios—tú decides</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Basado en ChangeNotifier y ValueNotifier</strong> - Integración perfecta con Flutter usando primitivas familiares</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Tipado seguro</strong> - Verificación de tipos completa en tiempo de compilación</li>
  <li style="padding-left: 1.5em; text-indent: -1.5em;">✅ <strong>Probado extensivamente</strong> - Confiado por miles de desarrolladores Flutter</li>
</ul>

## Míralo en acción

```dart
// 1. Registra servicios en cualquier parte de tu app (get_it)
final getIt = GetIt.instance;
getIt.registerSingleton(CounterModel());

// 2. Observa y reacciona a cambios automáticamente (watch_it)
class CounterWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final count = watchValue((CounterModel m) => m.count);
    return Text('Cuenta: $count'); // Tu widget se reconstruye automáticamente con cada cambio
  }
}

// 3. Usa colecciones reactivas (listen_it)
final items = ListNotifier<String>();
items.add('Nuevo item'); // Notifica automáticamente a los listeners

// 4. Encapsula acciones con comandos (command_it)
final saveCommand = Command.createAsyncNoResult<UserData>(
  (userData) async => await api.save(userData),
);
// Accede al estado de carga, errores - todo incluido
```

Sin setState(), sin código repetitivo de Provider, sin generación de código. Solo Flutter reactivo.

## El Kit de Herramientas

> 💡 **Cada paquete funciona de forma independiente** - comienza con uno, añade otros según los necesites.

### <img src="/images/get_it.svg" alt="get_it" width="50" style="vertical-align: middle; margin-right: 0.5rem; display: inline-block;" />get_it

**Dependency injection sin el framework**

Service Locator simple que funciona en cualquier parte de tu app—sin BuildContext, sin árboles de InheritedWidget, solo acceso limpio a dependencias.

[Comienza →](/es/documentation/get_it/getting_started) | [Ejemplos →](/examples/get_it/get_it)

---

### <img src="/images/watch_it.svg" alt="watch_it" width="50" style="vertical-align: middle; margin-right: 0.5rem; display: inline-block;" />`watch_it`

**Actualizaciones de UI reactivas, automáticamente**

Reacciona a cambios de estado sin setState()—observa valores y reconstruye solo lo necesario. Casi nunca necesitarás un StatefulWidget otra vez. Depende de get_it para la localización de servicios.

[Comienza →](/documentation/watch_it/getting_started) | [Ejemplos →](/examples/watch_it/watch_it)

---

### <img src="/images/command_it.svg" alt="command_it" width="67" style="vertical-align: middle; margin-right: 0.5rem; display: inline-block;" />command_it

**Encapsula acciones con estado incluido**

Comandos que rastrean la ejecución, manejan errores y proporcionan estados de carga automáticamente. Maneja excepciones de forma inteligente. Perfecto para operaciones asíncronas.

[Comienza →](/documentation/command_it/getting_started) | [Ejemplos →](/examples/command_it/command_it)

---

### <img src="/images/listen_it.svg" alt="listen_it" width="50" style="vertical-align: middle; margin-right: 0.5rem; display: inline-block;" />listen_it

**Combina estado reactivo al estilo RxDart pero fácil de entender**

Operadores de transformación, filtrado, combinación y debounce para ValueNotifier—además de colecciones reactivas (ListNotifier, MapNotifier, SetNotifier) que notifican automáticamente los cambios.

[Comienza →](/documentation/listen_it/listen_it) | [Ejemplos →](/examples/listen_it/listen_it)

---

## Primeros Pasos

**¿Nuevo en flutter_it?** Empieza aquí:

1. **[Qué hacer con cada paquete](/es/getting_started/what_to_do_with_which_package)** - Encuentra la herramienta correcta para tus necesidades
2. **[Documentación Completa](/documentation/overview)** - Profundiza en cada paquete
3. **[Ejemplos del Mundo Real](/examples/overview)** - Mira patrones en acción

## Comunidad

Únete a la comunidad flutter_it:

- **[GitHub](https://github.com/flutter-it)** - Código fuente e issues
- **[Discord](https://discord.com/invite/Nn6GkYjzW)** - Chat y soporte
- **[Twitter](https://x.com/ThomasBurkhartB)** - Actualizaciones y noticias
