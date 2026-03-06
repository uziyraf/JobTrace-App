import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobtracker/core/services/notification_service.dart';
import 'package:jobtracker/data/models/daos/schedule_dao.dart';
import 'package:jobtracker/data/models/schedule_model.dart';
import 'package:jobtracker/ui/widgets/main_layout.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/application_model.dart';
import 'package:intl/intl.dart';

class CustomScheduleScreen extends StatefulWidget {
  final ApplicationModel job;

  const CustomScheduleScreen({super.key, required this.job});

  @override
  State<CustomScheduleScreen> createState() => _CustomScheduleScreenState();
}

class _CustomScheduleScreenState extends State<CustomScheduleScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 30);
  String selectedPlatform = 'ZOOM';
  bool isReminderOn = true;
  String reminderTime = '1 hour before';

  // State baru untuk Activity Type
  String selectedActivity = 'Online Test';
  final TextEditingController _customActivityController =
      TextEditingController();

  final List<String> predefinedActivities = [
    'Online Test',
    'FGD',
    'Technical Interview',
    'HR Interview',
    'User Interview'
  ];

  @override
  void dispose() {
    _customActivityController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF137FEC), // Warna biru sesuai Figma baru
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

  Future<void> _saveSchedule() async {
    // Ambil nama aktivitas final (dari chip pilihan ATAU dari input custom)
    String finalActivity = _customActivityController.text.trim().isNotEmpty
        ? _customActivityController.text.trim()
        : selectedActivity;

    final newSchedule = ScheduleModel(
      jobId: widget.job.id!,
      company: widget.job.company,
      role: widget.job.role,
      date: DateFormat('MMM dd, yyyy').format(selectedDate),
      time: selectedTime.format(context),
      platform: selectedPlatform,
      status:
          'UPCOMING', // Atau kamu bisa simpan finalActivity di database kalau ada fieldnya
    );

    final interviewDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // Set Notifikasi (Bisa dimodif pesannya biar dinamis sesuai aktivitas)
    await NotificationService().scheduleInterviewReminder(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      companyName: "${widget.job.company} ($finalActivity)",
      interviewDate: interviewDateTime,
    );

    await ScheduleDao().insertSchedule(newSchedule);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('$finalActivity scheduled for ${widget.job.company}! 📅'),
          backgroundColor: const Color(0xFF137FEC), // Biru Figma
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF0D141B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Quick Schedule',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: const Color(0xFF0D141B))),
        centerTitle: false,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xCCF6F7F8),
        ),
        child: ElevatedButton(
          onPressed: _saveSchedule,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF137FEC), // Biru Figma
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
          ),
          child: Text('Add to Calendar',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CALENDAR DATE PICKER (Asli Flutter)
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x07000000),
                        blurRadius: 4,
                        offset: Offset(0, 2)),
                  ]),
              child: CalendarDatePicker(
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                onDateChanged: (date) => setState(() => selectedDate = date),
              ),
            ),
            const SizedBox(height: 24),

            // 2. TIME PICKER
            Text('Select Time',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0D141B))),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x07000000),
                          blurRadius: 4,
                          offset: Offset(0, 2)),
                    ]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.clock,
                        color: Color(0xFF137FEC), size: 28),
                    const SizedBox(width: 16),
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

            // 3. PLATFORM SELECTION
            Text('Platform',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0D141B))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildPlatformCard('ZOOM')),
                const SizedBox(width: 8),
                Expanded(child: _buildPlatformCard('MEET')),
                const SizedBox(width: 8),
                Expanded(child: _buildPlatformCard('TEAMS')),
                const SizedBox(width: 8),
                Expanded(child: _buildPlatformCard('IN-\nPERSON')),
              ],
            ),
            const SizedBox(height: 24),

            // 4. ACTIVITY TYPE (CHIPS & CUSTOM INPUT)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Activity Type',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF334155))),
                Text('SELECT ONE',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 1)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: predefinedActivities.map((activity) {
                bool isSelected = selectedActivity == activity &&
                    _customActivityController.text.isEmpty;
                return ChoiceChip(
                  label: Text(activity,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF475569))),
                  selected: isSelected,
                  selectedColor: const Color(0xFF137FEC),
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                      side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF137FEC)
                              : const Color(0xFFE2E8F0))),
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                        selectedActivity = activity;
                        _customActivityController
                            .clear(); // Hapus custom jika milih chip
                        FocusScope.of(context).unfocus();
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // Custom Activity Input
            TextField(
              controller: _customActivityController,
              onChanged: (val) {
                if (val.isNotEmpty) {
                  setState(() => selectedActivity =
                      ''); // Kosongkan chip jika user ngetik custom
                }
              },
              decoration: InputDecoration(
                hintText: 'Or enter custom activity type...',
                hintStyle: GoogleFonts.inter(
                    color: const Color(0xFF6B7280), fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF137FEC))),
              ),
            ),
            const SizedBox(height: 24),

            // 5. JOB DETAILS (READ-ONLY)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LINK TO APPLICATION',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                          letterSpacing: 0.6)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0x19137FEC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(LucideIcons.briefcase,
                              color: Color(0xFF137FEC)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.job.role,
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0F172A))),
                              const SizedBox(height: 4),
                              Text(widget.job.company,
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF64748B))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 6. SET REMINDER
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x0C000000),
                        blurRadius: 20,
                        offset: Offset(0, 4))
                  ]),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                  color: Color(0x19137FEC),
                                  shape: BoxShape.circle),
                              child: const Icon(LucideIcons.bellRing,
                                  color: Color(0xFF137FEC), size: 20),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Set Reminder',
                                    style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
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
                          onChanged: (val) =>
                              setState(() => isReminderOn = val),
                          activeColor: const Color(0xFF137FEC),
                        ),
                      ],
                    ),
                  ),
                  if (isReminderOn) ...[
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
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
                                  size: 16, color: Color(0xFF137FEC)),
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
                                              color: const Color(0xFF137FEC),
                                              fontWeight: FontWeight.w600))))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => reminderTime = val!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(
                height: 100), // Spacing agar tidak tertutup tombol bawah
          ],
        ),
      ),
    );
  }

  // Widget Bantuan: Kartu Pilihan Platform
  Widget _buildPlatformCard(String title) {
    bool isSelected = selectedPlatform == title.replaceAll('\n', '-');
    return GestureDetector(
      onTap: () =>
          setState(() => selectedPlatform = title.replaceAll('\n', '-')),
      child: Container(
        height: 70,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF137FEC) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFF137FEC)
                  : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.25,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
