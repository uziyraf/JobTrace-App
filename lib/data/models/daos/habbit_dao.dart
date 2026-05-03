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

  Future<void> updateHabit(HabitModel habit) async {
    if (habit.id != null) {
      await _habitCollection.doc(habit.id).update(habit.toMap());
    }
  }

  // UPDATE: Fungsi buat Checklist Habit (Smart Streak + Nyawa)
  Future<void> markHabitDone(HabitModel habit) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int newStreak = habit.currentStreak;

    if (habit.lastCompletedDate != null) {
      final lastDate = habit.lastCompletedDate!;
      final lastDateOnly =
          DateTime(lastDate.year, lastDate.month, lastDate.day);
      final difference = today.difference(lastDateOnly).inDays;

      // 1. Ambil batas waktu maksimal berdasarkan siklus frekuensi
      int allowedGap = _getAllowedGap(habit.frequency);

      // 2. Sistem Nyawa: Dikasih toleransi telat 1x siklus
      int gapWithNyawa = allowedGap * 2;

      if (difference == 0) {
        // UNCHECK: Batalin ceklis hari ini
        newStreak = habit.currentStreak > 0 ? habit.currentStreak - 1 : 0;
        await _habitCollection.doc(habit.id).update({
          'currentStreak': newStreak,
          'lastCompletedDate': null,
        });
        return;
      } else if (difference <= allowedGap) {
        newStreak += 1;
      } else if (difference <= gapWithNyawa) {
        newStreak += 1;
        print("Nyawa terpakai untuk habit: ${habit.habitName}");
      } else {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    await _habitCollection.doc(habit.id).update({
      'currentStreak': newStreak,
      'lastCompletedDate': today,
    });
  }

  // --- FUNGSI BANTUAN UNTUK MENGHITUNG BATAS HARI SESUAI SIKLUS ---
  int _getAllowedGap(String frequency) {
    // Kalau opsi bawaan:
    if (frequency == 'Daily') return 1;
    if (frequency == 'Weekdays (Senin - Jumat)')
      return 3; // Mentok telat dari Jumat ke Senin (3 hari)
    if (frequency == 'Weekends (Sabtu - Minggu)')
      return 5; // Mentok telat dari Minggu ke Sabtu (5 hari)
    if (frequency == 'Weekly') return 7;
    if (frequency == 'Bi-weekly') return 14;
    if (frequency == 'Monthly') return 30;

    // Kalau opsi Custom... (contoh: "Setiap 2 Hari", "Setiap 1 Minggu")
    if (frequency.startsWith('Setiap')) {
      final parts =
          frequency.split(' '); // Mecah kata biar bisa dibaca angkanya
      if (parts.length >= 3) {
        int val = int.tryParse(parts[1]) ?? 1; // Ambil angka
        String unit = parts[2]; // Ambil satuan waktu (Hari/Minggu/Bulan)

        if (unit.contains('Hari')) return val;
        if (unit.contains('Minggu')) return val * 7;
        if (unit.contains('Bulan')) return val * 30;
      }
    }

    return 1;
  }

  // DELETE: Hapus Habit (Parameternya diubah jadi HabitModel biar pas sama UI)
  Future<void> deleteHabit(HabitModel habit) async {
    if (habit.id != null) {
      await _habitCollection.doc(habit.id).delete();
    }
  }
}
