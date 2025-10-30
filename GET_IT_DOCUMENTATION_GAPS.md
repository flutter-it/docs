# get_it Documentation Gaps & Enhancement Plan

**Date**: 2025-10-29
**Status**: Planning
**Purpose**: Track undocumented API features and documentation improvements needed

## Overview

Analysis of `/home/escamoteur/dev/flutter_it/get_it/lib/get_it.dart` revealed 11 significant features that are either missing from documentation or need better coverage.

---

## 1. Cached Factories ⭐ CRITICAL - COMPLETELY UNDOCUMENTED

**Priority**: HIGH - This is a new feature with zero documentation

### Missing Methods:
- `registerCachedFactory<T>()` - Factory with weak reference caching
- `registerCachedFactoryParam<T, P1, P2>()` - Parameterized cached factory
- `registerCachedFactoryAsync<T>()` - Async cached factory
- `registerCachedFactoryParamAsync<T, P1, P2>()` - Async parameterized cached factory

### What it does:
- Holds a weak reference to the last created instance
- Returns cached instance if not garbage collected yet
- For param versions: checks if parameters haven't changed before reusing

### Where to document:
- **Primary**: `object_registration.md` - Add new "Cached Factories" section after "Factory" section
- **Secondary**: Brief mention in getting_started.md under "Different ways of registration"

### Content needed:
```markdown
## Cached Factories

Cached factories are a performance optimization that sits between regular factories and singletons.

- Creates new instance on first call (like factory)
- Caches instance with weak reference
- Returns cached instance if still in memory (like singleton)
- Creates new instance if garbage collected (like factory)

Use cases:
- Heavy objects that are frequently recreated
- Objects with expensive initialization but short-medium lifecycle
- Memory-sensitive scenarios where you want automatic cleanup

Examples needed:
- Basic cached factory
- Cached factory with parameters
- Performance comparison vs factory vs singleton
```

---

## 2. Reference Counting - UNDOCUMENTED

**Priority**: MEDIUM-HIGH - Important for complex lifecycle management

### Missing Methods:
- `registerSingletonIfAbsent<T>()` - Register singleton with reference counting
- `releaseInstance(Object instance)` - Decrement reference counter

### What it does:
- Tracks how many "users" need a singleton
- Prevents disposal until all users release it
- Perfect for recursive page navigation scenarios

### Where to document:
- **Primary**: `advanced.md` - Add new "Reference Counting" section
- **Secondary**: Mention in scopes.md when discussing lifecycle management

### Content needed:
```markdown
## Reference Counting

Reference counting helps manage singleton lifecycle when multiple consumers might need the same instance.

Problem scenario:
- Page A registers a service when pushed
- Page A can be pushed recursively (A → A → A)
- Don't want to dispose service when first instance pops

Solution:
- registerSingletonIfAbsent increments counter if already registered
- releaseInstance decrements counter
- Only unregisters/disposes when counter reaches 0

Examples needed:
- Recursive navigation scenario
- Nested scope with shared services
- Testing reference counter behavior
```

---

## 3. Utility Methods - UNDOCUMENTED

**Priority**: MEDIUM - Helpful for production code

### Missing Methods:
- `maybeGet<T>()` - Like get() but returns null instead of throwing
- `changeTypeInstanceName()` - Rename registered instance without unregister/reregister
- `checkLazySingletonInstanceExists()` - Check if lazy singleton has been instantiated
- `findFirstObjectRegistration<T>()` - Get registration metadata

### What they do:
- **maybeGet**: Safe retrieval without exceptions
- **changeTypeInstanceName**: Avoid disposal issues when renaming
- **checkLazySingletonInstanceExists**: Introspection for lazy singletons
- **findFirstObjectRegistration**: Advanced introspection

### Where to document:
- **Primary**: `advanced.md` - Add new "Utility Methods" section
- **Secondary**: maybeGet could be mentioned in getting_started.md

### Content needed:
```markdown
## Utility Methods

### Safe Retrieval: maybeGet()

Returns null instead of throwing if type not registered.

Use when:
- Optional dependencies
- Feature flags
- Graceful degradation

### Instance Management: changeTypeInstanceName()

Rename a registered instance without unregister/reregister cycle.

Use when:
- Dynamic naming schemes
- Avoiding disposal side effects
- Complex scope hierarchies

### Introspection: checkLazySingletonInstanceExists()

Check if a lazy singleton has been created yet.

Use when:
- Performance monitoring
- Conditional initialization
- Testing lazy loading behavior

### Advanced Introspection: findFirstObjectRegistration()

Get metadata about a registration.

Use when:
- Debugging
- Building tools on top of GetIt
- Advanced lifecycle management
```

---

## 4. Scope Enhancements - PARTIALLY DOCUMENTED

**Priority**: HIGH - Scopes are complex and need special care

### Missing/Underdocumented:
- `pushNewScopeAsync()` - Async version of pushNewScope
- `currentScopeName` getter - Get name of current scope
- `fromAllScopes` parameter in `getAll()`/`getAllAsync()` - Search across all scopes

### What they do:
- **pushNewScopeAsync**: Allow async initialization when pushing scope
- **currentScopeName**: Know which scope you're in (debugging, conditional logic)
- **fromAllScopes**: Get all instances across scope hierarchy

### Where to document:
- **Primary**: `scopes.md` - Enhance existing content
- **Add sections**:
  - "Async Scope Initialization"
  - "Scope Introspection"
  - "Cross-Scope Queries"

### Content needed:
```markdown
## Async Scope Initialization

pushNewScopeAsync() allows async work during scope setup:

Example:
- Loading user preferences from database
- Fetching configuration from API
- Initializing async services

## Scope Introspection

currentScopeName property tells you which scope is active.

Use cases:
- Conditional logic based on scope
- Debugging scope issues
- Logging scope transitions

## Cross-Scope Queries

getAll(fromAllScopes: true) retrieves instances from entire scope hierarchy.

Use cases:
- Plugin systems
- Modular architectures
- Aggregating services across scopes
```

---

## 5. Lazy Singleton Weak References - UNDOCUMENTED

**Priority**: LOW-MEDIUM - Advanced feature

### Missing:
- `useWeakReference` parameter in `registerLazySingleton()` and `registerLazySingletonAsync()`

### What it does:
- Hold lazy singleton with weak reference
- Allow garbage collection if no other references exist
- Recreate on next access if collected

### Where to document:
- **Primary**: `object_registration.md` - Add to LazySingleton section
- **Note**: Explain trade-offs vs normal lazy singleton

---

## 6. Advanced Unregister Options - UNDOCUMENTED

**Priority**: LOW - Edge case handling

### Missing:
- `ignoreReferenceCount` parameter in `unregister()`

### What it does:
- Force unregister even if reference count > 0
- Dangerous but necessary in some cleanup scenarios

### Where to document:
- **Primary**: `advanced.md` - In Reference Counting section
- **Warning**: Explain when this is needed and risks

---

## Documentation Structure Enhancement Plan

### Phase 1: Critical Gaps (Days 1-2)
1. ✅ Add "Cached Factories" to object_registration.md
2. ✅ Add "Reference Counting" to advanced.md
3. ✅ Enhance scopes.md with async/introspection/cross-scope

### Phase 2: Utility & Polish (Days 3-4)
4. ✅ Add "Utility Methods" to advanced.md
5. ✅ Add weak reference option to object_registration.md
6. ✅ Expand FAQ with common questions
7. ✅ Expand testing.md with practical examples

### Phase 3: Beginner Experience (Day 5)
8. ✅ Polish getting_started.md
9. ✅ Add cross-references between all docs
10. ✅ Verify all code examples work

---

## FAQ Topics to Add

Based on API features and common patterns:

1. **"What's the difference between Factory, Cached Factory, and Lazy Singleton?"**
   - Performance characteristics
   - Memory implications
   - When to use each

2. **"Should I use Scopes or just reset GetIt between tests?"**
   - Scope advantages
   - Testing patterns
   - Isolation strategies

3. **"How do I handle optional dependencies?"**
   - maybeGet() usage
   - Graceful degradation patterns
   - Feature flags

4. **"When should I use reference counting?"**
   - Recursive navigation
   - Shared resources
   - Complex lifecycles

5. **"How do I debug GetIt issues?"**
   - isRegistered checks
   - currentScopeName
   - findFirstObjectRegistration
   - Common error messages

6. **"What's the performance of GetIt?"**
   - O(1) lookup explanation
   - Cached factory trade-offs
   - Weak reference implications

7. **"Can I use GetIt in packages/libraries?"**
   - Singleton instance sharing
   - asNewInstance() usage
   - Best practices for libraries

8. **"How do I handle async initialization properly?"**
   - allReady patterns
   - dependsOn usage
   - Common pitfalls

---

## Testing Documentation Needs

Expand testing.md with:

1. **Setup and Teardown Patterns**
   - Using scopes in tests
   - reset() vs resetScope()
   - allowReassignment for test doubles

2. **Mocking Strategies**
   - Interface-based mocking
   - Constructor injection pattern
   - Test-specific registrations

3. **Integration Test Patterns**
   - Conditional registration (testing flag)
   - Partial mocking
   - Real vs mock services

4. **Common Testing Pitfalls**
   - Forgetting to reset
   - Shared state between tests
   - Async initialization in tests

5. **Reference Testing**
   - Testing reference counting
   - Testing lazy singleton creation
   - Testing scope lifecycle

---

## Code Examples Needed

Each undocumented feature needs:
- ✅ Basic usage example
- ✅ Real-world scenario
- ✅ Common pitfalls to avoid
- ✅ When to use vs alternatives

Prioritize examples for:
1. Cached factories (completely new)
2. Reference counting (complex concept)
3. Scope async initialization (common need)
4. maybeGet (simple but useful)

---

## Cross-Reference Improvements

Ensure these links exist:
- getting_started.md → object_registration.md (for all registration types)
- object_registration.md → scopes.md (for lifecycle management)
- scopes.md → testing.md (for test isolation)
- testing.md → advanced.md (for advanced patterns)
- FAQ → All relevant sections

---

## Verification Checklist

Before considering documentation complete:

- [ ] Every public method in get_it.dart is documented somewhere
- [ ] Every code example compiles and runs
- [ ] Cross-references are accurate and helpful
- [ ] Beginner path is clear (getting_started → common patterns)
- [ ] Advanced features are clearly marked as such
- [ ] FAQ covers most Stack Overflow questions
- [ ] Testing guidance covers common scenarios
- [ ] Performance characteristics are explained

---

## Notes

- **Cached factories** are the biggest gap - completely new feature with zero docs
- **Scopes** need special care per user request - add async, introspection, cross-scope queries
- **Reference counting** is powerful but complex - needs clear examples
- Many utility methods exist but are undiscovered - discoverability issue

---

**Next Steps**: Begin with Phase 1, starting with scopes.md enhancement (user priority)
