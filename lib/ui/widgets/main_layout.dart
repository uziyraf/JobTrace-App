import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobtracker/features/job_tracker/job_screen.dart';
import 'package:jobtracker/features/job_tracker/list_application_screen.dart';
import 'package:jobtracker/features/profile/profile_screen.dart';
import 'package:jobtracker/features/job_tracker/list_schedule_screen.dart';
import 'package:jobtracker/features/wrapped/analytic_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;
  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    // Tarik nilai titipan tab ke dalam selectedIndex
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _pages = [
    const JobScreen(), // Index 0: Home (Dashboard yang baru kita buat)
    const ListApplicationScreen(), // Index 1: Placeholder
    const ListScheduleScreen(), // Index 2: SafeSpace
    const AnalyticScreen(), // Index 3: Placeholder
    const ProfileScreen(), // Index 4: Placeholder
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
