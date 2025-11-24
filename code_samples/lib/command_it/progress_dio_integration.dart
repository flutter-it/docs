import 'dart:io';
import 'package:command_it/command_it.dart';

// Mock Dio classes for compilation
class Dio {
  Future<dynamic> download(
    String url,
    String path, {
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    // Simulate download
    if (onReceiveProgress != null) {
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(Duration(milliseconds: 50));
        onReceiveProgress(i * 1024 * 1024, 100 * 1024 * 1024);
      }
    }
    return null;
  }
}

class CancelToken {
  void cancel([String? reason]) {}
  static bool isCancel(Exception e) => false;
}

class DioException implements Exception {
  DioException();
}

// #region example
final downloadCommand = Command.createAsyncWithProgress<String, File>(
  (url, handle) async {
    final dio = Dio();
    final cancelToken = CancelToken();

    // Forward command cancellation to Dio
    late final subscription;
    subscription = handle.isCanceled.listen(
      (canceled, _) {
        if (canceled) {
          cancelToken.cancel('User canceled');
          subscription.cancel();
        }
      },
    );

    try {
      await dio.download(
        url,
        '/downloads/file.zip',
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            handle.updateProgress(received / total);
            handle.updateStatusMessage(
              'Downloaded ${(received / 1024 / 1024).toStringAsFixed(1)} MB '
              'of ${(total / 1024 / 1024).toStringAsFixed(1)} MB',
            );
          }
        },
      );
      return File('/downloads/file.zip');
    } finally {
      subscription.cancel();
    }
  },
  initialValue: File(''),
);
// #endregion example

void main() {
  // Example usage
  downloadCommand.run('https://example.com/file.zip');
}
