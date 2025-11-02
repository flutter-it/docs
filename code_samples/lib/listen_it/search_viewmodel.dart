import '_shared/stubs.dart';

// #region example
class SearchViewModel {
  final searchTerm = ValueNotifier<String>('');
  final results = ListNotifier<SearchResult>(data: []);

  SearchViewModel() {
    // Debounce search input to avoid excessive API calls
    searchTerm
        .debounce(const Duration(milliseconds: 300))
        .where((term) => term.length >= 3)
        .listen((term, _) => _performSearch(term));
  }

  Future<void> _performSearch(String term) async {
    final apiResults = await searchApi(term);

    // Use transaction to batch updates
    results.startTransAction();
    results.clear();
    results.addAll(apiResults);
    results.endTransAction();
  }
}

void main() async {
  final viewModel = SearchViewModel();

  // Listen to results
  viewModel.results.listen((items, _) {
    print('Search results: ${items.length} items');
  });

  // Simulate rapid typing
  viewModel.searchTerm.value = 'f';
  viewModel.searchTerm.value = 'fl';
  viewModel.searchTerm.value = 'flu';
  viewModel.searchTerm.value = 'flut';
  viewModel.searchTerm.value = 'flutter';

  // Only after 300ms pause, API is called and results updated
  await Future.delayed(Duration(milliseconds: 600));
}
// #endregion example
