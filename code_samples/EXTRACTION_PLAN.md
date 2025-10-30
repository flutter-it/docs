# Code Sample Extraction Plan

## Summary
- **Total code blocks**: 278 across 17 markdown files
- **Status**: 1 extracted (async_factory_basic.dart), 277 remaining

## File Distribution
- `documentation/get_it/`: 188 blocks across 9 files
- `documentation/watch_it/`: 26 blocks in 1 file
- `documentation/command_it/`: 21 blocks in 1 file
- `documentation/listen_it/`: 11 blocks in 1 file
- `examples/`: 31 blocks across 5 files
- `index.md`: 1 block

## Extraction Strategy

### File Naming Convention
`lib/{package}/{topic}_{description}.dart`

Examples:
- `lib/get_it/async_factory_basic.dart` ✅ (done)
- `lib/get_it/async_singleton_with_deps.dart`
- `lib/get_it/scope_basic.dart`
- `lib/watch_it/watch_value_example.dart`

### Types of Code Blocks

1. **Method Signatures** - Don't extract, keep inline
   ```dart
   void registerFactoryAsync<T>(...)
   ```

2. **Usage Examples** - Extract to separate files
   ```dart
   void configureDependencies() { ... }
   ```

3. **Short Snippets** (< 5 lines) - Keep inline unless part of larger example

4. **Complete Examples** - Always extract

## Extraction Priority

### Phase 1: get_it async_objects.md (Current)
- 39 blocks total
- ~10-15 need extraction (excluding method signatures)
- Focus: Complete, compilable examples

### Phase 2: Other get_it docs
- getting_started.md (9 blocks)
- object_registration.md (23 blocks)
- scopes.md (21 blocks)

### Phase 3: Other packages
- watch_it, command_it, listen_it

## Process

1. **Extract** - Copy code exactly as-is from markdown to `.dart` file
2. **Reference** - Replace markdown code block with `<<< ../../../code_samples/lib/...`
3. **Verify** - Check docs display correctly
4. **Compile** - Fix compilation issues while ensuring docs still match
5. **Test** - Add tests that use the sample code

## Current Working Example

**File**: `async_objects.md` line 68-90
**Extracted to**: `lib/get_it/async_factory_basic.dart`
**Reference**:
```markdown
**Example:**

<<< ../../../code_samples/lib/get_it/async_factory_basic.dart
```

**Result**: ✅ Displays correctly in docs
