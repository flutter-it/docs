---
title: AI Skills for Coding Assistants
---

# AI Skills for Coding Assistants

Every flutter_it package ships with **AI skill files** that help AI coding assistants generate correct, idiomatic code using the packages.

## What are AI Skill Files?

AI skill files are structured knowledge files that teach AI coding assistants (like Claude Code, Cursor, GitHub Copilot, and others) how to properly use a library. They contain:

- **Critical rules** that must be followed (e.g., watch_it's ordering requirement)
- **Common patterns** with complete code examples
- **Anti-patterns** with correct alternatives
- **Integration patterns** between packages
- **Architecture guidance** for structuring Flutter apps

The skill files follow the [Agent Skills](https://github.com/agentskills) open standard — a directory-based format with a `SKILL.md` file and YAML frontmatter that works across different AI tools.

## Which Skills Ship with Which Package?

| Package | Skills Included |
|---------|----------------|
| **get_it** | `get-it-expert`, `flutter-architecture-expert` |
| **watch_it** | `watch-it-expert`, `get-it-expert`, `flutter-architecture-expert`, `feed-datasource-expert` |
| **command_it** | `command-it-expert`, `listen-it-expert`, `flutter-architecture-expert`, `feed-datasource-expert` |
| **listen_it** | `listen-it-expert`, `flutter-architecture-expert` |
| **flutter_it** | All 7 skills (convenience package) |

Each package includes the skills most relevant to its usage, so you get the right context regardless of which package you start with.

## All 7 Skills

| Skill | Description |
|-------|-------------|
| `get-it-expert` | Service locator registration, scopes, async initialization, testing |
| `watch-it-expert` | Reactive widgets, watch functions, handlers, lifecycle, ordering rules |
| `command-it-expert` | Command pattern, async operations, error handling, restrictions |
| `listen-it-expert` | ValueListenable operators, reactive collections, chaining, transactions |
| `flutter-architecture-expert` | Pragmatic Flutter Architecture (PFA) with Services/Managers/Views |
| `feed-datasource-expert` | Paginated feeds, infinite scroll, proxy lifecycle, reference counting |
| `flutter-it` | Overview of the flutter_it construction set, package selection, dependencies |

## Download

**[Download all 7 skills (zip)](/downloads/flutter_it_ai_skills.zip)**

Or clone from the [flutter_it repository](https://github.com/flutter-it/flutter_it/tree/main/skills) which contains all skills.

## How to Use with Your AI Tool

### Claude Code

Extract the zip (or copy from the repo) into your global skills directory:

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

Claude Code will automatically pick up skills from `~/.claude/skills/` across all your projects.

### Cursor

Copy the content of the relevant `SKILL.md` files into your `.cursorrules` file at the project root. Pick the skills that match the packages you use.

### GitHub Copilot

Copy the content of the relevant `SKILL.md` files into `.github/copilot-instructions.md` in your repository.

### Other AI Tools

The skill files are plain Markdown with YAML frontmatter. Copy their content into whatever context mechanism your AI tool supports.

## Skill Files on GitHub

You can browse the skill files directly in each package repository:

- [get_it skills](https://github.com/flutter-it/get_it/tree/master/skills)
- [watch_it skills](https://github.com/flutter-it/watch_it/tree/main/skills)
- [command_it skills](https://github.com/flutter-it/command_it/tree/main/skills)
- [listen_it skills](https://github.com/flutter-it/listen_it/tree/main/skills)
- [flutter_it skills](https://github.com/flutter-it/flutter_it/tree/main/skills) (all 7 skills)

## Why This Matters

AI coding assistants are powerful, but they can generate incorrect patterns without proper context. For example:

- Using `isRunningSync` for UI updates instead of `isRunning` (command_it)
- Wrapping watch calls in conditionals, breaking the ordering rule (watch_it)
- Using `copyWith` on DTOs instead of proxy override fields (architecture)
- Creating operator chains inline in `build()` without caching (listen_it)

The skill files prevent these mistakes by teaching the AI tool the correct patterns upfront.
