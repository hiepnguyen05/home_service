import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Xin quyền thông báo
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      print('User granted permission: ${settings.authorizationStatus}');
    }

    // Cấu hình Local Notifications cho Foreground
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Cập nhật: v21.0.0 dùng tham số 'settings'
    await _localNotifications.initialize(
      settings: initializationSettings,
    );

    // Kênh thông báo cho Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // name
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Lắng nghe tin nhắn khi App đang mở (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        // Hiển thị thông báo hệ thống (v21.0.0 dùng named arguments)
        _localNotifications.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker',
            ),
          ),
        );
      }
    });

    // Lắng nghe khi người dùng nhấn vào thông báo (Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageNavigation(message);
    });

    // Kiểm tra thông báo khi app đã bị kill
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageNavigation(initialMessage);
    }
  }

  static void _handleMessageNavigation(RemoteMessage message) {
    if (kDebugMode) {
      print('🔔 [NotificationService] Nhấn vào thông báo: ${message.data}');
    }
  }

  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  // Lắng nghe thông báo từ RTDB (Giải pháp thay thế FCM Direct khi không có Server Key)
  static void observeNotifications(String userId) {
    FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          "https://homeservice-a4290-default-rtdb.asia-southeast1.firebasedatabase.app",
    ).ref('notifications/$userId').onChildAdded.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        // Hiển thị thông báo hệ thống (v21.0.0 dùng named arguments)
        _localNotifications.show(
          id: data.hashCode,
          title: data['title']?.toString(),
          body: data['body']?.toString(),
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
        // Xóa thông báo sau khi đã hiển thị để tránh lặp lại
        event.snapshot.ref.remove();
      }
    });
  }
}
