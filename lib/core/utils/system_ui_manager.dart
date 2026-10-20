import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Keeps Android's navigation bar hidden.
///
/// Recent Android targets ignore Flutter's manual system UI mode. The Android
/// activity hides only the navigation bar through native window insets. If the
/// bar returns after a gesture, this manager requests the native setting again.
///
/// [SystemChrome.setSystemUIChangeCallback] does not report the navigation bar
/// alone while the status bar remains visible, so we watch window metrics.
class SystemUiManager with WidgetsBindingObserver {
  SystemUiManager({
    this.hideDelay = const Duration(seconds: 3),
    TargetPlatform? platform,
  }) : _platform = platform ?? defaultTargetPlatform;

  static const _androidChannel = MethodChannel(
    'com.gurbanov.elyeter/system_ui',
  );

  /// How long the bar stays visible after the user swipes it up.
  final Duration hideDelay;
  final TargetPlatform _platform;

  Timer? _timer;

  /// Applies the mode and starts watching for the bar coming back.
  Future<void> start() async {
    WidgetsBinding.instance.addObserver(this);
    await apply();
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Android's native insets API works even when edge-to-edge is enforced.
  /// Keep the previous overlay setting on other platforms.
  Future<void> apply() {
    if (_platform == TargetPlatform.android) {
      return _androidChannel.invokeMethod<void>('hideNavigationBar');
    }
    return SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
  }

  @override
  void didChangeMetrics() {
    final view = WidgetsBinding.instance.platformDispatcher.implicitView;
    if (view == null) return;
    handleBottomPadding(view.viewPadding.bottom);
  }

  /// A bottom padding above zero means the navigation bar is on screen
  /// again. Exposed so the behaviour can be tested without a device.
  void handleBottomPadding(double bottomPadding) {
    if (bottomPadding <= 0) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    // Already counting down; don't restart on every metrics tick.
    if (_timer?.isActive ?? false) return;
    _timer = Timer(hideDelay, apply);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from another app restores the system bars.
    if (state == AppLifecycleState.resumed) unawaited(apply());
  }
}
