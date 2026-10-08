import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../firebase_options.dart';
import '../utils/app_logger.dart';
import 'local_notifications_service.dart';

/// Push notifications, open or closed.
///
/// Three deliveries, three paths: the system draws the banner itself when
/// the app is backgrounded or terminated, [_onForeground] draws it by hand
/// when the app is open, and [_backgroundHandler] runs in its own isolate so
/// a data-only push is still processed with the app closed.
class PushService {
  PushService(this._auth, this._local);

  /// Everyone who opens the app joins this; broadcasts are sent here.
  static const topic = 'elyeter';

  final AuthRepository _auth;
  final LocalNotificationsService _local;

  String? _token;

  /// Never throws: a phone without Play services, or a build whose Firebase
  /// config is missing, must still open the app.
  Future<void> init() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      }
      await _local.init();

      final messaging = FirebaseMessaging.instance;

      // Android 13+ and iOS both raise the system prompt here.
      final settings = await messaging.requestPermission();
      AppLogger.i('Push permission: ${settings.authorizationStatus.name}');

      // iOS suppresses banners while the app is open unless this is set —
      // independent of the permission above.
      if (Platform.isIOS) {
        await messaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
      }

      await messaging.subscribeToTopic(topic);
      AppLogger.i('Subscribed to topic "$topic"');

      // Registered before the streams: a terminated-app delivery reaches the
      // isolate below, which has no Firebase of its own.
      FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
      FirebaseMessaging.onMessage.listen(_onForeground);
      FirebaseMessaging.onMessageOpenedApp.listen(_onOpened);

      // The notification that launched the app from a cold start; it never
      // reaches `onMessageOpenedApp`.
      final initial = await messaging.getInitialMessage();
      if (initial != null) _onOpened(initial);

      // On iOS the FCM token is derived from the APNs one, and asking too
      // early simply returns null — with no second attempt, the device then
      // has no token for the rest of the session.
      await _awaitApns();

      _token = await messaging.getToken();
      await _printTokens();
      unawaited(syncToken());

      // A rotated token is useless to the backend until it is sent again.
      messaging.onTokenRefresh.listen((token) {
        _token = token;
        AppLogger.group(
          AnsiColor.paint('FCM token refreshed', AnsiColor.magenta),
          lines: [token],
        );
        unawaited(syncToken());
      });
    } on Object catch (e, s) {
      AppLogger.e('Push setup failed', e, s);
    }
  }

  /// Waits for APNs to hand iOS its device token, up to [_apnsWait].
  ///
  /// A no-op on Android and on the simulator, which never gets one — the
  /// loop just runs out and the app carries on without push, which is the
  /// right outcome there.
  Future<void> _awaitApns() async {
    if (!Platform.isIOS) return;

    final deadline = DateTime.now().add(_apnsWait);
    while (DateTime.now().isBefore(deadline)) {
      final apns = await FirebaseMessaging.instance.getAPNSToken();
      if (apns != null) return;
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
    AppLogger.w('APNs did not answer in ${_apnsWait.inSeconds}s');
  }

  /// Long enough for a fresh install on a slow network, short enough that
  /// nothing else at startup notices — this runs off the first frame.
  static const _apnsWait = Duration(seconds: 6);

  /// Prints both device tokens in full, on their own block, so a test push
  /// can be addressed to this exact phone from the Firebase console.
  ///
  /// Whole tokens, not masked: they are worth nothing without the project's
  /// server key, this only ever runs in a debug build ([AppLogger] is silent
  /// in release), and a truncated token cannot be pasted anywhere.
  Future<void> _printTokens() async {
    AppLogger.group(
      AnsiColor.paint('FCM token', AnsiColor.magenta),
      lines: [_token ?? 'null — no token yet'],
    );

    // iOS only: null on Android, and null on iOS until the APNs handshake
    // finishes, which can take a beat right after a fresh install.
    if (!Platform.isIOS) return;
    try {
      final apns = await FirebaseMessaging.instance.getAPNSToken();
      AppLogger.group(
        AnsiColor.paint('APNs token', AnsiColor.magenta),
        lines: [apns ?? 'null — APNs has not answered yet'],
      );
    } on Object catch (e) {
      AppLogger.w('APNs token fetch failed: $e');
    }
  }

  /// `PATCH /auth/fcm-token`. Only meaningful with a session, so the login
  /// flow calls it again the moment the SMS code is verified — boot-time
  /// registration happens before any token exists.
  Future<void> syncToken() async {
    try {
      final token = _token ??= await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      if (!await _auth.hasSession()) return;

      final result = await _auth.updateFcmToken(token);
      result.fold(
        (_) => AppLogger.i('FCM token registered with the backend'),
        (failure) => AppLogger.w('FCM token not registered: ${failure.code}'),
      );
    } on Object catch (e) {
      AppLogger.w('FCM token sync failed: $e');
    }
  }

  void _onForeground(RemoteMessage message) {
    final notification = message.notification;
    // iOS presents the remote message itself (configured in [init]); a local
    // one on top of it would be a duplicate banner.
    if (notification == null || Platform.isIOS) return;

    unawaited(_local.show(notification.title, notification.body, payload: message.data.toString()));
  }

  void _onOpened(RemoteMessage message) {
    AppLogger.i('Notification opened: ${message.data}');
    // Routing from a payload (an order, a product) hangs off this.
  }
}

/// Runs in its own isolate with the app backgrounded or killed, so it shares
/// nothing with [PushService] and has to bring Firebase up itself.
@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
}
