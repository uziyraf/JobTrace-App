import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class JobScreen extends StatelessWidget {
  const JobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7), // Warna background dari Figma
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildStatsGrid(),
              const SizedBox(height: 24),
              _buildWeeklyActivityCard(),
              const SizedBox(height: 32),
              _buildHabitSection(),
            ],
          ),
        ),
      ),
      // Perhatikan: Kita TIDAK ADA lagi kode bottomNavigationBar di sini
    );
  }

  // 1. Header (Profil & Notifikasi)
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x3313EC80), width: 2),
                image: const DecorationImage(
                  image: NetworkImage('https://i.pravatar.cc/150?u=alex'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Good Morning,",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF5C7066),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Alex Johnson",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF0D1B14),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        Stack(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(LucideIcons.bell, color: Color(0xFF0D1B14), size: 24),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. Stats Grid (Data Lamaran)
  Widget _buildStatsGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _statCard(
            "24",
            "APPLIED",
            const Color(0xFFEFF6FF),
            const Color(0xFF0D1B14),
            const Color(0xFF5C7066),
            LucideIcons.fileText,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            "3",
            "INTERVIEWS",
            const Color(0x3313EC80),
            const Color(0xFF0DB662),
            const Color(0xFF0DB662),
            LucideIcons.gem,
            isActive: true,
            bgTint: const Color(0x0C13EC80),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            "5",
            "ACTIVE",
            const Color(0xFFFFF7ED),
            const Color(0xFF0D1B14),
            const Color(0xFF5C7066),
            LucideIcons.briefcase,
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    String value,
    String label,
    Color iconBgColor,
    Color valueColor,
    Color labelColor,
    IconData icon, {
    bool isActive = false,
    Color? bgTint,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgTint ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0x4C13EC80) : const Color(0xFFE2E8E5),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: valueColor, size: 16),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: labelColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Weekly Activity
  Widget _buildWeeklyActivityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8E5), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Weekly Activity",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: const Color(0xFF0D1B14),
                    ),
                  ),
                  Text(
                    "Application volume",
                    style: GoogleFonts.inter(
                      color: const Color(0xFF5C7066),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x1913EC80),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "+12%",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF0DB662),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Center(
            child: Text(
              "Grafik diletakkan di sini",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Daily Habits
  Widget _buildHabitSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Daily Career Habits",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: const Color(0xFF0D1B14),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0x1913EC80),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Manage",
                style: GoogleFonts.inter(
                  color: const Color(0xFF0DB662),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _habitItem("Apply to 5 senior roles", "Career Growth • 5/5 done", true),
        _habitItem("Update LinkedIn Status", "Networking", false),
        _habitItem("Follow up on Emails", "Communication", false),
      ],
    );
  }

  // Komponen Item Habit
  Widget _habitItem(String title, String subtitle, bool isDone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDone ? const Color(0x3313EC80) : const Color(0xFFE2E8E5),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFF13EC80) : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDone
                    ? const Color(0xFF13EC80)
                    : const Color(0xFFD1D5DB),
                width: 2,
              ),
            ),
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: isDone ? FontWeight.w500 : FontWeight.w600,
                    fontSize: 14,
                    color: isDone
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF0D1B14),
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDone
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF5C7066),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
