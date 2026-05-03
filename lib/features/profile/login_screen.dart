import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jobtracker/features/profile/register_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:jobtracker/features/habits/habbit_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variabel untuk pesan error di bawah form
  String? _emailError;
  String? _passwordError;

  bool _isLoading = false;
  bool _obscurePassword = true;

  // --- FUNGSI LOGIN EMAIL & PASSWORD ---
  Future<void> _login() async {
    // Reset error tiap kali tombol ditekan
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // Validasi lokal (kosong atau tidak)
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
          MaterialPageRoute(builder: (context) => const HabitScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found' ||
            e.code == 'invalid-email' ||
            e.code == 'invalid-credential') {
          _emailError = "Email tidak terdaftar atau kredensial salah";
        } else if (e.code == 'wrong-password') {
          _passwordError = "Password salah";
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Terjadi kesalahan: ${e.message}'),
                backgroundColor: Colors.red),
          );
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- FUNGSI LOGIN GOOGLE ---
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      // 1. Trigger proses login Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User membatalkan proses login (tutup popup)
        setState(() => _isLoading = false);
        return;
      }

      // 2. Ambil detail autentikasi
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Buat kredensial untuk Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in ke Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);

      // 5. Arahkan ke halaman utama jika sukses
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HabitScreen()),
        );
      }
    } catch (e) {
      print("Error Google Login: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login Google Gagal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Logo Container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF13EC80).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.briefcase,
                    color: Color(0xFF13EC80), size: 32),
              ),
              const SizedBox(height: 24),
              Text('Welcome Back',
                  style: GoogleFonts.manrope(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A))),
              const SizedBox(height: 8),
              Text('Sign in to continue tracking your progress.',
                  style: GoogleFonts.inter(
                      fontSize: 16, color: const Color(0xFF64748B))),
              const SizedBox(height: 48),

              // Form Email
              Text('EMAIL ADDRESS',
                  style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF64748B),
                      letterSpacing: 1.2)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'you@example.com',
                  errorText:
                      _emailError, // Muncul pesan error merah di bawah garis jika kosong/salah
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  prefixIcon:
                      const Icon(LucideIcons.mail, color: Color(0xFF94A3B8)),
                ),
              ),
              const SizedBox(height: 24),

              // Form Password
              Text('PASSWORD',
                  style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF64748B),
                      letterSpacing: 1.2)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: '••••••••',
                  errorText: _passwordError,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  prefixIcon:
                      const Icon(LucideIcons.lock, color: Color(0xFF94A3B8)),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                        color: const Color(0xFF94A3B8)),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Login Button (Email & Pass)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005DB5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text('SIGN IN',
                          style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2)),
                ),
              ),

              const SizedBox(height: 16),

              // Google Sign In Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: const Icon(LucideIcons.chrome,
                      color: Colors.red, size: 24),
                  label: Text('Sign in with Google',
                      style: GoogleFonts.manrope(
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ",
                      style: GoogleFonts.inter(color: const Color(0xFF64748B))),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()));
                    },
                    child: Text('Sign Up',
                        style: GoogleFonts.inter(
                            color: const Color(0xFF13EC80),
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
