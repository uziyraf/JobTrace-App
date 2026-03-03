import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobtracker/data/models/daos/application_dao.dart';
import 'package:jobtracker/features/job_tracker/schedule_interview_screen.dart';
import 'package:jobtracker/ui/widgets/main_layout.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:jobtracker/features/job_tracker/add_application_screen.dart';
import '../../data/models/application_model.dart';

class DetailApplicationScreen extends StatefulWidget {
  final ApplicationModel job;

  const DetailApplicationScreen({super.key, required this.job});

  @override
  State<DetailApplicationScreen> createState() =>
      _DetailApplicationScreenState();
}

class _DetailApplicationScreenState extends State<DetailApplicationScreen> {
  late ApplicationModel currentJob;

  @override
  void initState() {
    super.initState();
    currentJob = widget.job; // Simpan ke state agar UI bisa di-refresh
  }

  void _showSuccessCard(String newStatus) {
    final random = Random();
    String message = "";
    bool isInterview = newStatus == 'Interview';

    if (newStatus == 'Offer') {
      List<String> msgs = [
        "Woohoo! You nailed it! 🎉",
        "Hard work pays off! Congratulations!",
        "Time to celebrate your new journey! 🥳"
      ];
      message = msgs[random.nextInt(msgs.length)];
    } else if (newStatus == 'Interview') {
      List<String> msgs = [
        "Awesome! You're one step closer! 🚀",
        "Time to shine! Prepare your best answers.",
        "They loved your profile! Good luck!"
      ];
      message = msgs[random.nextInt(msgs.length)];
    } else if (newStatus == 'Rejected') {
      List<String> msgs = [
        "Every 'no' brings you closer to a 'yes'. Keep going! 💪",
        "Rejection is just redirection. You got this!",
        "Don't give up! The right opportunity is out there."
      ];
      message = msgs[random.nextInt(msgs.length)];
    } else {
      message = "Application updated\nsuccessfully!";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
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
                            blurRadius: 15,
                            offset: Offset(0, 10),
                            spreadRadius: -3)
                      ],
                    ),
                    child: const Icon(LucideIcons.check,
                        color: Colors.white, size: 32),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text('Saved!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      color: const Color(0xFF0F172A),
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              Text(message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      color: const Color(0xFF64748B),
                      fontSize: 16,
                      height: 1.5)),
              const SizedBox(height: 32),

              if (isInterview) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ScheduleInterviewScreen(job: currentJob),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.calendar,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text('Schedule Interview',
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Tombol Dismiss
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // 1. Tutup pop-up "Saved!"
                  Navigator.pop(context,
                      true); // 2. Tutup halaman Detail & kembali ke List
                },
                child: Text('Dismiss',
                    style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- LOGIKA UPDATE DATABASE ---
  Future<void> _updateStatus(String newStatus) async {
    final updatedJob = ApplicationModel(
      id: currentJob.id,
      company: currentJob.company,
      role: currentJob.role,
      status: newStatus,
      platform: currentJob.platform,
      dateApplied: currentJob.dateApplied,
      evaluation: currentJob.evaluation,
      notes: currentJob.notes,
    );

    await ApplicationDao()
        .updateApplication(updatedJob); // Perbarui UI dan tutup pop up
    setState(() => currentJob = updatedJob);
    Navigator.pop(context); // Tutup Bottom Sheet

    _showSuccessCard(newStatus);
  }

  // --- BOTTOM SHEET (POP UP UPDATE STATUS) ---
  void _showUpdateStatusModal() {
    String selectedStatus = currentJob.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle Bar Putih/Abu
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 24),

                // Header Pop-up
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Update Status',
                        style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A))),
                    IconButton(
                        icon:
                            const Icon(LucideIcons.x, color: Color(0xFF94A3B8)),
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: ListView(
                    children: [
                      _buildStatusOption(
                          'Applied',
                          const Color(0xFFDBEAFE),
                          const Color(0xFF1D4ED8),
                          selectedStatus,
                          () =>
                              setModalState(() => selectedStatus = 'Applied')),
                      _buildStatusOption(
                          'Screening',
                          const Color(0xFFF3E8FF),
                          const Color(0xFF7E22CE),
                          selectedStatus,
                          () => setModalState(
                              () => selectedStatus = 'Screening')),
                      _buildStatusOption(
                          'Interview',
                          const Color(0xFFFEF3C7),
                          const Color(0xFFB45309),
                          selectedStatus,
                          () => setModalState(
                              () => selectedStatus = 'Interview')),
                      _buildStatusOption(
                          'Offer',
                          const Color(0xFFD1FAE5),
                          const Color(0xFF065F46),
                          selectedStatus,
                          () => setModalState(() => selectedStatus = 'Offer')),
                      _buildStatusOption(
                          'Rejected',
                          const Color(0xFFFFE4E6),
                          const Color(0xFFBE123C),
                          selectedStatus,
                          () =>
                              setModalState(() => selectedStatus = 'Rejected')),

                      const SizedBox(height: 16),
                      Text('CUSTOM STATUS',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF64748B),
                              letterSpacing: 1.2)),
                      const SizedBox(height: 8),

                      // Input Custom (Hanya placeholder UI untuk sekarang)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'e.g. Technical Assignment',
                                hintStyle: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF94A3B8)),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0))),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(12)),
                            child: Text('ADD',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A))),
                          )
                        ],
                      )
                    ],
                  ),
                ),

                // Tombol Confirm
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EB562),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    onPressed: () => _updateStatus(selectedStatus),
                    child: Text('Confirm Update',
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // Widget Bantuan untuk List Status di Pop-up
  Widget _buildStatusOption(String title, Color bgColor, Color iconColor,
      String selectedStatus, VoidCallback onTap) {
    bool isSelected = selectedStatus == title;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // Pastikan area kosong bisa diklik
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFF0EB562)
                  : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                      color: Color(0x330EB562),
                      blurRadius: 10,
                      offset: Offset(0, 4))
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: bgColor, borderRadius: BorderRadius.circular(12)),
                  child:
                      Icon(LucideIcons.briefcase, color: iconColor, size: 20),
                ),
                const SizedBox(width: 16),
                Text(title,
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: const Color(0xFF0F172A))),
              ],
            ),
            if (isSelected)
              const Icon(LucideIcons.checkCircle2, color: Color(0xFF0EB562)),
          ],
        ),
      ),
    );
  }

  // --- HALAMAN UTAMA (DETAIL VIEW) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF0F172A)),
            onPressed: () => Navigator.pop(context, true)),
        title: Text('APPLICATION DETAIL',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: const Color(0xFF64748B),
                letterSpacing: 1)),
        centerTitle: true,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: const Color(0xFFE2E8F0), height: 1)),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () async {
                  // Arahkan ke halaman Add Screen TAPI bawa data currentJob-nya!
                  final updatedData = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddApplicationScreen(job: currentJob),
                    ),
                  );

                  // Jika halaman edit mengembalikan data baru (artinya berhasil di-save)
                  if (updatedData != null && updatedData is ApplicationModel) {
                    setState(() {
                      currentJob =
                          updatedData; // Langsung refresh UI Detail ini!
                    });
                  }
                },
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: Color(0xFFE2E8F0))),
                child: Text('EDIT',
                    style: GoogleFonts.inter(
                        color: const Color(0xFF475569),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _showUpdateStatusModal,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF0EB562),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: Text('UPDATE STATUS',
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        color: const Color(0xFFEEF2F0),
                        borderRadius: BorderRadius.circular(16)),
                    child: Center(
                        child: Text(
                            currentJob.company.substring(0, 1).toUpperCase(),
                            style: GoogleFonts.inter(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0EB562)))),
                  ),
                  const SizedBox(height: 16),
                  Text(currentJob.role,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  Text(currentJob.company,
                      style: GoogleFonts.inter(
                          fontSize: 16, color: const Color(0xFF64748B))),
                  const SizedBox(height: 16),

                  // Status Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEEF2F0),
                        borderRadius: BorderRadius.circular(99)),
                    child: Text(currentJob.status.toUpperCase(),
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0EB562),
                            letterSpacing: 1)),
                  ),
                  const SizedBox(height: 16),
                  Text("${currentJob.platform.toUpperCase()} APPLICATION",
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 1)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (currentJob.evaluation != null &&
                currentJob.evaluation!.isNotEmpty)
              _buildInfoCard("SELF-EVALUATION", currentJob.evaluation!),
            if (currentJob.notes != null && currentJob.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInfoCard("GENERAL NOTES", currentJob.notes!),
            ],
          ],
        ),
      ),
    );
  }

  // Widget Bantuan untuk buat Kartu Notes/Evaluasi
  Widget _buildInfoCard(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF64748B),
                  letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9))),
            child: Text('"$content"',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF475569),
                    height: 1.5)),
          ),
        ],
      ),
    );
  }
}
