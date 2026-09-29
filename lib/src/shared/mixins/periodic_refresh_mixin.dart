import 'dart:async';

import 'package:flutter/widgets.dart';

/// Interval + app-resume refresh for screens that should stay reasonably fresh.
///
/// Call [startPeriodicRefresh] from `initState` and [stopPeriodicRefresh] from
/// `dispose`. Override [onPeriodicRefresh] to reload data (silent preferred).
mixin PeriodicRefreshMixin<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  Timer? _periodicTimer;

  /// Default matches merchant web (`businessPoll.ts`).
  Duration get refreshInterval => const Duration(seconds: 30);

  /// Whether the timer should run. Override to pause while inactive, etc.
  bool get shouldPeriodicRefresh => true;

  Future<void> onPeriodicRefresh();

  void startPeriodicRefresh() {
    WidgetsBinding.instance.addObserver(this);
    _restartTimer();
  }

  void stopPeriodicRefresh() {
    WidgetsBinding.instance.removeObserver(this);
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  void _restartTimer() {
    _periodicTimer?.cancel();
    if (!shouldPeriodicRefresh) return;
    _periodicTimer = Timer.periodic(refreshInterval, (_) {
      if (!mounted || !shouldPeriodicRefresh) return;
      unawaited(onPeriodicRefresh());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        mounted &&
        shouldPeriodicRefresh) {
      unawaited(onPeriodicRefresh());
      _restartTimer();
    }
  }
}
