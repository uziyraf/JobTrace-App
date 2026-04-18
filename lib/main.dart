import 'package:flutter/material.dart';
import 'package:jobtracker/ui/widgets/main_layout.dart';
import 'core/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Tracker',
      debugShowCheckedModeBanner: false,

      // 1. UBAH TEMA DI SINI: Bikin semua layar jadi tembus pandang (transparan)
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent, // Kunci utamanya!
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),

      // 2. TAMBAH BUILDER DI SINI: Taruh kanvas gradient di lapisan paling bawah aplikasi
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                Color(0xFFF3F6EA), // Krem bawah
                Color(0xFFB5DFD1), // Mint tengah
                Color(0xFF8DCAC0), // Hijau mint kanan atas
              ],
            ),
          ),
          child: child, // Ini akan nampilin MainLayout dan isinya
        );
      },

      home: const MainLayout(),
    );
  }
}
