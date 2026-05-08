import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Import halaman lu
import 'package:jobtracker/features/job_tracker/job_screen.dart';
import 'package:jobtracker/features/job_tracker/list_application_screen.dart';
import 'package:jobtracker/features/profile/profile_screen.dart';
import 'package:jobtracker/features/job_tracker/list_schedule_screen.dart';
import 'package:jobtracker/features/wrapped/analytic_screen.dart';
import 'package:jobtracker/features/job_tracker/add_application_screen.dart';

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
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _pages = [
    const JobScreen(),
    const ListApplicationScreen(),
    const ListScheduleScreen(),
    const AnalyticScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      floatingActionButton: null,
      bottomNavigationBar: SizedBox(
        height: 100,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 100),
              painter: NavbarPainter(isBumped: _selectedIndex == 1),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 60,
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: const Color(0xFF0E3253),
                  unselectedItemColor: const Color(0xFF9CA3AF),
                  selectedLabelStyle: GoogleFonts.poppins(
                      fontSize: 10, fontWeight: FontWeight.w500),
                  unselectedLabelStyle: GoogleFonts.poppins(
                      fontSize: 10, fontWeight: FontWeight.w500),
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                  items: const [
                    BottomNavigationBarItem(
                        icon: Icon(LucideIcons.home), label: 'Home'),
                    BottomNavigationBarItem(
                        icon: Icon(LucideIcons.briefcase), label: 'Jobs'),
                    BottomNavigationBarItem(
                        icon: Icon(LucideIcons.calendarDays),
                        label: 'Interviews'),
                    BottomNavigationBarItem(
                        icon: Icon(LucideIcons.lineChart), label: 'Analytic'),
                    BottomNavigationBarItem(
                        icon: Icon(LucideIcons.user), label: 'Profile'),
                  ],
                ),
              ),
            ),
            if (_selectedIndex == 1)
              Positioned(
                top: -10,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddApplicationScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.plus,
                        color: Color(0xFF0E3253), size: 34),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NavbarPainter extends CustomPainter {
  final bool isBumped;

  NavbarPainter({required this.isBumped});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();
    double w = size.width;
    double h = size.height;

    double bumpHeight = 40.0;
    double baseTop = bumpHeight;
    double radius = 24.0;
    path.moveTo(0, baseTop + radius);
    path.quadraticBezierTo(0, baseTop, radius, baseTop);

    if (isBumped) {
      double center = w / 2;
      double bumpRadius = 38.0;

      path.lineTo(center - bumpRadius - 15, baseTop);

      // Kurva naik
      path.cubicTo(
        center - bumpRadius + 5, baseTop,
        center - 20, 0, // Titik tertinggi di Y = 0
        center, 0,
      );

      // Kurva turun
      path.cubicTo(
        center + 15,
        0,
        center + bumpRadius - 5,
        baseTop,
        center + bumpRadius + 15,
        baseTop,
      );
    }

    // 3. Lanjut ke kanan atas
    path.lineTo(w - radius, baseTop);
    path.quadraticBezierTo(w, baseTop, w, baseTop + radius);

    // 4. Lanjut ke bawah
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    // Gambar shadow & background
    canvas.drawShadow(path, const Color(0x1A000000), 10, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
