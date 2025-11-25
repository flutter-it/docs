// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'riverpod_integration.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todoManagerHash() => r'b7cca67a5b93ae1a212397d68b8f6a3a252f6991';

/// Manager provider with cleanup
///
/// Copied from [todoManager].
@ProviderFor(todoManager)
final todoManagerProvider = AutoDisposeProvider<TodoManager>.internal(
  todoManager,
  name: r'todoManagerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$todoManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodoManagerRef = AutoDisposeProviderRef<TodoManager>;
String _$isLoadingHash() => r'f79c2064e2e8cf50812cfc42b78115cc09df7128';

/// Granular provider for isRunning - only rebuilds when loading state changes
///
/// Copied from [isLoading].
@ProviderFor(isLoading)
final isLoadingProvider =
    AutoDisposeProvider<Raw<ValueListenable<bool>>>.internal(
  isLoading,
  name: r'isLoadingProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsLoadingRef = AutoDisposeProviderRef<Raw<ValueListenable<bool>>>;
String _$loadResultsHash() => r'a620c7c19c9c756905ef852dda14ed46949c822f';

/// Granular provider for results - only rebuilds when results change
///
/// Copied from [loadResults].
@ProviderFor(loadResults)
final loadResultsProvider = AutoDisposeProvider<
    Raw<ValueListenable<CommandResult<void, List<Todo>>>>>.internal(
  loadResults,
  name: r'loadResultsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$loadResultsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LoadResultsRef = AutoDisposeProviderRef<
    Raw<ValueListenable<CommandResult<void, List<Todo>>>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
