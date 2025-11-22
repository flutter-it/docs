import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';

// Mock analytics service
class Analytics {
  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    debugPrint('Analytics: $name - $parameters');
  }
}

final analytics = Analytics();

// #region example
void setupLoggingHandler() {
  Command.loggingHandler = (commandName, result) {
    // Log all command executions to analytics

    // Track command started
    if (result.isRunning) {
      analytics.logEvent('command_started', parameters: {
        'command': commandName,
        'has_parameter': result.paramData != null,
      });
      return;
    }

    // Track command completed
    if (result.hasData) {
      analytics.logEvent('command_success', parameters: {
        'command': commandName,
        'has_data': result.data != null,
        'parameter': result.paramData?.toString(),
      });
      return;
    }

    // Track command error
    if (result.hasError) {
      analytics.logEvent('command_error', parameters: {
        'command': commandName,
        'error_type': result.error.runtimeType.toString(),
        'parameter': result.paramData?.toString(),
        'had_previous_data': result.data != null,
      });
    }
  };
}
// #endregion example

void main() {
  setupLoggingHandler();
}
