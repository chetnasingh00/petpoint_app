import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:math';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize local notifications
  static Future<void> init() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _notificationsPlugin.initialize(initSettings);

    // ✅ Request notification permission on Android 13+ devices
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();

    print("✅ NotificationService initialized");
  }

  /// Show an instant (immediate) notification
  static Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'petpoint_channel',
      'PetPoint Reminders',
      channelDescription: 'Reminders for upcoming appointments',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    await _notificationsPlugin.show(
      Random().nextInt(100000), // random ID to avoid overwriting
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );

    print("🔔 Instant notification shown: $title");
  }

  /// Schedule a future reminder notification
  static Future<void> scheduleReminderNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'petpoint_channel',
      'PetPoint Reminders',
      channelDescription: 'Reminders for upcoming appointments',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails();

    final id = Random().nextInt(100000);

    print("⏰ Scheduling notification for: $scheduledTime (ID: $id)");

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print("✅ Notification scheduled successfully");
  }

  /// Cancel all scheduled notifications (optional helper)
  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
    print("🗑️ All notifications canceled");
  }
}
