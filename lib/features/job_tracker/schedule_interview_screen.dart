import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobtracker/core/services/notification_service.dart';
import 'package:jobtracker/data/models/daos/schedule_dao.dart';
import 'package:jobtracker/data/models/schedule_model.dart';
import 'package:jobtracker/ui/widgets/main_layout.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/application_model.dart';
import 'package:intl/intl.dart';

class ScheduleInterviewScreen extends StatefulWidget {
  final ApplicationModel job;

  const ScheduleInterviewScreen({super.key, required this.job});

  @override
  State<ScheduleInterviewScreen> createState() =>
      _ScheduleInterviewScreenState();
}

class _ScheduleInterviewScreenState extends State<ScheduleInterviewScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 30);
  String selectedPlatform = 'ZOOM';
  bool isReminderOn = true;
  String reminderTime = '1 hour before';

  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0EB562), // Warna header hijau
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() => selectedTime = picked);
    }
  }

  // Fungsi saat tombol Add to Calendar diklik
  Future<void> _saveSchedule() async {
    final newSchedule = ScheduleModel(
      jobId: widget.job.id!,
      company: widget.job.company,
      role: widget.job.role,
      date: DateFormat('MMM dd, yyyy').format(selectedDate),
      time: selectedTime.format(context),
      platform: selectedPlatform,
      status: 'UPCOMING',
    );
    final interviewDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // Panggil Service Notifikasinya!
    await NotificationService().scheduleInterviewReminder(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      companyName: widget.job.company, // Sesuaikan dengan variabel namamu
      interviewDate: interviewDateTime,
    );

    await ScheduleDao().insertSchedule(newSchedule);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Interview scheduled for ${widget.job.company}! 📅'),
          backgroundColor: const Color(0xFF0EB562),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MainLayout(initialIndex: 2),
        ),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _linkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Quick Schedule',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: const Color(0xFF0F172A))),
        centerTitle: true,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: ElevatedButton(
          onPressed: _saveSchedule,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0EB562),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('Add to Calendar',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9))),
              child: CalendarDatePicker(
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                onDateChanged: (date) => setState(() => selectedDate = date),
              ),
            ),
            const SizedBox(height: 24),

            // 2. WAKTU (TIME PICKER)
            Text('Select Time',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A))),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1F5F9))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.clock,
                        color: Color(0xFF0EB562), size: 24),
                    const SizedBox(width: 12),
                    Text(
                      selectedTime.format(context),
                      style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 3. COMPANY & POSITION (READ-ONLY)
            Text('Company Name',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A))),
            const SizedBox(height: 8),
            _buildReadOnlyField(widget.job.company, LucideIcons.building2),
            const SizedBox(height: 16),

            Text('Position',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A))),
            const SizedBox(height: 8),
            _buildReadOnlyField(widget.job.role, LucideIcons.briefcase),
            const SizedBox(height: 24),

            // 4. PLATFORM SELECTION
            Text('Platform',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildPlatformCard('ZOOM')),
                const SizedBox(width: 8),
                Expanded(child: _buildPlatformCard('MEET')),
                const SizedBox(width: 8),
                Expanded(child: _buildPlatformCard('TEAMS')),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildPlatformCard('IN-PERSON', isMultiline: true)),
              ],
            ),
            const SizedBox(height: 24),

            // 5. MEETING DETAILS
            Text('Meeting Details',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A))),
            const SizedBox(height: 12),
            TextField(
              controller: _linkController,
              decoration: InputDecoration(
                hintText: 'Paste meeting link here',
                hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                filled: true,
                fillColor: Colors.white,
                prefixIcon:
                    const Icon(LucideIcons.link, color: Color(0xFF94A3B8)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add a short note (optional)',
                hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
              ),
            ),
            const SizedBox(height: 24),

            // 6. SET REMINDER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9))),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                                color: Color(0xFFEEF2F0),
                                shape: BoxShape.circle),
                            child: const Icon(LucideIcons.bellRing,
                                color: Color(0xFF0EB562), size: 20),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Set Reminder',
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A))),
                              Text('Get notified before start',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF64748B))),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: isReminderOn,
                        onChanged: (val) => setState(() => isReminderOn = val),
                        activeColor: const Color(0xFF0EB562),
                      ),
                    ],
                  ),
                  if (isReminderOn) ...[
                    const Divider(height: 32, color: Color(0xFFF1F5F9)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Notify me',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF0F172A))),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: reminderTime,
                            icon: const Icon(LucideIcons.chevronDown,
                                size: 16, color: Color(0xFF0EB562)),
                            items: [
                              '15 mins before',
                              '30 mins before',
                              '1 hour before',
                              '1 day before'
                            ]
                                .map((time) => DropdownMenuItem(
                                    value: time,
                                    child: Text(time,
                                        style: GoogleFonts.inter(
                                            color: const Color(0xFF0EB562),
                                            fontWeight: FontWeight.bold))))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => reminderTime = val!),
                          ),
                        ),
                      ],
                    )
                  ]
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget Bantuan: Kotak Read Only (Untuk Company & Position)
  Widget _buildReadOnlyField(String text, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text,
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0F172A)))),
          const Icon(LucideIcons.lock,
              color: Color(0xFFCBD5E1),
              size: 16), // Tanda kalau ini tidak bisa diedit
        ],
      ),
    );
  }

  // Widget Bantuan: Kartu Pilihan Platform
  Widget _buildPlatformCard(String title, {bool isMultiline = false}) {
    bool isSelected = selectedPlatform == title;
    return GestureDetector(
      onTap: () => setState(() => selectedPlatform = title),
      child: Container(
        height: 70,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0EB562) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFF0EB562)
                  : const Color(0xFFE2E8F0)),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                      color: Color(0x4C0EB562),
                      blurRadius: 8,
                      offset: Offset(0, 4))
                ]
              : [],
        ),
        child: Text(
          isMultiline ? title.replaceAll('-', '\n') : title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
