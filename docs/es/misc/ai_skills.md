---
title: Skills de IA para Asistentes de Código
---

# Skills de IA para Asistentes de Código

Cada paquete de flutter_it incluye **archivos de skills de IA** que ayudan a los asistentes de código con IA a generar código correcto e idiomático usando los paquetes.

## ¿Qué son los Archivos de Skills de IA?

Los archivos de skills de IA son archivos de conocimiento estructurado que enseñan a los asistentes de código con IA (como Claude Code, Cursor, GitHub Copilot y otros) cómo usar correctamente una librería. Contienen:

- **Reglas críticas** que deben seguirse (ej. el requisito de orden de watch_it)
- **Patrones comunes** con ejemplos de código completos
- **Anti-patrones** con alternativas correctas
- **Patrones de integración** entre paquetes
- **Guía de arquitectura** para estructurar apps Flutter

Los archivos de skills siguen el estándar abierto [Agent Skills](https://agentskills.io) — un formato basado en directorios con un archivo `SKILL.md` y frontmatter YAML que funciona con diferentes herramientas de IA — y se distribuyen como recomienda Dart para los [package skills](https://dart.dev/tools/pub/package-skills): en un directorio `skills/` en la raíz de cada paquete.

## Instalar con el CLI `skills` de Dart (Recomendado)

Añade los paquetes que uses a tu `pubspec.yaml` y luego ejecuta en el directorio de tu proyecto:

```bash
dart run skills@ get
```

Esto revisa tus dependencias **directas** en busca de skills incluidos y los instala en tu proyecto (por ejemplo en `.claude/skills/`, `.agents/skills/` o lo que lea tu herramienta de IA — el CLI te pregunta la primera vez). Vuelve a ejecutarlo después de actualizar un paquete para obtener la última versión de los skills.

::: tip Solo dependencias directas
El CLI `skills` solo mira los paquetes listados directamente en tu `pubspec.yaml`. Si dependes de `watch_it` y también quieres el skill de `get_it`, añade `get_it` como dependencia directa (la necesitarás de todos modos para `di.registerX(...)`). O depende de `flutter_it`, que incluye los siete skills.
:::

También puedes instalarlos directamente desde el repositorio, independientemente de tus dependencias:

```bash
dart run skills@ add flutter-it/flutter_it
```

## ¿Qué Skills Incluye Cada Paquete?

| Paquete | Skills Incluidos |
|---------|-----------------|
| **get_it** | `get-it-expert` |
| **watch_it** | `watch-it-expert` |
| **command_it** | `command-it-expert` |
| **listen_it** | `listen-it-expert` |
| **flutter_it** | Los 7 skills como `flutter-it-overview`, `flutter-it-architecture`, `flutter-it-feed-datasource`, `flutter-it-get-it`, `flutter-it-watch-it`, `flutter-it-command-it`, `flutter-it-listen-it` |

Cada paquete incluye solo su propio skill (el CLI `skills` de Dart exige que los nombres de los skills lleven el nombre del paquete como prefijo). El paquete de conveniencia `flutter_it` los incluye todos, así que depender de él te da el conjunto completo — incluidos los skills de arquitectura y feeds que no pertenecen a un solo paquete.

## Los 7 Skills

| Skill | Descripción |
|-------|-------------|
| `get-it-expert` | Registro del service locator, scopes, inicialización async, cached factories, testing |
| `watch-it-expert` | Widgets reactivos, funciones watch, handlers, ciclo de vida, reglas de orden, parámetros de cached factories |
| `command-it-expert` | Patrón command, operaciones async, manejo de errores, restricciones |
| `listen-it-expert` | Operadores de ValueListenable, ciclo de vida de cadenas, colecciones reactivas, transacciones |
| `flutter-architecture-expert` | Arquitectura Flutter Pragmática (PFA) con Services/Managers/Views |
| `feed-datasource-expert` | Feeds paginados, scroll infinito, ciclo de vida de proxies, conteo de referencias |
| `flutter-it` | Descripción general del kit flutter_it, selección de paquetes, dependencias |

## Instalación Manual

Si no quieres usar el CLI:

**[Descargar los 7 skills (zip)](/downloads/flutter_it_ai_skills.zip)**

O clona desde el [repositorio flutter_it](https://github.com/flutter-it/flutter_it/tree/main/skills) que contiene todos los skills.

### Claude Code

Extrae el zip en tu directorio global de skills para tenerlos disponibles en todos tus proyectos:

```
~/.claude/skills/
├── get-it-expert/SKILL.md
├── watch-it-expert/SKILL.md
├── command-it-expert/SKILL.md
├── listen-it-expert/SKILL.md
├── flutter-architecture-expert/SKILL.md
├── feed-datasource-expert/SKILL.md
└── flutter-it/SKILL.md
```

O en `.claude/skills/` dentro de un proyecto para usarlos solo ahí — que es también donde los deja `dart run skills@ get`.

### Cursor

Copia el contenido de los archivos `SKILL.md` relevantes en tu archivo `.cursorrules` en la raíz del proyecto. Elige los skills que correspondan a los paquetes que uses.

### GitHub Copilot

Copia el contenido de los archivos `SKILL.md` relevantes en `.github/copilot-instructions.md` en tu repositorio.

### Otras Herramientas de IA

Los archivos de skills son Markdown plano con frontmatter YAML. Copia su contenido en el mecanismo de contexto que soporte tu herramienta de IA.

## Archivos de Skills en GitHub

Puedes explorar los archivos de skills directamente en cada repositorio:

- [Skills de get_it](https://github.com/flutter-it/get_it/tree/master/skills)
- [Skills de watch_it](https://github.com/flutter-it/watch_it/tree/main/skills)
- [Skills de command_it](https://github.com/flutter-it/command_it/tree/main/skills)
- [Skills de listen_it](https://github.com/flutter-it/listen_it/tree/main/skills)
- [Skills de flutter_it](https://github.com/flutter-it/flutter_it/tree/main/skills) (los 7 skills)

## Por Qué Esto Importa

Los asistentes de código con IA son potentes, pero pueden generar patrones incorrectos sin el contexto adecuado. Por ejemplo:

- Usar `isRunningSync` para actualizaciones de UI en lugar de `isRunning` (command_it)
- Envolver llamadas watch en condicionales, rompiendo la regla de orden (watch_it)
- Usar `copyWith` en DTOs en lugar de campos override en proxies (arquitectura)
- Crear cadenas de operadores en cada `build()` en lugar de una sola vez (listen_it)

Los archivos de skills previenen estos errores enseñando a la herramienta de IA los patrones correctos desde el inicio.
