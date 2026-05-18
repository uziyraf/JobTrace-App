import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Isi otomatis form dengan data user yang lagi login
    if (currentUser != null) {
      _nameController.text = currentUser!.displayName ?? '';
      _emailController.text = currentUser!.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      if (_nameController.text.trim().isNotEmpty &&
          _nameController.text.trim() != currentUser?.displayName) {
        await currentUser?.updateDisplayName(_nameController.text.trim());
      }

      if (_emailController.text.trim().isNotEmpty &&
          _emailController.text.trim() != currentUser?.email) {
        await currentUser
            ?.verifyBeforeUpdateEmail(_emailController.text.trim());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Verification link sent to your new email.'),
                backgroundColor: Color(0xFF10B981)),
          );
        }
      }

      if (_passwordController.text.isNotEmpty) {
        await currentUser?.updatePassword(_passwordController.text);
      }

      await currentUser?.reload();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account details updated successfully! 🎉'),
            backgroundColor: Color(0xFF0EB562),
          ),
        );
        Navigator.pop(context, true);
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = e.message ?? 'An error occurred';
      if (e.code == 'requires-recent-login') {
        errorMsg =
            'For security, please log out and log in again to change these details.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Account Details',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: const Color(0xFF0F172A)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField("Full Name", LucideIcons.user, _nameController),
            const SizedBox(height: 20),
            _buildInputField(
                "Email Address", LucideIcons.mail, _emailController),
            const SizedBox(height: 20),

            // Password Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("New Password (Optional)",
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF334155))),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Leave blank to keep current",
                    prefixIcon: const Icon(LucideIcons.lock,
                        size: 20, color: Color(0xFF94A3B8)),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscurePassword
                              ? LucideIcons.eye
                              : LucideIcons.eyeOff,
                          size: 18,
                          color: const Color(0xFF94A3B8)),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Tombol Save
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E3253),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text('Save Changes',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: Text(
                "Note: If you signed in with Google, changing your password here might not work unless you have linked an email/password to this account.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 12, color: const Color(0xFF94A3B8)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
      String label, IconData icon, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF334155))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
      ],
    );
  }
}
