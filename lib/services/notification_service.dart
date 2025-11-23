import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/models/task_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'remindy_channel_id';
  static const String channelName = 'Remindy Notifications';
  static const String channelDesc = 'Pengingat tugas akademik';

  Future<void> init() async {
    // 1. Setup Timezone
    tz_data.initializeTimeZones();
    try {
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    // 2. Setup Icon
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint("Notifikasi diklik: ${details.payload}");
      },
    );

    // 3. Create Channel
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDesc,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );
    }
  }

  // Cek Izin Exact Alarm (Android 12+)
  Future<void> checkAndroidScheduleExactAlarmPermission(BuildContext context) async {
    if (Platform.isAndroid) {
      // Cek status izin "Schedule Exact Alarm"
      final status = await Permission.scheduleExactAlarm.status;
      
      if (status.isDenied) {
        // Jika ditolak/belum aktif, tampilkan dialog
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF2C2C2C),
              title: const Text("Izin Diperlukan", style: TextStyle(color: Colors.white)),
              content: const Text(
                "Agar notifikasi Remindy bisa bunyi tepat waktu (bukan terlambat), mohon izinkan 'Alarms & Reminders' di pengaturan.",
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Nanti Saja", style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    // Buka settingan khusus Alarm
                    await openAppSettings();
                  },
                  child: const Text("Buka Pengaturan", style: TextStyle(color: Colors.blueAccent)),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  Future<void> scheduleTaskNotification(TaskModel task) async {
    if (!task.isReminderActive || task.isCompleted == 1) return;

    final notificationId = task.id ?? 0;
    final deadline = task.deadline;
    final now = DateTime.now();

    if (deadline.isAfter(now)) {
      await _scheduleOneShot(
        id: notificationId * 10 + 0,
        title: "Waktunya Deadline! ⏰",
        body: "Tugas '${task.title}' harus selesai sekarang.",
        scheduledDate: deadline,
      );
    }

    final hMin1 = deadline.subtract(const Duration(hours: 1));
    if (hMin1.isAfter(now)) {
      await _scheduleOneShot(
        id: notificationId * 10 + 1,
        title: "1 Jam Lagi! ⏳",
        body: "Yuk selesaikan '${task.title}' segera.",
        scheduledDate: hMin1,
      );
    }

    final hMin24 = deadline.subtract(const Duration(days: 1));
    if (hMin24.isAfter(now)) {
      await _scheduleOneShot(
        id: notificationId * 10 + 2,
        title: "Deadline Besok! 📅",
        body: "Persiapkan tugas '${task.title}' dari sekarang.",
        scheduledDate: hMin24,
      );
    }
  }

  Future<void> _scheduleOneShot({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDesc,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint("Error scheduling notification: $e");
    }
  }

  Future<void> cancelNotification(int taskId) async {
    await flutterLocalNotificationsPlugin.cancel(taskId * 10 + 0);
    await flutterLocalNotificationsPlugin.cancel(taskId * 10 + 1);
    await flutterLocalNotificationsPlugin.cancel(taskId * 10 + 2);
  }
  
  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}