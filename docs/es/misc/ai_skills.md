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

Los archivos de skills siguen el estándar abierto [Agent Skills](https://github.com/agentskills) — un formato basado en directorios con un archivo `SKILL.md` y frontmatter YAML que funciona con diferentes herramientas de IA.

## ¿Qué Skills Incluye Cada Paquete?

| Paquete | Skills Incluidos |
|---------|-----------------|
| **get_it** | `get-it-expert`, `flutter-architecture-expert` |
| **watch_it** | `watch-it-expert`, `get-it-expert`, `flutter-architecture-expert`, `feed-datasource-expert` |
| **command_it** | `command-it-expert`, `listen-it-expert`, `flutter-architecture-expert`, `feed-datasource-expert` |
| **listen_it** | `listen-it-expert`, `flutter-architecture-expert` |
| **flutter_it** | Los 7 skills (paquete de conveniencia) |

Cada paquete incluye los skills más relevantes para su uso, así obtienes el contexto correcto sin importar con qué paquete comiences.

## Los 7 Skills

| Skill | Descripción |
|-------|-------------|
| `get-it-expert` | Registro del service locator, scopes, inicialización async, testing |
| `watch-it-expert` | Widgets reactivos, funciones watch, handlers, ciclo de vida, reglas de orden |
| `command-it-expert` | Patrón command, operaciones async, manejo de errores, restricciones |
| `listen-it-expert` | Operadores de ValueListenable, colecciones reactivas, encadenamiento, transacciones |
| `flutter-architecture-expert` | Arquitectura Flutter Pragmática (PFA) con Services/Managers/Views |
| `feed-datasource-expert` | Feeds paginados, scroll infinito, ciclo de vida de proxies, conteo de referencias |
| `flutter-it` | Descripción general del kit flutter_it, selección de paquetes, dependencias |

## Descargar

**[Descargar los 7 skills (zip)](/downloads/flutter_it_ai_skills.zip)**

O clona desde el [repositorio flutter_it](https://github.com/flutter-it/flutter_it/tree/main/skills) que contiene todos los skills.

## Cómo Usar con tu Herramienta de IA

### Claude Code

Extrae el zip (o copia desde el repo) en tu directorio global de skills:

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

Claude Code detectará automáticamente los skills de `~/.claude/skills/` en todos tus proyectos.

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
- Crear cadenas de operadores inline en `build()` sin caché (listen_it)

Los archivos de skills previenen estos errores enseñando a la herramienta de IA los patrones correctos desde el inicio.
