import '_shared/stubs.dart';

// #region example
void main() {
  final isLoadingData = ValueNotifier<bool>(false);
  final isLoadingUser = ValueNotifier<bool>(false);

  // Combine two loading states - true if either is loading
  final isLoading = isLoadingData.combineLatest<bool, bool>(
    isLoadingUser,
    (dataLoading, userLoading) => dataLoading || userLoading,
  );

  isLoading.listen((loading, _) => print('Loading: $loading'));

  // Prints initial: Loading: false

  isLoadingData.value = true;
  // Prints: Loading: true

  isLoadingUser.value = true;
  // Prints: Loading: true (both loading)

  isLoadingData.value = false;
  // Prints: Loading: true (user still loading)

  isLoadingUser.value = false;
  // Prints: Loading: false (both done)
}
// #endregion example
