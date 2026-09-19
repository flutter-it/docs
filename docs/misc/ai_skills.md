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

The skill files follow the [Agent Skills](https://agentskills.io) open standard — a directory-based format with a `SKILL.md` file and YAML frontmatter that works across different AI tools — and are distributed the way Dart recommends for [package skills](https://dart.dev/tools/pub/package-skills): in a top-level `skills/` directory of each package.

## Install with the Dart `skills` CLI (Recommended)

Add the packages you use to your `pubspec.yaml`, then run in your project directory:

```bash
dart run skills@ get
```

This scans your **direct** dependencies for bundled skills and installs them into your project (for example into `.claude/skills/`, `.agents/skills/` or whatever your AI tool reads — the CLI asks you on first run). Re-run it after upgrading a package to pick up the latest version of the skills.

::: tip Direct dependencies only
The `skills` CLI only looks at packages listed directly in your `pubspec.yaml`. If you depend on `watch_it` and want the `get_it` skill too, add `get_it` as a direct dependency (you'll need it anyway for `di.registerX(...)`). Or depend on `flutter_it`, which bundles all seven skills.
:::

You can also install straight from the repository, independent of your dependencies:

```bash
dart run skills@ add flutter-it/flutter_it
```

## Which Skills Ship with Which Package?

| Package | Skills Included |
|---------|----------------|
| **get_it** | `get-it-expert` |
| **watch_it** | `watch-it-expert` |
| **command_it** | `command-it-expert` |
| **listen_it** | `listen-it-expert` |
| **flutter_it** | All 7 skills as `flutter-it-overview`, `flutter-it-architecture`, `flutter-it-feed-datasource`, `flutter-it-get-it`, `flutter-it-watch-it`, `flutter-it-command-it`, `flutter-it-listen-it` |

Each package ships only its own skill (the Dart `skills` CLI requires skill names to be prefixed with the package name). The `flutter_it` convenience package ships all of them, so depending on it gets you the complete set — including the architecture and feed skills that don't belong to a single package.

## All 7 Skills

| Skill | Description |
|-------|-------------|
| `get-it-expert` | Service locator registration, scopes, async initialization, cached factories, testing |
| `watch-it-expert` | Reactive widgets, watch functions, handlers, lifecycle, ordering rules, cached factory params |
| `command-it-expert` | Command pattern, async operations, error handling, restrictions |
| `listen-it-expert` | ValueListenable operators, chain lifecycle, reactive collections, transactions |
| `flutter-architecture-expert` | Pragmatic Flutter Architecture (PFA) with Services/Managers/Views |
| `feed-datasource-expert` | Paginated feeds, infinite scroll, proxy lifecycle, reference counting |
| `flutter-it` | Overview of the flutter_it construction set, package selection, dependencies |

## Manual Installation

If you don't want to use the CLI:

**[Download all 7 skills (zip)](/downloads/flutter_it_ai_skills.zip)**

Or clone from the [flutter_it repository](https://github.com/flutter-it/flutter_it/tree/main/skills) which contains all skills.

### Claude Code

Extract the zip into your global skills directory to have them available in every project:

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

Or into `.claude/skills/` inside a project for that project only — that's also where `dart run skills@ get` puts them.

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
- Creating operator chains on every `build()` instead of once (listen_it)

The skill files prevent these mistakes by teaching the AI tool the correct patterns upfront.
