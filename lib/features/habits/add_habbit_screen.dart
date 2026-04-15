import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobtracker/data/models/daos/habbit_dao.dart';
import 'package:jobtracker/data/models/habbit_model.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController _nameController = TextEditingController();
  final HabitDao _habitDao = HabitDao();

  TimeOfDay? _selectedTime;
  bool _isReminderOn = false;

  // Variabel untuk Fitur Frekuensi
  String _selectedFrequency = 'Daily'; // Default
  final List<String> _frequencyOptions = [
    'Daily',
    'Weekdays (Senin - Jumat)',
    'Weekends (Sabtu - Minggu)',
    'Weekly',
    'Bi-weekly',
    'Monthly',
    'Custom...' // Opsi untuk frekuensi khusus
  ];

  // 1. Fungsi buat milih jam
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // 2. Fungsi Pop-up Custom Frekuensi (Muncul kalau pilih "Custom...")
  void _showCustomFrequencyDialog() {
    int interval = 2; // Default angka
    String unit = 'Hari'; // Default satuan

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('Pengulangan Khusus',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Setiap ', style: GoogleFonts.inter(fontSize: 16)),
                  const SizedBox(width: 8),
                  // Dropdown Angka (1 sampai 30)
                  DropdownButton<int>(
                    value: interval,
                    items: List.generate(30, (i) => i + 1)
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text('$e')))
                        .toList(),
                    onChanged: (val) => setStateDialog(() => interval = val!),
                  ),
                  const SizedBox(width: 8),
                  // Dropdown Satuan Waktu
                  DropdownButton<String>(
                    value: unit,
                    items: ['Hari', 'Minggu', 'Bulan']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setStateDialog(() => unit = val!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child:
                      const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005DB5)),
                  onPressed: () {
                    // Simpan hasil custom ke variabel utama
                    setState(() {
                      _selectedFrequency = 'Setiap $interval $unit';
                    });
                    Navigator.pop(context); // Tutup pop-up
                  },
                  child: const Text('Simpan',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          });
        });
  }

  // 3. Fungsi Bottom Sheet Frekuensi Utama (VERSI ANTI-OVERFLOW)
  void _showFrequencyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled:
          true, // <--- MAGIC TRICK 1: Biar bisa lebih tinggi dari batas wajar
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          // Tambahin padding bawah nyesuaiin layar HP biar gak ketutup tombol navigasi Android
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom, top: 24),
          // <--- MAGIC TRICK 2: Bungkus pakai SingleChildScrollView biar bisa di-scroll!
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Pilih Frekuensi Habit',
                    style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2B3437))),
                const SizedBox(height: 16),
                ..._frequencyOptions
                    .map((freq) => ListTile(
                          title: Text(freq,
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: const Color(0xFF2B3437))),
                          trailing: _selectedFrequency == freq
                              ? const Icon(Icons.check_circle,
                                  color: Color(0xFF005DB5))
                              : const Icon(Icons.circle_outlined,
                                  color: Colors.grey),
                          onTap: () {
                            if (freq == 'Custom...') {
                              Navigator.pop(context); // Tutup bottom sheet dulu
                              _showCustomFrequencyDialog(); // Buka pop-up angka
                            } else {
                              setState(() {
                                _selectedFrequency = freq;
                              });
                              Navigator.pop(context); // Tutup bottom sheet
                            }
                          },
                        ))
                    .toList(),
                const SizedBox(height: 16), // Spasi ekstra di bawah biar lega
              ],
            ),
          ),
        );
      },
    );
  }

  // 4. Fungsi Simpan Data ke Database
  Future<void> _saveHabit() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Nama habit tidak boleh kosong!'),
            backgroundColor: Colors.red),
      );
      return;
    }

    String? timeString;
    if (_selectedTime != null) {
      timeString =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
    }

    // Pastikan HabitModel lu udah ditambahin variabel 'frequency' ya bos!
    final newHabit = HabitModel(
      userId: '',
      habitName: _nameController.text.trim(),
      reminderTime: timeString,
      isReminderOn: _isReminderOn,
      frequency: _selectedFrequency,
    );

    try {
      await _habitDao.addHabit(newHabit);
      if (mounted) {
        Navigator.pop(context); // Tutup halaman kalau sukses
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2B3437)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Habit Details',
          style: GoogleFonts.manrope(
            color: const Color(0xFF2B3437),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0x7FE2E8F0), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Build your routine',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF4D626C),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Define the architectural logic of your daily workflow. Small habits lead to massive results.',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF586064),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // FORM: HABIT NAME
            Text(
              'HABIT NAME',
              style: GoogleFonts.manrope(
                color: const Color(0xFF737C7F),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _nameController,
                style: GoogleFonts.inter(
                    fontSize: 16, color: const Color(0xFF2B3437)),
                decoration: InputDecoration(
                  hintText: 'e.g., Code Review',
                  hintStyle: GoogleFonts.inter(color: const Color(0xFFABB3B7)),
                  contentPadding: const EdgeInsets.all(20),
                  border: InputBorder.none,
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0x26ABB3B7)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF005DB5), width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // FORM: FREQUENCY
            Text(
              'FREQUENCY',
              style: GoogleFonts.manrope(
                color: const Color(0xFF737C7F),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _showFrequencyPicker,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0x26ABB3B7)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedFrequency,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF2B3437),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(Icons.autorenew, color: Color(0xFF737C7F)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // FORM: REMINDER TIME
            Text(
              'REMINDER TIME',
              style: GoogleFonts.manrope(
                color: const Color(0xFF737C7F),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _selectTime(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTime != null
                          ? _selectedTime!.format(context)
                          : 'Set Time',
                      style: GoogleFonts.inter(
                        color: _selectedTime != null
                            ? const Color(0xFF2B3437)
                            : const Color(0xFFABB3B7),
                        fontSize: 18,
                      ),
                    ),
                    const Icon(Icons.access_time, color: Color(0xFF737C7F)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // FORM: NOTIFICATIONS (SWITCH)
            Text(
              'NOTIFICATIONS',
              style: GoogleFonts.manrope(
                color: const Color(0xFF737C7F),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Remind Me',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF2B3437),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Switch(
                    value: _isReminderOn,
                    activeColor: Colors.white,
                    activeTrackColor: const Color(0xFF005DB5),
                    onChanged: (val) => setState(() => _isReminderOn = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // INFO CARD (NOTE)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 24,
                      offset: Offset(0, 8))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6E3FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lightbulb_outline,
                        color: Color(0xFF005DB5)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Note',
                          style: GoogleFonts.manrope(
                            color: const Color(0xFF2B3437),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Users who set reminders are 45% more likely to complete their goals.',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF737C7F),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // SAVE BUTTON
            InkWell(
              onTap: _saveHabit,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF005DB5), Color(0xFF0052A0)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'SAVE HABIT',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
