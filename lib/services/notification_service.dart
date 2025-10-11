import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones(); // Initialize timezone for scheduling
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: androidInitializationSettings,
          iOS: iosInitializationSettings,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap if needed
      },
    );
  }

  Future<void> showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'flood_alert_channel',
          'Flood Alerts',
          channelDescription: 'Notifications for flood alerts',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Flood Alert',
      'Road ahead maybe dangerous',
      notificationDetails,
    );
  }

  Future<void> scheduleNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'flood_alert_channel',
          'Flood Alerts',
          channelDescription: 'Notifications for flood alerts',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      1, // Notification ID
      'Flood Alert',
      'Road ahead maybe dangerous',
      tz.TZDateTime.now(
        tz.local,
      ).add(const Duration(seconds: 5)), // 5 seconds from now
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
