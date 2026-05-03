import 'package:flutter/material.dart'; // 1. IMPORT INI MENGATASI ERROR 'Color'
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
    // Setup timezone dasar
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings: initSettings,
    );
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
      print("🔔 [NOTIF LOG] Mulai memproses notifikasi...");

      await requestPermission();
      print("🔔 [NOTIF LOG] Cek Izin selesai.");

      final scheduledTime =
          tz.TZDateTime.now(tz.UTC).add(const Duration(seconds: 10));
      print("🔔 [NOTIF LOG] Jadwal diset pada: $scheduledTime");

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'jalur_skripsi_baru_v1',
        'Interview Reminders',
        channelDescription: 'Reminds you to update interview status',
        importance: Importance.max,
        priority: Priority.high,
        color: Color(0xFF0EB562),
      );

      const NotificationDetails details =
          NotificationDetails(android: androidDetails);

      print("🔔 [NOTIF LOG] Mengirim perintah ke sistem Android...");

      // 👇👇👇 KODE TEST INSTAN 👇👇👇
      await _notificationsPlugin.show(
        id: 99,
        title: 'TEST INSTAN 🚀',
        body: 'Kalau ini muncul, berarti Infinix memblokir alarm 10 detiknya!',
        notificationDetails: details,
      );
      // 👆👆👆 ================= 👆👆👆

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: 'Gimana interview di $companyName kemarin? 🤩',
        body: 'Yuk tandai selesai dan update status lamaranmu di JobTracker!',
        scheduledDate: scheduledTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      print("✅ [NOTIF LOG] SUKSES! Jadwal 10 detik berhasil ditanam ke HP.");
    } catch (e) {
      print("🚨 [NOTIF ERROR] GAGAL! Penyebabnya: $e");
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
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // Kalau jamnya udah lewat hari ini, lempar ke besok
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      print("🔔 [NOTIF LOG] Habit '$habitName' diset ke: $scheduledDate");

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: 'Waktunya Habit: $habitName! 🔥',
        body: 'Yuk selesaikan sekarang agar streak tetap terjaga!',
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_channel_id', // ID Channel bebas tapi unik
            'Habit Reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents:
            DateTimeComponents.time, // Biar tiap hari jam segini
      );

      print("✅ [NOTIF LOG] Berhasil ditanam!");
    } catch (e) {
      print("🚨 [NOTIF ERROR] Gagal: $e");
    }
  }
}
