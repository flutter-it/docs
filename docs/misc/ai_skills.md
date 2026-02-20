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

## How to Use with Your AI Tool

### Claude Code

Skills are **auto-detected** from the `skills/` directory when you open a project containing a flutter_it package. No extra setup needed.

You can also copy the skills to your global `~/.claude/skills/` directory so they are available across all projects:

```bash
cp -r <package>/skills/* ~/.claude/skills/
```

### Cursor

Copy the relevant `SKILL.md` content into your `.cursorrules` file at the project root:

```bash
cat <package>/skills/get-it-expert/SKILL.md >> .cursorrules
```

Or reference the skill files in your Cursor settings.

### GitHub Copilot

Copy the skill content to `.github/copilot-instructions.md`:

```bash
cat <package>/skills/get-it-expert/SKILL.md >> .github/copilot-instructions.md
```

### Other AI Tools

Reference the `SKILL.md` files directly from the `skills/` directory of each package. The files are plain Markdown with YAML frontmatter and work with any tool that accepts context files.

## Skill Files on GitHub

You can browse the skill files directly in each package repository:

- [get_it skills](https://github.com/flutter-it/get_it/tree/master/skills)
- [watch_it skills](https://github.com/flutter-it/watch_it/tree/main/skills)
- [command_it skills](https://github.com/flutter-it/command_it/tree/main/skills)
- [listen_it skills](https://github.com/flutter-it/listen_it/tree/main/skills)

## Why This Matters

AI coding assistants are powerful, but they can generate incorrect patterns without proper context. For example:

- Using `isRunningSync` for UI updates instead of `isRunning` (command_it)
- Wrapping watch calls in conditionals, breaking the ordering rule (watch_it)
- Using `copyWith` on DTOs instead of proxy override fields (architecture)
- Creating operator chains inline in `build()` without caching (listen_it)

The skill files prevent these mistakes by teaching the AI tool the correct patterns upfront.
