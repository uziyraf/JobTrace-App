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

  Future<void> _markAsDone(ScheduleModel schedule) async {
    final updatedSchedule = ScheduleModel(
      id: schedule.id,
      jobId: schedule.jobId,
      company: schedule.company,
      role: schedule.role,
      date: schedule.date,
      time: schedule.time,
      platform: schedule.platform,
      status: 'COMPLETED',
    );

    await ScheduleDao().updateSchedule(updatedSchedule);

    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SuccessDialog(
            title: 'Completed!',
            message: 'Interview at ${schedule.company} marked as done! 🎉',
          );
        },
      );

      _fetchSchedules();
    }
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
                    color: const Color(0xFF0E3253),
                    borderRadius: BorderRadius.circular(10)),
                labelColor: const Color.fromARGB(255, 253, 253, 253),
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
                child: CircularProgressIndicator(color: Color(0xFF0E3253)))
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
            const Icon(LucideIcons.calendarX, size: 64, color: Color(0000)),
            const SizedBox(height: 16),
            Text("No interviews found.",
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0000))),
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
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1))
            ],
          ),
          child: Column(
            children: [
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

// CLASS SUCCESS DIALOG (WAJIB ADA DI SINI)
class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;

  const SuccessDialog({
    Key? key,
    required this.title,
    required this.message,
    this.primaryButtonText,
    this.onPrimaryButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0x3313EC80),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFF13EC80),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x4C13EC80),
                        blurRadius: 6,
                        offset: Offset(0, 4),
                        spreadRadius: -4,
                      ),
                      BoxShadow(
                        color: Color(0x4C13EC80),
                        blurRadius: 15,
                        offset: Offset(0, 10),
                        spreadRadius: -3,
                      )
                    ],
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 32),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 20,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Column(
              children: [
                if (primaryButtonText != null && onPrimaryButtonPressed != null)
                  ElevatedButton(
                    onPressed: onPrimaryButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_month,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          primaryButtonText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (primaryButtonText != null) const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Dismiss',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
