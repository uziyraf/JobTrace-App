import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class AddApplicationScreen extends StatefulWidget {
  const AddApplicationScreen({super.key});

  @override
  State<AddApplicationScreen> createState() => _AddApplicationScreenState();
}

class _AddApplicationScreenState extends State<AddApplicationScreen> {
  // Controller untuk mengambil data input saat tombol Save diklik
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _evaluationController = TextEditingController();
  final _notesController = TextEditingController();

  String selectedStatus = 'Applied';
  String selectedPlatform = 'LinkedIn';
  DateTime selectedDate = DateTime.now();

  // Fungsi untuk memunculkan kalender (DatePicker)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Application',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: const Color(0xFF0F172A)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Di sini nanti logika simpan ke Database (Backend)
              print("Data Tersimpan: ${_companyController.text}");
              Navigator.pop(context);
            },
            child: Text('Save',
                style: GoogleFonts.inter(
                    color: const Color(0xFF0EB562),
                    fontWeight: FontWeight.w600)),
          )
        ],
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
                        ['Applied', 'Interview', 'Offer', 'Rejected'],
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

            _buildSelfEvaluationBox(),
            const SizedBox(height: 24),

            _buildInputField(
                "Additional Notes",
                "URL to job posting, recruiter info, etc.",
                null,
                _notesController,
                isMultiline: true),
            const SizedBox(height: 100), // Ruang untuk FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => print("Validate and Save"),
        backgroundColor: const Color(0xFF13EC80),
        child: const Icon(LucideIcons.check, color: Color(0xFF0F172A)),
      ),
    );
  }

  // Widget untuk Input Text (Reusable)
  Widget _buildInputField(String label, String placeholder, IconData? icon,
      TextEditingController controller,
      {bool isMultiline = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
            prefixIcon: icon != null
                ? Icon(icon, size: 20, color: const Color(0xFF94A3B8))
                : null,
            filled: true,
            fillColor: const Color(0xFFEEF2F0),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  // Widget untuk Dropdown
  Widget _buildDropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: items
                .map((String item) =>
                    DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // Widget Date Picker (Klik untuk ganti tanggal)
  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Date Applied",
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF334155))),
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
                    style: GoogleFonts.inter(
                        fontSize: 16, color: const Color(0xFF0F172A))),
                const Icon(LucideIcons.calendar,
                    color: Color(0xFF13EC80), size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget Kotak Self-Evaluation (Persis Figma)
  Widget _buildSelfEvaluationBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.lightbulb,
                  color: Color(0xFF0EB562), size: 18),
              const SizedBox(width: 8),
              Text("SELF-EVALUATION",
                  style: GoogleFonts.inter(
                      color: const Color(0xFF0EB562),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 0.7)),
            ],
          ),
          const SizedBox(height: 8),
          Text("Reflect on your application. How confident do you feel?",
              style: GoogleFonts.inter(
                  color: const Color(0xFF64748B), fontSize: 12)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _evaluationController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "I feel that my cover letter was strong...",
              filled: true,
              fillColor: const Color(0xFFEEF2F0),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}
