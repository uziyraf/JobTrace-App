// Buka habit_model.dart, ganti isinya dengan ini:
import 'package:cloud_firestore/cloud_firestore.dart';

class HabitModel {
  String? id;
  String userId;
  String habitName;
  String? reminderTime;
  bool isReminderOn;
  int currentStreak;
  DateTime? lastCompletedDate;
  String frequency; // <--- INI VARIABEL BARUNYA BOS!

  HabitModel({
    this.id,
    required this.userId,
    required this.habitName,
    this.reminderTime,
    this.isReminderOn = false,
    this.currentStreak = 0,
    this.lastCompletedDate,
    this.frequency = 'Daily', // Default-nya tiap hari
  });

  factory HabitModel.fromMap(Map<String, dynamic> map, String documentId) {
    return HabitModel(
      id: documentId,
      userId: map['userId'] ?? '',
      habitName: map['habitName'] ?? '',
      reminderTime: map['reminderTime'],
      isReminderOn: map['isReminderOn'] ?? false,
      currentStreak: map['currentStreak'] ?? 0,
      lastCompletedDate: map['lastCompletedDate'] != null
          ? (map['lastCompletedDate'] as Timestamp).toDate()
          : null,
      frequency: map['frequency'] ?? 'Daily', // Ambil data frekuensi
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'habitName': habitName,
      'reminderTime': reminderTime,
      'isReminderOn': isReminderOn,
      'currentStreak': currentStreak,
      'lastCompletedDate': lastCompletedDate,
      'frequency': frequency, // Simpan ke Firebase
    };
  }
}
