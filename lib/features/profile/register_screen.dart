import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jobtracker/features/job_tracker/job_screen.dart';
import 'package:jobtracker/ui/widgets/main_layout.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  String? _nameError;
  String? _emailError;
  String? _passwordError;

  Future<void> _register() async {
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
    });

    bool isValid = true;
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = "Nama lengkap wajib diisi");
      isValid = false;
    }
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
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await userCredential.user?.updateDisplayName(_nameController.text.trim());
      await userCredential.user?.reload();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
          (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          _emailError = "Email ini sudah terdaftar";
        } else if (e.code == 'weak-password') {
          _passwordError = "Password terlalu lemah";
        } else if (e.code == 'invalid-email') {
          _emailError = "Format email salah";
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

  Future<void> _signUpWithGoogle() async {
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
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user != null &&
          (user.displayName == null || user.displayName!.isEmpty)) {
        await user.updateDisplayName(googleUser.displayName);
        await user.reload();
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal daftar dengan Google: $e'),
          backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 150,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/image/login.gif'),
                            fit: BoxFit.contain,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: IconButton(
                          icon: const Icon(LucideIcons.arrowLeft,
                              color: Color(0xFF0F172A)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(),
                        Positioned(
                          top: -20,
                          left: 24,
                          right: 24,
                          bottom: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.20)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x19000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                )
                              ],
                            ),
                            // SOLUSINYA DI SINI: Bungkus form dengan SingleChildScrollView
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Column(
                                      children: [
                                        Text('Create Account',
                                            style: GoogleFonts.inter(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF0F172A),
                                                letterSpacing: -0.60)),
                                        const SizedBox(height: 2),
                                        Text('Join us to track your journey',
                                            style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    const Color(0xFF475569))),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  Text('FULL NAME',
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF334155),
                                          letterSpacing: 0.6)),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    height: 44,
                                    child: TextField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        hintText: 'e.g. Your Name',
                                        hintStyle: GoogleFonts.inter(
                                            color: const Color(0xFF94A3B8),
                                            fontSize: 14),
                                        errorText: _nameError,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFE2E8F0))),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFE2E8F0))),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  Text('EMAIL ADDRESS',
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF334155),
                                          letterSpacing: 0.6)),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    height: 44,
                                    child: TextField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        hintText: 'youremail@address.com',
                                        hintStyle: GoogleFonts.inter(
                                            color: const Color(0xFF94A3B8),
                                            fontSize: 14),
                                        errorText: _emailError,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFE2E8F0))),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFE2E8F0))),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Form Password
                                  Text('PASSWORD',
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF334155),
                                          letterSpacing: 0.6)),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    height: 44,
                                    child: TextField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        hintText: '••••••••',
                                        hintStyle: GoogleFonts.inter(
                                            color: const Color(0xFF94A3B8),
                                            fontSize: 14),
                                        errorText: _passwordError,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFE2E8F0))),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFE2E8F0))),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                              _obscurePassword
                                                  ? LucideIcons.eye
                                                  : LucideIcons.eyeOff,
                                              color: const Color(0xFF94A3B8),
                                              size: 18),
                                          onPressed: () => setState(() =>
                                              _obscurePassword =
                                                  !_obscurePassword),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Tombol Sign Up
                                  SizedBox(
                                    width: double.infinity,
                                    height: 44,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _register,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF0E3253),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        elevation: 0,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2))
                                          : Text('Sign Up',
                                              style: GoogleFonts.inter(
                                                  color:
                                                      const Color(0xFF102219),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700)),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Garis OR
                                  Row(
                                    children: [
                                      const Expanded(
                                          child: Divider(
                                              color: Color(0x7FCBD5E1))),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Text('OR',
                                            style: GoogleFonts.inter(
                                                color: const Color(0xFF64748B),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                      const Expanded(
                                          child: Divider(
                                              color: Color(0x7FCBD5E1))),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // Tombol Google
                                  SizedBox(
                                    width: double.infinity,
                                    height: 44,
                                    child: OutlinedButton.icon(
                                      onPressed:
                                          _isLoading ? null : _signUpWithGoogle,
                                      icon: Image.asset(
                                          'assets/image/google.jpg',
                                          height: 18),
                                      label: Text('Sign up with Google',
                                          style: GoogleFonts.inter(
                                              color: const Color(0xFF334155),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600)),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        side: const BorderSide(
                                            color: Color(0xFFE2E8F0)),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Teks Login
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Already have an account? ",
                                          style: GoogleFonts.inter(
                                              color: const Color(0xFF475569),
                                              fontSize: 12)),
                                      GestureDetector(
                                        onTap: () => Navigator.pop(context),
                                        child: Text('Login',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
