import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(settings: initSettings);
  }

  Future<void> requestPermission() async {
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  Future<void> scheduleInterviewReminder({
    required int id,
    required String companyName,
    required DateTime interviewDate,
  }) async {
    try {
      await requestPermission();
      final scheduledTime = tz.TZDateTime.from(interviewDate, tz.local)
          .add(const Duration(days: 1));

      if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) return;

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'jalur_skripsi_baru_v1',
        'Interview Reminders',
        importance: Importance.max,
        priority: Priority.high,
        color: Color(0xFF0E3253),
      );

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: 'Gimana interview di $companyName kemarin? 🤩',
        body: 'Yuk tandai selesai dan update status lamaranmu di JobTrace!',
        scheduledDate: scheduledTime,
        notificationDetails: const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('ERROR INTERVIEW NOTIF: $e');
    }
  }

  Future<void> scheduleDailyHabitReminder({
    required int id,
    required String habitName,
    required int hour,
    required int minute,
  }) async {
    try {
      await requestPermission();
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduledDate.isBefore(now))
        scheduledDate = scheduledDate.add(const Duration(days: 1));

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: 'Waktunya Habit: $habitName! 🔥',
        body: 'Yuk selesaikan sekarang agar streak tetap terjaga!',
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
                'habit_channel_id', 'Habit Reminders',
                importance: Importance.max, priority: Priority.high)),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('ERROR HABIT NOTIF: $e');
    }
  }

  // ====================================================================
  // --- FITUR AUTOMASI TEROR FOLLOW UP ---
  // ====================================================================

  // 1. DEFAULT FREQUENCY (DAILY / WEEKLY)
  Future<void> scheduleRecurringFollowUp({
    required int id,
    required String companyName,
    String? note,
    required RepeatInterval interval,
  }) async {
    try {
      await requestPermission();
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'default_follow_up_channel',
        'Default Follow Up Reminders',
        importance: Importance.max,
        priority: Priority.high,
        color: Color(0xFF0E3253),
        styleInformation: BigTextStyleInformation(''),
      );

      String bodyText =
          'Status lamaran di $companyName belum berubah. Yuk cek/follow-up!';
      if (note != null && note.isNotEmpty)
        bodyText = 'Catatan Follow-up: $note';

      await _notificationsPlugin.periodicallyShow(
        id: id,
        title: 'Update Lamaran: $companyName 🏢',
        body: bodyText,
        repeatInterval: interval,
        notificationDetails: const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('ERROR RECURRING NOTIF: $e');
    }
  }

  // 2. CUSTOM FREQUENCY - TESTING 5 DETIK
  Future<void> scheduleCustomFollowUp({
    required int baseId,
    required String companyName,
    String? note,
    required int intervalDays,
  }) async {
    try {
      await requestPermission();
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'custom_follow_up_channel',
        'Custom Follow Up Reminders',
        importance: Importance.max,
        priority: Priority.high,
        color: Color(0xFF0EB562),
        styleInformation: BigTextStyleInformation(''),
      );

      String bodyText =
          'Status lamaran di $companyName belum berubah. Yuk cek/follow-up!';
      if (note != null && note.isNotEmpty)
        bodyText = 'Catatan Follow-up: $note';

      // --- MENGUBAH SEMENTARA JADI DETIK (JEDA 5 DETIK) ---
      for (int i = 1; i <= 5; i++) {
        final scheduledTime =
            tz.TZDateTime.now(tz.local).add(Duration(seconds: 5 * i));

        await _notificationsPlugin.zonedSchedule(
          id: baseId + i,
          title: 'Cek Status: $companyName (Tes ke-$i) 🏢',
          body: bodyText,
          scheduledDate: scheduledTime,
          notificationDetails:
              const NotificationDetails(android: androidDetails),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    } catch (e) {
      debugPrint('ERROR CUSTOM NOTIF: $e');
    }
  }

  // 3. STOP TEROR
  Future<void> cancelFollowUp(int baseId) async {
    try {
      // Wajib pakai id: di versi terbaru
      await _notificationsPlugin.cancel(id: baseId);
      for (int i = 1; i <= 5; i++) {
        await _notificationsPlugin.cancel(id: baseId + i);
      }
      debugPrint('Semua teror follow-up untuk ID $baseId berhasil dihentikan.');
    } catch (e) {
      debugPrint('ERROR CANCEL NOTIF: $e');
    }
  }
}
