import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SkillScreen extends StatefulWidget {
  const SkillScreen({super.key});

  @override
  State<SkillScreen> createState() => _SkillScreenState();
}

class _SkillScreenState extends State<SkillScreen> {
  final TextEditingController _skillController = TextEditingController();
  final List<String> _skills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSkillsFromFirebase();
  }

  // AMBIL DATA DARI FIREBASE
  Future<void> _loadSkillsFromFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data()!['skills'] != null) {
          setState(() {
            _skills.clear();
            _skills.addAll(List<String>.from(doc.data()!['skills']));
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading skills: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // SIMPAN SEMUA DATA KE FIREBASE
  Future<void> _saveSkillsToFirebase() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Simpan array _skills ke dokumen user
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'skills': _skills,
        }, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Skills saved to your profile! 🎉'),
                backgroundColor: Color(0xFF0EB562)),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to save skills'),
            backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addSkill() {
    final newSkill = _skillController.text.trim();
    if (newSkill.isNotEmpty) {
      bool isDuplicate =
          _skills.any((skill) => skill.toLowerCase() == newSkill.toLowerCase());

      if (!isDuplicate) {
        setState(() {
          _skills.insert(0, newSkill);
        });
        _skillController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Skill ini sudah ada!'),
              backgroundColor: Colors.orange),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Skills',
          style: GoogleFonts.manrope(
              color: const Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0E3253)))
          : SafeArea(
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
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: const Color(0xFFF1F5F9)),
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
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: const Icon(LucideIcons.code,
                                          size: 20, color: Color(0xFFF59E0B)),
                                    ),
                                    const SizedBox(width: 12),
                                    Text('Define Your Expertise',
                                        style: GoogleFonts.manrope(
                                            color: const Color(0xFF4D626C),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Daftar skill ini akan digunakan untuk menghitung persentase kecocokan saat kamu melamar pekerjaan.',
                                  style: GoogleFonts.inter(
                                      color: const Color(0xFF586064),
                                      fontSize: 14,
                                      height: 1.4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // INPUT SKILL
                          Text('ADD NEW SKILL',
                              style: GoogleFonts.manrope(
                                  color: const Color(0xFF737C7F),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2)),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: const Color(0xFFF1F5F9))),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _skillController,
                                    style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: const Color(0xFF2B3437)),
                                    onSubmitted: (_) => _addSkill(),
                                    decoration: InputDecoration(
                                      hintText: 'e.g., Flutter, Figma, Dart...',
                                      hintStyle: GoogleFonts.inter(
                                          color: const Color(0xFFABB3B7)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 16),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                IconButton(
                                    onPressed: _addSkill,
                                    icon: const Icon(LucideIcons.plusCircle,
                                        color: Color(0xFF005DB5))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // LIST OF SKILLS
                          Row(
                            children: [
                              Text('YOUR SKILLS',
                                  style: GoogleFonts.manrope(
                                      color: const Color(0xFF737C7F),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2)),
                              const Spacer(),
                              Text('${_skills.length} Total',
                                  style: GoogleFonts.inter(
                                      color: const Color(0xFF0E3253),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (_skills.isEmpty)
                            Center(
                                child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Text("Belum ada skill.",
                                        style: GoogleFonts.inter(
                                            color: const Color(0xFF94A3B8)))))
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
                                    border: Border.all(
                                        color: const Color(0xFFE2E8F0)),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Color(0x05000000),
                                          blurRadius: 4,
                                          offset: Offset(0, 2))
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(skill,
                                          style: GoogleFonts.inter(
                                              color: const Color(0xFF0F172A),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => _removeSkill(skill),
                                        child: const Icon(LucideIcons.x,
                                            size: 16, color: Color(0xFFEF4444)),
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

                  // TOMBOL SAVE PERMANEN
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            top: BorderSide(
                                color: Colors.black.withOpacity(0.05)))),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveSkillsToFirebase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E3253),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text('SAVE TO PROFILE',
                            style: GoogleFonts.manrope(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.4)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
