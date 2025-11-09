import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:math';

/// A utility class for handling all local notifications in the PetPoint app.
/// Includes instant notifications and scheduled reminders for appointments.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize local notifications
  static Future<void> init() async {
    // Initialize timezone data for accurate scheduling
    tz.initializeTimeZones();

    // Android initialization
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combine settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    // Initialize plugin
    await _notificationsPlugin.initialize(initSettings);

    // Request notification permission (for Android 13+)
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();

    print("✅ NotificationService initialized successfully");
  }

  /// Show an instant (immediate) notification
  static Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'petpoint_channel', // Channel ID
      'PetPoint Reminders', // Channel name
      channelDescription: 'Reminders for upcoming appointments',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    await _notificationsPlugin.show(
      Random().nextInt(100000), // Random ID to avoid collision
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );

    print("🔔 Instant notification shown: $title");
  }

  /// Schedule a reminder notification at a specific time
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
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails();

    final id = Random().nextInt(100000);

    // Convert time to local timezone
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print("⏰ Notification scheduled for: $scheduledTime (ID: $id)");
  }

  /// Cancel all notifications (optional helper)
  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
    print("🗑️ All notifications canceled");
  }
}
