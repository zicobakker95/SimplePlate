import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Handles daily "time to log your meals" reminders.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'sp_reminders';
  static const _reminderId = 1001;

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final tzName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (_) {
      // A zone name the bundled database does not know: stay on UTC rather
      // than fail start-up.
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );
  }

  /// Asks for notification permission and returns whether reminders can
  /// actually be shown. False when the user declined now or earlier (the
  /// system no longer asks after a refusal), so the caller can keep the
  /// reminder switch off and point to the system settings instead of
  /// promising a reminder that will never arrive.
  ///
  /// A platform error counts as granted: it says nothing about the user's
  /// choice, and blocking the switch on it would break reminders outright.
  Future<bool> requestPermissions(BuildContext context) async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        if (granted != null) return granted;
        // Below Android 13 there is no runtime prompt; the app-level switch
        // in the system settings is what counts.
        return await android.areNotificationsEnabled() ?? true;
      }

      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        return await ios.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            true;
      }
    } catch (e) {
      debugPrint('[notifications] permission request failed: $e');
    }
    return true;
  }

  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    String? title,
    String? body,
    String? channelName,
    String? channelDescription,
  }) async {
    await _plugin.cancel(id: _reminderId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: _reminderId,
      title: title ?? 'Time to log your meals 🥗',
      body: body ?? 'Keep your streak going — log what you ate today!',
      scheduledDate: scheduled,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          channelName ?? 'Daily Reminders',
          channelDescription:
              channelDescription ?? 'Reminds you to log your meals each day',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      // Inexact on purpose: a meal reminder does not need to the minute, and
      // inexact alarms need no SCHEDULE_EXACT_ALARM permission.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelReminder() => _plugin.cancel(id: _reminderId);
}
