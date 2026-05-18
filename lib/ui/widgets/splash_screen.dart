import 'package:flutter/material.dart';
import 'package:jobtracker/features/profile/auth_gate.dart';

class SplashScreenFlutter extends StatefulWidget {
  const SplashScreenFlutter({super.key});

  @override
  State<SplashScreenFlutter> createState() => _SplashScreenFlutterState();
}

class _SplashScreenFlutterState extends State<SplashScreenFlutter> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthGate()),
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
            Image.asset(
              'assets/image/splash.gif',
              width: 190,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
