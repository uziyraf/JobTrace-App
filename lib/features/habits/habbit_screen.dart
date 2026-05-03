import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobtracker/data/models/daos/habbit_dao.dart';
import 'package:jobtracker/data/models/habbit_model.dart';
import 'package:jobtracker/features/habits/add_habbit_screen.dart';

class HabitScreen extends StatefulWidget {
  const HabitScreen({super.key});

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  final HabitDao _habitDao = HabitDao();

  String get _formattedDate {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 24),
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
            ),
            child: const Icon(Icons.person_outline, color: Color(0xFF64748B)),
          )
        ],
      ),
      body: StreamBuilder<List<HabitModel>>(
        stream: _habitDao.getHabitsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF13ECDA)));
          }

          final habits = snapshot.data ?? [];

          final today = DateTime.now();
          int completedToday = 0;
          for (var h in habits) {
            if (h.lastCompletedDate != null &&
                h.lastCompletedDate!.year == today.year &&
                h.lastCompletedDate!.month == today.month &&
                h.lastCompletedDate!.day == today.day) {
              completedToday++;
            }
          }

          double progressPercent =
              habits.isEmpty ? 0.0 : (completedToday / habits.length);
          int progressDisplay = (progressPercent * 100).toInt();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Habits',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF0F172A),
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formattedDate,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // PROGRESS CARD
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: progressPercent,
                              strokeWidth: 8,
                              backgroundColor: const Color(0xFFF1F5F9),
                              color: const Color(0xFF13ECDA),
                            ),
                            Center(
                              child: Text(
                                '$progressDisplay%',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              progressDisplay == 100
                                  ? 'All done!'
                                  : 'Great progress!',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF0F172A),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$completedToday of ${habits.length} habits completed for today. Keep going!',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF64748B),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ACTIVE HABITS SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Habits',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF0F172A),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Manage',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF13ECDA),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // LIST OF HABITS DARI FIREBASE
                if (habits.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Belum ada habit.\nKlik tombol + untuk menambah!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: habits.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      bool isDoneToday = false;
                      if (habit.lastCompletedDate != null) {
                        isDoneToday =
                            habit.lastCompletedDate!.year == today.year &&
                                habit.lastCompletedDate!.month == today.month &&
                                habit.lastCompletedDate!.day == today.day;
                      }

                      return Dismissible(
                        key: Key(habit.id ?? habit.habitName),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.white, size: 28),
                        ),

                        // TAMBAHIN BAGIAN INI BUAT POP UP KONFIRMASI
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: Text(
                                  'Hapus Habit?',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                content: Text(
                                  'Yakin mau hapus habit "${habit.habitName}"? Data yang dihapus nggak bisa dikembalikan.',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(
                                        false), // Return false = batal hapus
                                    child: Text(
                                      'Batal',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF64748B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(
                                        true), // Return true = lanjut hapus
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Hapus',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        // onDismissed BARU DIJALANKAN KALAU CONFIRMDISMISS RETURN TRUE
                        onDismissed: (direction) {
                          _habitDao.deleteHabit(habit);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${habit.habitName} dihapus'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: _buildActiveHabitCard(
                          habit,
                          isDoneToday,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddHabitScreen(habitToEdit: habit),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 32),

                // SUGGESTED HABITS
                Text(
                  'Suggested Habits',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF0F172A),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: [
                      _buildSuggestedHabitCard(
                          'Update LinkedIn\nProfile', Icons.work_outline),
                      const SizedBox(width: 16),
                      _buildSuggestedHabitCard('Review & Polish\nResume',
                          Icons.description_outlined),
                      const SizedBox(width: 16),
                      _buildSuggestedHabitCard(
                          'Mock\nInterview', Icons.people_outline),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddHabitScreen()),
          );
        },
        backgroundColor: const Color(0xFF13ECDA),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildActiveHabitCard(
      HabitModel habit, bool isDoneToday, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDoneToday
                    ? const Color(0xFF13ECDA).withOpacity(0.15)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.task_alt,
                  color: isDoneToday
                      ? const Color(0xFF13ECDA)
                      : const Color(0xFF94A3B8)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.habitName,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: isDoneToday
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '🔥 STREAK: ${habit.currentStreak}',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _habitDao.markHabitDone(habit),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDoneToday
                      ? const Color(0xFF13ECDA)
                      : const Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                child: isDoneToday
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedHabitCard(String title, IconData icon) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              color: const Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              _habitDao.addHabit(HabitModel(
                  userId: '', habitName: title.replaceAll('\n', ' ')));
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Berhasil menambah habit: $title')));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF13ECDA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Add',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF13ECDA),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
