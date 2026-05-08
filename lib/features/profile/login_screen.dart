import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jobtracker/features/job_tracker/job_screen.dart';
import 'package:jobtracker/features/profile/register_screen.dart';
import 'package:jobtracker/ui/widgets/main_layout.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    // ... (Fungsi login tetap sama seperti sebelumnya, biarkan utuh)
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    bool isValid = true;
    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = "Email tidak boleh kosong");
      isValid = false;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = "Password tidak boleh kosong");
      isValid = false;
    }

    if (!isValid) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const JobScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found' ||
            e.code == 'invalid-email' ||
            e.code == 'invalid-credential') {
          _emailError = "Email atau password salah";
        } else if (e.code == 'wrong-password') {
          _passwordError = "Password salah";
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error: ${e.message}'),
              backgroundColor: Colors.red));
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    // ... (Fungsi google tetap sama seperti sebelumnya)
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login Google Gagal: $e'),
          backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil tinggi layar HP biar bisa diukur pas
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Form gak akan kedorong ke atas pas keyboard muncul
      body: SafeArea(
        child: Stack(
          children: [
            // --- 1. GAMBAR GIF DI BELAKANG ---
            Positioned(
              top: -10,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/image/login.gif',
                width: double.infinity,
                // Gambar dibikin responsif ngikutin layar (35% dari tinggi layar)
                height: screenHeight * 0.35,
                fit: BoxFit.contain,
              ),
            ),

            // --- 2. KOTAK FORM FIXED DI BAWAH ---
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Container(
                  // Spasi dalam kotak dikurangin dikit dari 32 jadi 24 biar muat
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.30)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 50,
                        offset: Offset(0, 25),
                        spreadRadius: -12,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Bungkus konten pas-pasan
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text('Welcome JobTrace',
                                style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                    letterSpacing: -0.60)),
                            const SizedBox(height: 4), // Spasi dipotong
                            Text('Track your career journey',
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF475569))),
                          ],
                        ),
                      ),

                      const SizedBox(
                          height: 20), // Spasi dipotong dari 32 ke 20

                      // Form Email
                      Text('EMAIL ADDRESS',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF334155),
                              letterSpacing: 0.6)),
                      const SizedBox(height: 6),
                      SizedBox(
                        // Bungkus pake SizedBox biar TextField gak kegedean
                        height: 48,
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'name@company.com',
                            hintStyle: GoogleFonts.inter(
                                color: const Color(0xFF94A3B8), fontSize: 14),
                            errorText: _emailError,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE2E8F0))),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE2E8F0))),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Form Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('PASSWORD',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF334155),
                                  letterSpacing: 0.6)),
                          Text('Forgot?',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0E3253))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 48,
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: '••••••••',
                            hintStyle: GoogleFonts.inter(
                                color: const Color(0xFF94A3B8), fontSize: 14),
                            errorText: _passwordError,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE2E8F0))),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE2E8F0))),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _obscurePassword
                                      ? LucideIcons.eye
                                      : LucideIcons.eyeOff,
                                  color: const Color(0xFF94A3B8),
                                  size: 18),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Tombol Login
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0E3253),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text('Login',
                                  style: GoogleFonts.inter(
                                      color: const Color(0xFF102219),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                        ),
                      ),

                      const SizedBox(height: 16), // Spasi dipotong

                      // Garis OR
                      Row(
                        children: [
                          const Expanded(
                              child: Divider(color: Color(0x7FCBD5E1))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('OR',
                                style: GoogleFonts.inter(
                                    color: const Color(0xFF64748B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                          ),
                          const Expanded(
                              child: Divider(color: Color(0x7FCBD5E1))),
                        ],
                      ),

                      const SizedBox(height: 16), // Spasi dipotong

                      // Tombol Google (Dibalikin ke tinggi normal 48)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _signInWithGoogle,
                          icon: Image.asset('assets/image/google.jpg',
                              height: 20),
                          label: Text('Sign in with Google',
                              style: GoogleFonts.inter(
                                  color: const Color(0xFF334155),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Teks Sign Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ",
                              style: GoogleFonts.inter(
                                  color: const Color(0xFF475569),
                                  fontSize: 12)),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen())),
                            child: Text('Sign up',
                                style: GoogleFonts.inter(
                                    color: const Color(0xFF0E3253),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
