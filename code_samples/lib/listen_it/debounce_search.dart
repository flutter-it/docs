import '_shared/stubs.dart';

// #region example
void main() async {
  final searchTerm = ValueNotifier<String>('');

  // Debounce search input - only calls API after 500ms pause
  searchTerm
      .debounce(const Duration(milliseconds: 500))
      .listen((s, _) => callRestApi(s));

  // Rapid typing - each keystroke updates the value
  searchTerm.value = 'f';
  searchTerm.value = 'fl';
  searchTerm.value = 'flu';
  searchTerm.value = 'flut';
  searchTerm.value = 'flutt';
  searchTerm.value = 'flutte';
  searchTerm.value = 'flutter';

  // Only after 500ms pause, the API is called with 'flutter'
  // Output (after 500ms): API called with: flutter

  // Wait to see the output
  await Future.delayed(Duration(milliseconds: 600));
}
// #endregion example
