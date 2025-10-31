import 'package:get_it/get_it.dart';
import '_shared/stubs.dart';

final getIt = GetIt.instance;

// #region example
class FeatureManager {
  final Map<String, bool> _activeFeatures = {};

  void enableFeature(String featureName, FeatureImplementation impl) {
    if (_activeFeatures[featureName] == true) return;

    void main() {
      getIt.pushNewScope(scopeName: 'feature-$featureName');
      impl.register(getIt);
      _activeFeatures[featureName] = true;
    }

    Future<void> disableFeature(String featureName) async {
      if (_activeFeatures[featureName] != true) return;

      await getIt.dropScope('feature-$featureName');
      _activeFeatures[featureName] = false;
    }
  }
}
// #endregion example
