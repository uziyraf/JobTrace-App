import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jobtracker/features/profile/login_screen.dart';
import 'package:jobtracker/ui/widgets/main_layout.dart';
import 'package:jobtracker/core/services/notification_service.dart';
import 'package:jobtracker/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi Notifikasi
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

      // 1. TEMA: Transparan agar gradient di builder terlihat
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),

      // 2. BUILDER: Lapisan Background Gradient Global
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
          child: child,
        );
      },

      // 3. HOME: Menggunakan AuthWrapper untuk proteksi halaman
      home: const AuthWrapper(),
    );
  }
}

// --- LOGIKA AUTH WRAPPER ---
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Memantau perubahan status login user
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Jika sedang loading ngecek status firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF13EC80)),
            ),
          );
        }

        // Jika user sudah login (ada data user)
        if (snapshot.hasData) {
          return const MainLayout();
        }

        // Jika user belum login
        return const LoginScreen();
      },
    );
  }
}
