import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobtracker/data/models/daos/schedule_dao.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:jobtracker/features/job_tracker/custom_schedule_screen.dart';
import '../../data/models/schedule_model.dart';

class ListScheduleScreen extends StatefulWidget {
  const ListScheduleScreen({super.key});

  @override
  State<ListScheduleScreen> createState() => _ListScheduleScreenState();
}

class _ListScheduleScreenState extends State<ListScheduleScreen> {
  List<ScheduleModel> upcomingList = [];
  List<ScheduleModel> completedList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    setState(() => isLoading = true);
    final allSchedules = await ScheduleDao().getAllSchedules();

    setState(() {
      upcomingList = allSchedules.where((s) => s.status == 'UPCOMING').toList();
      completedList =
          allSchedules.where((s) => s.status == 'COMPLETED').toList();
      isLoading = false;
    });
  }

  // --- FUNGSI BARU: MARK AS DONE ---
  Future<void> _markAsDone(ScheduleModel schedule) async {
    // 1. Ubah status model menjadi COMPLETED
    final updatedSchedule = ScheduleModel(
      id: schedule.id,
      jobId: schedule.jobId,
      company: schedule.company,
      role: schedule.role,
      date: schedule.date,
      time: schedule.time,
      platform: schedule.platform,
      status: 'COMPLETED', // Diubah di sini!
    );

    // 2. Simpan perubahan ke Database
    await ScheduleDao().updateSchedule(updatedSchedule);

    // 3. Tampilkan Notifikasi
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Interview at ${schedule.company} marked as done! 🎉'),
          backgroundColor: const Color(0xFF0EB562),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // 4. Refresh List agar kartu langsung pindah tab
    _fetchSchedules();
  }

  Color _getPlatformColor(String platform) {
    if (platform == 'ZOOM') return const Color(0xFF137FEC);
    if (platform == 'MEET') return const Color(0xFF10B981);
    if (platform == 'TEAMS') return const Color(0xFF9333EA);
    return const Color(0xFF64748B);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF6F8F7),
          elevation: 0,
          title: Text(
            'Interviews',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: const Color(0xFF0F172A)),
          ),
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.calendarPlus,
                  color: Color(0xFF0F172A)),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomScheduleScreen(),
                  ),
                );

                // 2. Setelah halaman Custom Schedule ditutup (kembali ke sini),
                // otomatis panggil fungsi fetch untuk refresh data dari Firebase!
                _fetchSchedules();
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0))),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                    color: const Color(0xFF13EC80),
                    borderRadius: BorderRadius.circular(10)),
                labelColor: const Color(0xFF0F172A),
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
                unselectedLabelStyle:
                    GoogleFonts.inter(fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF13EC80)))
            : TabBarView(
                children: [
                  _buildScheduleList(upcomingList),
                  _buildScheduleList(completedList),
                ],
              ),
      ),
    );
  }

  Widget _buildScheduleList(List<ScheduleModel> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.calendarX,
                size: 64, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text("No interviews found.",
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        bool isCompleted = item.status == 'COMPLETED';
        Color platformColor = _getPlatformColor(item.platform);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1))
            ],
          ),
          child: Column(
            children: [
              // HEADER CARD
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12)),
                    child: Center(
                      child: Text(
                        item.company.substring(0, 1).toUpperCase(),
                        style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0EB562)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.company,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A))),
                        Text(item.role,
                            style: GoogleFonts.inter(
                                fontSize: 14, color: const Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: platformColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      item.platform,
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: platformColor,
                          letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // WAKTU CARD
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.date,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B))),
                        Text(item.time,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isCompleted
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF1E293B))),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: isCompleted
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF10B981),
                              shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.status,
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isCompleted
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF10B981)),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // --- TOMBOL MARK AS DONE (Hanya Muncul Jika Belum Selesai) ---
              if (!isCompleted) ...[
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFE2E8F0)),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () =>
                        _markAsDone(item), // Panggil fungsi saat diklik
                    icon: const Icon(LucideIcons.checkCircle2,
                        color: Color(0xFF0EB562), size: 18),
                    label: Text(
                      'Mark as Done',
                      style: GoogleFonts.inter(
                          color: const Color(0xFF0EB562),
                          fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
