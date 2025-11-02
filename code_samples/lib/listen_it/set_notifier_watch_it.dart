import '_shared/stubs.dart';

// #region example
class TagsWidget extends WatchingWidget {
  const TagsWidget(this.tags, {super.key});

  final SetNotifier<String> tags;

  @override
  Widget build(BuildContext context) {
    final set = watch(tags).value;

    return Wrap(
      // Note: .map() here is the standard Dart collection method,
      // not the reactive operator
      children: set.map((tag) => Chip(label: Text(tag))).toList(),
    );
  }
}
// #endregion example
