# Code Samples

This directory contains testable code samples used in the flutter_it documentation site.

## Purpose

All code samples in the documentation are extracted from these Dart files to ensure they:
- Compile correctly
- Follow best practices
- Stay up-to-date with API changes

## Structure

```
code_samples/
├── lib/
│   ├── get_it/          # get_it examples
│   ├── watch_it/        # watch_it examples
│   ├── command_it/      # command_it examples
│   └── listen_it/       # listen_it examples
├── test/                # Tests that verify samples compile
└── pubspec.yaml         # Dependencies
```

## Usage

### Running Tests

```bash
cd docs/code_samples
flutter test
```

### Analyzing Code

```bash
cd docs/code_samples
flutter analyze
```

## Referencing in Documentation

Use VitePress code import syntax to include samples in markdown:

```md
<!-- Import entire file -->
<<< @/../../code_samples/lib/get_it/basic_usage.dart

<!-- Import specific lines -->
<<< @/../../code_samples/lib/get_it/basic_usage.dart{10-20}

<!-- Import with region markers -->
<<< @/../../code_samples/lib/get_it/basic_usage.dart#setup
```

## Adding New Samples

1. Create a new `.dart` file in the appropriate `lib/` subdirectory
2. Write compilable code with proper imports
3. Add tests in `test/` directory if needed
4. Reference the file in documentation markdown
5. Run `flutter test` to verify it compiles
