import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobtracker/data/models/daos/application_dao.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../data/models/application_model.dart';
import '../../core/services/notification_service.dart';

class AddApplicationScreen extends StatefulWidget {
  final ApplicationModel? job;
  const AddApplicationScreen({super.key, this.job});

  @override
  State<AddApplicationScreen> createState() => _AddApplicationScreenState();
}

class _AddApplicationScreenState extends State<AddApplicationScreen> {
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _evaluationController = TextEditingController();
  final _notesController = TextEditingController();
  final _followUpNoteController = TextEditingController();

  String selectedStatus = 'Applied';
  String selectedPlatform = 'LinkedIn';
  DateTime selectedDate = DateTime.now();

  // --- VARIABEL FREKUENSI TEROR ---
  String selectedFrequency = 'Daily'; // Opsi: Daily, Weekly, Custom
  int customFrequencyDays = 2; // Default kalau milih custom

  List<String> _userSkillsFromProfile = [];
  double _currentMatchScore = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchUserSkills();
    _evaluationController.addListener(_updateMatchScore);

    if (widget.job != null) {
      _companyController.text = widget.job!.company;
      _positionController.text = widget.job!.role;
      _evaluationController.text = widget.job!.evaluation ?? '';
      _notesController.text = widget.job!.notes ?? '';
      selectedStatus = widget.job!.status;
      selectedPlatform = widget.job!.platform;
      _currentMatchScore = widget.job!.matchPercentage;
    }
  }

  Future<void> _fetchUserSkills() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data() != null && doc.data()!['skills'] != null) {
          setState(() => _userSkillsFromProfile =
              List<String>.from(doc.data()!['skills']));
        }
        _updateMatchScore();
      }
    } catch (e) {
      debugPrint("Error fetching profile skills: $e");
    }
  }

  void _updateMatchScore() {
    String desc = _evaluationController.text.toLowerCase();
    if (_userSkillsFromProfile.isEmpty || desc.isEmpty) {
      if (mounted) setState(() => _currentMatchScore = 0.0);
      return;
    }
    int matches = 0;
    for (var skill in _userSkillsFromProfile) {
      if (desc.contains(skill.toLowerCase())) matches++;
    }
    if (mounted)
      setState(() =>
          _currentMatchScore = (matches / _userSkillsFromProfile.length) * 100);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() => selectedDate = picked);
  }

  Future<void> _saveApplication() async {
    if (_companyController.text.trim().isEmpty ||
        _positionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Company and Position are required!'),
          backgroundColor: Colors.redAccent));
      return;
    }

    // Pakai ID database atau random ID kalau baru bikin (buat ID alarm)
    int notificationId =
        widget.job?.id ?? (DateTime.now().millisecondsSinceEpoch % 100000);

    final newApp = ApplicationModel(
      id: widget.job?.id,
      company: _companyController.text.trim(),
      role: _positionController.text.trim(),
      status: selectedStatus,
      platform: selectedPlatform,
      dateApplied: DateFormat('MM/dd/yyyy').format(selectedDate),
      evaluation: _evaluationController.text.trim(),
      notes: _notesController.text.trim(),
      matchPercentage: _currentMatchScore,
    );

    final applicationDao = ApplicationDao();
    if (widget.job == null) {
      await applicationDao.insertApplication(newApp);
    } else {
      await applicationDao.updateApplication(newApp);
    }
    if (selectedStatus == 'Offer' || selectedStatus == 'Rejected') {
      // Hentikan teror kalau udah diterima / ditolak
      await NotificationService().cancelFollowUp(notificationId);
    } else {
      // Pasang teror sesuai pilihan
      if (selectedFrequency == 'Daily') {
        await NotificationService().scheduleRecurringFollowUp(
            id: notificationId,
            companyName: newApp.company,
            note: _followUpNoteController.text.trim(),
            interval: RepeatInterval.daily);
      } else if (selectedFrequency == 'Weekly') {
        await NotificationService().scheduleRecurringFollowUp(
            id: notificationId,
            companyName: newApp.company,
            note: _followUpNoteController.text.trim(),
            interval: RepeatInterval.weekly);
      } else if (selectedFrequency == 'Custom') {
        await NotificationService().scheduleCustomFollowUp(
            baseId: notificationId,
            companyName: newApp.company,
            note: _followUpNoteController.text.trim(),
            intervalDays: customFrequencyDays);
      }
    }

    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => SuccessDialog(
          title: widget.job == null ? 'Saved!' : 'Updated!',
          message: 'Follow-up automation set to: $selectedFrequency',
        ),
      );
      if (mounted) Navigator.pop(context, newApp);
    }
  }

  @override
  void dispose() {
    _evaluationController.removeListener(_updateMatchScore);
    _companyController.dispose();
    _positionController.dispose();
    _evaluationController.dispose();
    _notesController.dispose();
    _followUpNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.job != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F7),
        elevation: 0,
        leading: IconButton(
            icon: const Icon(LucideIcons.x, color: Color(0xFF0F172A)),
            onPressed: () => Navigator.pop(context)),
        title: Text(isEditing ? 'Edit Application' : 'Add Application',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: const Color(0xFF0F172A))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField("Company Name", "e.g. Google",
                LucideIcons.building2, _companyController),
            const SizedBox(height: 20),
            _buildInputField("Position Title", "e.g. UX Designer",
                LucideIcons.briefcase, _positionController),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _buildDropdown(
                        "Status",
                        selectedStatus,
                        [
                          'Applied',
                          'Screening',
                          'Interview',
                          'Offer',
                          'Rejected'
                        ],
                        (val) => setState(() => selectedStatus = val!))),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildDropdown(
                        "Platform",
                        selectedPlatform,
                        ['LinkedIn', 'Indeed', 'Website', 'Other'],
                        (val) => setState(() => selectedPlatform = val!))),
              ],
            ),
            const SizedBox(height: 20),
            _buildDatePicker(),
            const SizedBox(height: 24),

            // --- BOX PENGATURAN TEROR FOLLOW UP ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.bellRing,
                          size: 18, color: Color(0xFF0EB562)),
                      const SizedBox(width: 8),
                      Text("Follow-up Automation",
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: const Color(0xFF0F172A))),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildDropdown(
                      "Frequency:",
                      selectedFrequency,
                      ['Daily', 'Weekly', 'Custom'],
                      (val) => setState(() => selectedFrequency = val!)),

                  // Muncul cuma kalau user milih 'Custom'
                  if (selectedFrequency == 'Custom') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text("Remind me every: ",
                            style: GoogleFonts.inter(
                                fontSize: 14, color: const Color(0xFF64748B))),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 80,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: customFrequencyDays,
                              isExpanded: true,
                              items: [2, 3, 4, 5, 6]
                                  .map((int e) => DropdownMenuItem(
                                      value: e, child: Text("$e Days")))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => customFrequencyDays = val!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),
                  _buildInputField(
                      "Specific Note (Optional)",
                      "e.g. Ask about salary range...",
                      null,
                      _followUpNoteController),
                ],
              ),
            ),
            // ----------------------------------------

            const SizedBox(height: 24),
            _buildSelfEvaluationBox(),
            const SizedBox(height: 24),
            _buildInputField("Additional Notes", "URL, recruiter info, etc.",
                null, _notesController,
                isMultiline: true),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveApplication,
        backgroundColor: const Color(0xFF0E3253),
        child: const Icon(LucideIcons.check, color: Colors.white),
      ),
    );
  }

  Widget _buildSelfEvaluationBox() {
    return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("SELF-EVALUATION",
              style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(
              controller: _evaluationController,
              maxLines: 3,
              decoration: InputDecoration(
                  hintText: "Skills requirement...",
                  filled: true,
                  fillColor: const Color(0xFFEEF2F0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none)))
        ]));
  }

  Widget _buildInputField(String label, String placeholder, IconData? icon,
      TextEditingController controller,
      {bool isMultiline = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF334155))),
      const SizedBox(height: 6),
      TextFormField(
          controller: controller,
          maxLines: isMultiline ? 4 : 1,
          decoration: InputDecoration(
              hintText: placeholder,
              prefixIcon: icon != null
                  ? Icon(icon, size: 20, color: const Color(0xFF94A3B8))
                  : null,
              filled: true,
              fillColor: const Color(0xFFEEF2F0),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none)))
    ]);
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF334155))),
      const SizedBox(height: 6),
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: const Color(0xFFEEF2F0),
              borderRadius: BorderRadius.circular(16)),
          child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  items: items
                      .map((String item) => DropdownMenuItem(
                          value: item,
                          child: Text(item,
                              style: GoogleFonts.inter(fontSize: 14))))
                      .toList(),
                  onChanged: onChanged)))
    ]);
  }

  Widget _buildDatePicker() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Date Applied",
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9))),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('MM/dd/yyyy').format(selectedDate),
                        style: GoogleFonts.inter(fontSize: 16)),
                    const Icon(LucideIcons.calendar,
                        color: Color(0xFF0E3253), size: 20)
                  ])))
    ]);
  }
}

class SuccessDialog extends StatelessWidget {
  final String title, message;
  const SuccessDialog({super.key, required this.title, required this.message});
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                      color: Color(0x3313EC80), shape: BoxShape.circle),
                  child: Center(
                      child: Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                              color: Color(0xFF13EC80), shape: BoxShape.circle),
                          child: const Icon(Icons.check,
                              color: Colors.white, size: 32)))),
              const SizedBox(height: 24),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(message,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: Color(0xFF64748B), fontSize: 16)),
              const SizedBox(height: 32),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Dismiss'))
            ])));
  }
}
