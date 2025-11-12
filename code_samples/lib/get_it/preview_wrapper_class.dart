import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// #region example
/// A wrapper widget for Flutter widget previews that initializes GetIt.
///
/// This widget handles GetIt setup in initState and cleanup via reset()
/// in dispose, making it perfect for preview scenarios where widgets are
/// rendered in isolation.
class GetItPreviewWrapper extends StatefulWidget {
  const GetItPreviewWrapper({
    super.key,
    required this.init,
    required this.child,
  });

  /// The child widget to render after GetIt is initialized
  final Widget child;

  /// Initialization function that registers dependencies in GetIt
  final void Function(GetIt getIt) init;

  @override
  State<GetItPreviewWrapper> createState() => _GetItPreviewWrapperState();
}

class _GetItPreviewWrapperState extends State<GetItPreviewWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize GetIt with preview dependencies
    widget.init(GetIt.instance);
  }

  @override
  void dispose() {
    // Clean up all GetIt registrations when preview is disposed
    GetIt.instance.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
// #endregion example

void main() {
  // This file is for documentation only
}
