import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDarkMode = false;
  double cardTransparency = 0.7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.6),
        elevation: 0,
        title: Text(
          'Profile & Settings',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: const Color(0xFF0F172A)),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(LucideIcons.settings, color: Color(0xFF13EC80))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildThemeSection(),
            const SizedBox(height: 24),
            _buildStylingSection(),
            const SizedBox(height: 24),
            _buildAppPreferences(),
            const SizedBox(height: 24),
            _buildHighlightCard(),
            const SizedBox(height: 24),
            _buildSignOutButton(),
          ],
        ),
      ),
    );
  }

  // 1. Profile Header (Foto, Nama, Label)
  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withOpacity(0.5), width: 4),
                image: const DecorationImage(
                    image:
                        NetworkImage("https://i.pravatar.cc/150?u=alex_rivera"),
                    fit: BoxFit.cover),
              ),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2)),
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        Text('Alex Rivera',
            style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A))),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
              color: const Color(0xFF13EC80),
              borderRadius: BorderRadius.circular(99)),
          child: Text('JOB SEEKER',
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5)),
        ),
      ],
    );
  }

  // 2. Workspace Theme (Background Selector)
  Widget _buildThemeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("WORKSPACE THEME", showSeeAll: true),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Backgrounds',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: const Color(0xFF64748B))),
              const SizedBox(height: 8),
              // Ganti Row dengan Wrap agar jika tidak muat otomatis turun ke bawah
              Wrap(
                spacing: 10, // Jarak antar kotak secara horizontal
                runSpacing: 10, // Jarak antar kotak jika turun ke bawah
                children: [
                  _themeThumb("https://placehold.co/60x60", isSelected: true),
                  _themeThumb("https://placehold.co/60x60"),
                  _themeThumb("https://placehold.co/60x60"),
                  _addThumb(),
                ],
              ),
              const SizedBox(height: 16),
              Text('Solid Colors',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF64748B))),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _colorCircle(Colors.blue),
                  _colorCircle(Colors.yellow),
                  _colorCircle(Colors.purple),
                  _colorCircle(Colors.orange),
                  _colorCircle(const Color(0xFF1E293B)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 3. Component Styling (Accent & Transparency)
  Widget _buildStylingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("COMPONENT STYLING"),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              _buildStylingRow(
                  "Accent Color", "Sky Blue", const Color(0xFF13EC80)),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Card Transparency",
                      style: GoogleFonts.inter(
                          fontSize: 14, color: const Color(0xFF334155))),
                  SizedBox(
                    width: 120,
                    child: Slider(
                      value: cardTransparency,
                      onChanged: (v) => setState(() => cardTransparency = v),
                      activeColor: const Color(0xFF13EC80),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  // 4. App Preferences (Dark Mode, Account)
  Widget _buildAppPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("APP PREFERENCES"),
        const SizedBox(height: 12),
        Container(
          decoration: _cardDecoration(),
          child: Column(
            children: [
              _buildPrefTile(
                  LucideIcons.moon, "Dark Mode", const Color(0x336366F1),
                  trailing: Switch(
                      value: isDarkMode,
                      activeColor: const Color(0xFF13EC80),
                      onChanged: (v) => setState(() => isDarkMode = v))),
              _buildPrefTile(LucideIcons.listChecks, "Habit Management",
                  const Color(0x3322C55E)),
              _buildPrefTile(
                  LucideIcons.user, "Account Details", const Color(0x333B82F6),
                  isLast: true),
            ],
          ),
        ),
      ],
    );
  }

  // 5. Monthly Wrapped Highlight
  Widget _buildHighlightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFF13EC80),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles, color: Colors.black, size: 16),
              const SizedBox(width: 8),
              Text('PERSONAL HIGHLIGHT',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Monthly Wrapped',
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
          Text('Check your search velocity for this month.',
              style: GoogleFonts.inter(fontSize: 14)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text('View My Insights',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.white24))),
        child: Text('Sign Out',
            style: GoogleFonts.inter(
                color: const Color(0xFFEF4444),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Helpers
  Widget _buildSectionTitle(String title, {bool showSeeAll = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF334155),
                letterSpacing: 1.2)),
        if (showSeeAll)
          Text('See all',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF13EC80))),
      ],
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
      color: Colors.white.withOpacity(0.7),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.3)));

  Widget _themeThumb(String url, {bool isSelected = false}) => Container(
        width: 75,
        height: 75,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: const Color(0xFF137FEC), width: 3)
                : null,
            image:
                DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)),
      );

  Widget _addThumb() => Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.add, color: Color(0xFF64748B)));

  Widget _colorCircle(Color color) => Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));

  Widget _buildStylingRow(String label, String valText, Color color) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF334155))),
          Row(children: [
            Text(valText,
                style: GoogleFonts.inter(
                    fontSize: 12, color: const Color(0xFF94A3B8))),
            const SizedBox(width: 8),
            Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2)))
          ]),
        ],
      );
  Widget _buildPrefTile(IconData icon, String title, Color bgColor,
      {Widget? trailing, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      // Perbaikan: Gunakan Border() bukan BorderSide langsung
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  // Perbaikan: Gunakan withValues untuk versi terbaru atau withOpacity
                  color: Colors.black.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: Colors.indigo),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          trailing ?? const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}
