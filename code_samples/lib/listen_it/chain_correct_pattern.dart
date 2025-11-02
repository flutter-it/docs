import '_shared/stubs.dart';

// #region example
// ✅ Option 1: StatefulWidget with initState
class MyWidget extends StatefulWidget {
  final ValueNotifier<int> source;

  const MyWidget(this.source, {super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final ValueListenable<int> chain;

  @override
  void initState() {
    super.initState();
    // ✅ CORRECT: Chain created ONCE in initState
    chain = widget.source.map((x) => x * 2);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: chain, // Same object every rebuild - NO LEAK
      builder: (context, value, child) => Text('$value'),
    );
  }
}

// ✅ Option 2: watch_it with createOnce
class MyWidgetWithWatchIt extends WatchingWidget {
  final ValueNotifier<int> source;

  const MyWidgetWithWatchIt(this.source, {super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ CORRECT: createOnce ensures chain created only once
    final chain = createOnce(() => source.map((x) => x * 2));

    return ValueListenableBuilder<int>(
      valueListenable: chain,
      builder: (context, value, child) => Text('$value'),
    );
  }
}

// ✅ Option 3: Put chains in your data layer (RECOMMENDED)
class CounterService {
  final source = ValueNotifier<int>(0);

  // Chain created once in data layer
  late final doubled = source.map((x) => x * 2);

  void dispose() {
    // Only dispose the source - the chain will be GC'd when service is unreachable
    source.dispose();
  }
}

class MyWidgetWithService extends StatelessWidget {
  const MyWidgetWithService(this.service, {super.key});

  final CounterService service;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: service.doubled, // Chain from data layer - NO LEAK
      builder: (context, value, child) => Text('$value'),
    );
  }
}
// #endregion example
