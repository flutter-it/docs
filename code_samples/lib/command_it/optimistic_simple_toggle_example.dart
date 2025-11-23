import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import '_shared/stubs.dart';

// #region example
class Post extends ChangeNotifier {
  final String id;
  final String title;
  bool isBookmarked;

  late final toggleBookmarkCommand = Command.createAsyncNoParamNoResult(
    () async {
      // Optimistic update - toggle immediately
      isBookmarked = !isBookmarked;
      notifyListeners();

      // Sync to server
      await getIt<ApiClient>().updateBookmark(id, isBookmarked);
    },
  )..errors.listen((error, _) {
      if (error != null) {
        // Restore previous state by inverting the value again
        isBookmarked = !isBookmarked;
        notifyListeners();

        // Show error to user
        showSnackBar('Failed to update bookmark: ${error.error}');
      }
    });

  Post(this.id, this.title, this.isBookmarked);
}
// #endregion example

void main() {
  setupDependencyInjection();

  final post = Post('post1', 'My First Post', false);

  // Test the toggle
  post.toggleBookmarkCommand();
}
