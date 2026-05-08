import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobtracker/features/profile/login_screen.dart';

class SplashScreenFlutter extends StatefulWidget {
  const SplashScreenFlutter({super.key});

  @override
  State<SplashScreenFlutter> createState() => _SplashScreenFlutterState();
}

class _SplashScreenFlutterState extends State<SplashScreenFlutter> {
  @override
  void initState() {
    super.initState();
    // 1. SETTING WAKTU PUTAR GIF:
    // Contoh, GIF bakal muter selama 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // 2. NAVIGASI OTOMATIS:
        // Setelah 3 detik, otomatis pindah ke halaman Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- INI KODINGAN UNTUK MEMUTAR GIF ---
            // Pake Image.asset() biasa untuk dicolok GIF-nya
            Image.asset(
              'assets/image/splash.gif', // Pastikan filenya beneran ada di folder assets lu
              width: 190, // Sesuaiin ukuran GIF lu
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
