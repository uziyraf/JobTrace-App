import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobtracker/features/job_tracker/job_screen.dart';
import 'package:jobtracker/features/job_tracker/list_application_screen.dart';
import 'package:jobtracker/features/profile/profile_screen.dart';
import 'package:jobtracker/features/job_tracker/list_schedule_screen.dart';
import 'package:jobtracker/features/wrapped/analytic_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // Variabel untuk menyimpan indeks menu yang sedang aktif (0 = Home)
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan sesuai urutan Navbar
  final List<Widget> _pages = [
    const JobScreen(), // Index 0: Home (Dashboard yang baru kita buat)
    const ListApplicationScreen(), // Index 1: Placeholder
    const ListScheduleScreen(), // Index 2: SafeSpace
    const AnalyticScreen(), // Index 3: Placeholder
    const ProfileScreen(), // Index 4: Placeholder
  ];

  // Fungsi yang dipanggil saat tombol navbar diklik
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan menampilkan halaman sesuai index yang dipilih
      body: _pages[_selectedIndex],

      // Navbar HANYA ADA DI SINI, tidak perlu ditaruh di job_screen.dart lagi
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF13EC80), // Hijau khas Figma-mu
        unselectedItemColor: const Color(0xFF9CA3AF),
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        currentIndex: _selectedIndex, // Memberi tahu tab mana yang aktif
        onTap: _onItemTapped, // Jalankan fungsi saat diklik
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.briefcase),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
              icon: Icon(LucideIcons.calendarDays), label: 'Interviews'),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.lineChart),
            label: 'Analytic',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
