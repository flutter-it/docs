# Command Types

::: warning AI-Generated Content Under Review
This documentation was generated with AI assistance and is currently under review. While we strive for accuracy, there may be errors or inconsistencies. Please report any issues you find.
:::

## How to create Commands
´Command´ offers different static factory functions for the different function types you want to wrap:

```dart
  /// for syncronous functions with no parameter and no result
  static Command<void, void> createSyncNoParamNoResult(
    void Function() action, {
    ValueListenable<bool>? restriction,
    void Function()? ifRestrictedRunInstead,
    bool? catchAlways,
    bool notifyOnlyWhenValueChanges = false,
    String? debugName,
  })
  /// for syncronous functions with one parameter and no result
  static Command<TParam, void> createSyncNoResult<TParam>(
    void Function(TParam x) action, {
    ValueListenable<bool>? restriction,
    ExecuteInsteadHandler<TParam>? ifRestrictedRunInstead,
    bool? catchAlways,
    bool notifyOnlyWhenValueChanges = false,
    String? debugName,
  })
  /// for syncronous functions with no parameter and but a result
  static Command<void, TResult> createSyncNoParam<TResult>(
    TResult Function() func,
    TResult initialValue, {
    ValueListenable<bool>? restriction,
    void Function()? ifRestrictedRunInstead,
    bool includeLastResultInCommandResults = false,
    bool? catchAlways,
    bool notifyOnlyWhenValueChanges = false,
    String? debugName,
  })
  /// for syncronous functions with one parameter and result
  static Command<TParam, TResult> createSync<TParam, TResult>(
    TResult Function(TParam x) func,
    TResult initialValue, {
    ValueListenable<bool>? restriction,
    ExecuteInsteadHandler<TParam>? ifRestrictedRunInstead,
    bool includeLastResultInCommandResults = false,
    bool? catchAlways,
    bool notifyOnlyWhenValueChanges = false,
    String? debugName,
  })

  /// and for Async functions:
  static Command<void, void> createAsyncNoParamNoResult(
    Future Function() action, {
    ValueListenable<bool>? restriction,
    void Function()? ifRestrictedRunInstead,
    bool? catchAlways,
    bool notifyOnlyWhenValueChanges = false,
    String? debugName,
  })
  static Command<TParam, void> createAsyncNoResult<TParam>(
    Future Function(TParam x) action, {
    ValueListenable<bool>? restriction,
    ExecuteInsteadHandler<TParam>? ifRestrictedRunInstead,
    bool? catchAlways,
    bool notifyOnlyWhenValueChanges = false,
    String? debugName,
  })
  static Command<void, TResult> createAsyncNoParam<TResult>(
    Future<TResult> Function() func,
    TResult initialValue, {
    ValueListenable<bool>? restriction,
    void Function()? ifRestrictedRunInstead,
    bool includeLastResultInCommandResults = false,
    bool? catchAlways,
    bool notifyOnlyWhenValueChanges = false,
    String? debugName,
  })
  static Command<TParam, TResult> createAsync<TParam, TResult>(
    Future<TResult> Function(TParam x) func,
    TResult initialValue, {
    ValueListenable<bool>? restriction,
    ExecuteInsteadHandler<TParam>? ifRestrictedRunInstead,
    bool includeLastResultInCommandResults = false,
    bool? catchAlways,
    bool notifyOnlyWhenValueChanges = false,
    String? debugName,
  })
  ```
  For detailed information on the parameters of these functions consult the API docs or the source code documentation.
