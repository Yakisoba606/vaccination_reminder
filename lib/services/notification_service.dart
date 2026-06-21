import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static Future init() async {
    const android = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(
      android: android,
    );

    await notifications.initialize(settings);
    tz.initializeTimeZones();
  }

  static Future scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      ),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'vaccination_channel',
          'Vaccination Reminder',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
