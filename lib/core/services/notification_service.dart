import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../network/dio_client.dart';

/// Top-level background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // FCM shows the notification automatically for data+notification messages
  // when the app is in background/terminated. No extra work needed here.
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'bringit_high_importance',
    'BringIt Notifications',
    description: 'Order alerts and updates from BringIt',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permission (required on iOS, recommended on Android 13+)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // iOS: show notifications when app is in foreground
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Android: create high-importance channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Init local notifications plugin (for foreground display on Android)
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Foreground: show local notification manually (Android only needs this)
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Background tap: app was backgrounded, user tapped notification
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTap);

    // Terminated tap: app was closed, user tapped notification
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _onNotificationTap(initial);

    // Token refresh
    _messaging.onTokenRefresh.listen(_registerToken);
  }

  void _onForegroundMessage(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    _localNotifications.show(
      n.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  void _onNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;
    final orderId = data['orderId'] as String?;
    if (type == 'order' && orderId != null) {
      Get.toNamed('/orders');
    }
  }

  /// Get the FCM device token for this installation.
  Future<String?> getToken() => _messaging.getToken();

  /// Register (or refresh) the FCM token with the backend.
  Future<void> _registerToken(String token) async {
    try {
      await DioClient.instance.patch('/store/notifications/fcm-token', data: {
        'fcmToken': token,
      });
    } catch (_) {}
  }

  /// Call this after a successful login to send the token to the backend.
  Future<void> registerTokenAfterLogin() async {
    final token = await getToken();
    if (token != null) await _registerToken(token);
  }
}
