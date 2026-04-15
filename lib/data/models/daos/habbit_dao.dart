import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jobtracker/data/models/habbit_model.dart';

class HabitDao {
  final CollectionReference _habitCollection =
      FirebaseFirestore.instance.collection('habits');

  // Ambil UID User yang lagi login
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // CREATE: Tambah habit baru
  Future<void> addHabit(HabitModel habit) async {
    habit.userId = currentUserId; // Set otomatis ke user yang login
    await _habitCollection.add(habit.toMap());
  }

  // READ: Ambil semua habit milik user secara Realtime
  Stream<List<HabitModel>> getHabitsStream() {
    return _habitCollection
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return HabitModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // UPDATE: Fungsi buat Checklist Habit (Hitung Streak!)
  Future<void> markHabitDone(HabitModel habit) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int newStreak = habit.currentStreak;

    if (habit.lastCompletedDate != null) {
      final lastDate = habit.lastCompletedDate!;
      final lastDateOnly =
          DateTime(lastDate.year, lastDate.month, lastDate.day);
      final difference = today.difference(lastDateOnly).inDays;

      if (difference == 1) {
        // Kalau kemaren ngerjain, streak nambah!
        newStreak += 1;
      } else if (difference > 1) {
        // Kalau bolos 1 hari aja, streak angus balik ke 1!
        newStreak = 1;
      } else if (difference == 0) {
        // Kalau hari ini udah di-check, uncheck (batalin)
        newStreak = habit.currentStreak > 0 ? habit.currentStreak - 1 : 0;
        await _habitCollection.doc(habit.id).update({
          'currentStreak': newStreak,
          'lastCompletedDate': null, // Batalin hari ini
        });
        return;
      }
    } else {
      // Pertama kali ngerjain
      newStreak = 1;
    }

    // Update ke Firebase
    await _habitCollection.doc(habit.id).update({
      'currentStreak': newStreak,
      'lastCompletedDate': today,
    });
  }

  // DELETE: Hapus Habit
  Future<void> deleteHabit(String id) async {
    await _habitCollection.doc(id).delete();
  }
}
