import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SkillScreen extends StatefulWidget {
  const SkillScreen({super.key});

  @override
  State<SkillScreen> createState() => _SkillScreenState();
}

class _SkillScreenState extends State<SkillScreen> {
  final TextEditingController _skillController = TextEditingController();

  // List skill sementara. Nanti kalau mau disambungin ke Firebase,
  // lu tinggal fetch data list-nya dari Firestore user profile.
  final List<String> _skills = [
    'Flutter',
    'Dart',
    'Firebase',
    'Git',
    'UI/UX Design'
  ];

  void _addSkill() {
    final newSkill = _skillController.text.trim();
    if (newSkill.isNotEmpty) {
      // Cek biar gak ada skill yang duplikat (Case Insensitive)
      bool isDuplicate =
          _skills.any((skill) => skill.toLowerCase() == newSkill.toLowerCase());

      if (!isDuplicate) {
        setState(() {
          _skills.insert(
              0, newSkill); // Masukin skill baru ke posisi paling atas
        });
        _skillController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Skill ini sudah ada di daftar!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _removeSkill(String skillToRemove) {
    setState(() {
      _skills.remove(skillToRemove);
    });
  }

  @override
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Skills',
          style: GoogleFonts.manrope(
            color: const Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // INFO CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0x33F59E0B),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(LucideIcons.code,
                                    size: 20, color: Color(0xFFF59E0B)),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Define Your Expertise',
                                style: GoogleFonts.manrope(
                                  color: const Color(0xFF4D626C),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Add your technical and soft skills here. We will use this data to calculate your Success Rate when you apply for a job.',
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

                    // INPUT SKILL
                    Text(
                      'ADD NEW SKILL',
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
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _skillController,
                              style: GoogleFonts.inter(
                                  fontSize: 16, color: const Color(0xFF2B3437)),
                              onSubmitted: (_) =>
                                  _addSkill(), // Tambah via tombol enter di keyboard
                              decoration: InputDecoration(
                                hintText: 'e.g., Python, Figma, Leadership...',
                                hintStyle: GoogleFonts.inter(
                                    color: const Color(0xFFABB3B7)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: IconButton(
                              onPressed: _addSkill, // Tambah via klik ikon plus
                              icon: const Icon(LucideIcons.plusCircle),
                              color: const Color(0xFF005DB5),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // LIST OF SKILLS (CHIPS)
                    Row(
                      children: [
                        Text(
                          'YOUR SKILLS',
                          style: GoogleFonts.manrope(
                            color: const Color(0xFF737C7F),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_skills.length} Total',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF13EC80),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_skills.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            "Belum ada skill yang ditambahkan.",
                            style: GoogleFonts.inter(
                                color: const Color(0xFF94A3B8)),
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 10.0,
                        runSpacing: 12.0,
                        children: _skills.map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x05000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  skill,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF0F172A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _removeSkill(skill),
                                  child: const Icon(
                                    LucideIcons.x,
                                    size: 16,
                                    color: Color(
                                        0xFFEF4444), // Warna merah untuk hapus
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),

            // SAVE BUTTON AREA DI BAWAH
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.black.withOpacity(0.05)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Nanti di sini lu tambahin logika buat nyimpen List _skills ke Firebase
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Skills berhasil disimpan!')),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF13EC80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'SAVE TO PROFILE',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
