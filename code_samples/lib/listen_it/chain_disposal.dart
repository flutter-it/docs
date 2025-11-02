import 'package:flutter/material.dart';
import '_shared/stubs.dart';

// #region stateful_disposal
class ProperDisposalWidget extends StatefulWidget {
  final ValueNotifier<int> source;

  const ProperDisposalWidget(this.source, {super.key});

  @override
  State<ProperDisposalWidget> createState() => _ProperDisposalWidgetState();
}

class _ProperDisposalWidgetState extends State<ProperDisposalWidget> {
  late final ValueListenable<int> chain;

  @override
  void initState() {
    super.initState();
    // Create chain in initState
    chain = widget.source.map((x) => x * 2);
  }

  @override
  void dispose() {
    // ✅ IMPORTANT: Always dispose chains!
    if (chain is ChangeNotifier) {
      (chain as ChangeNotifier).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: chain,
      builder: (context, value, child) => Text('$value'),
    );
  }
}
// #endregion stateful_disposal

// #region model_disposal
class ChainModel extends ChangeNotifier {
  final ValueNotifier<int> source = ValueNotifier(0);
  late final ValueListenable<int> chain;

  ChainModel() {
    chain = source.map((x) => x * 2);
  }

  @override
  void dispose() {
    // ✅ IMPORTANT: Dispose chains when model is disposed
    if (chain is ChangeNotifier) {
      (chain as ChangeNotifier).dispose();
    }
    source.dispose();
    super.dispose();
  }
}
// #endregion model_disposal

// #region subscription_disposal
void subscriptionExample() {
  final source = ValueNotifier<int>(0);
  final chain = source.map((x) => x * 2);

  // Create subscription
  final subscription = chain.listen((value, _) => print(value));

  // Later: cancel subscription when done
  subscription.cancel();

  // Also dispose the chain itself
  if (chain is ChangeNotifier) {
    (chain as ChangeNotifier).dispose();
  }
}
// #endregion subscription_disposal
