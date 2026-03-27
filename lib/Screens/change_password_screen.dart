import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool hideOld = true;
  bool hideNew = true;
  bool hideConfirm = true;

  final Color primaryPink = const Color(0xFFE67598);

  // ================= CHANGE PASSWORD =================

  Future<void> changePassword() async {
    if (newPasswordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      _showSnack("Passwords do not match");
      return;
    }

    if (newPasswordController.text.length < 6) {
      _showSnack("Password must be at least 6 characters");
      return;
    }

    try {
      setState(() => isLoading = true);

      final user = FirebaseAuth.instance.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPasswordController.text.trim());

      _showSnack("Password updated successfully ✅");

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? "Something went wrong");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= FORGOT PASSWORD =================

  Future<void> sendResetEmail() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      _showSnack("No email found");
      return;
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: user.email!);

      _showSnack("Reset link sent to ${user.email}");
    } catch (e) {
      _showSnack("Failed to send reset email");
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: primaryPink,
        content: Text(message),
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [

              const SizedBox(height: 20),

              const Text(
                "Change Password",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE67598),
                ),
              ),

              const SizedBox(height: 30),

              _glassCard(
                child: Column(
                  children: [

                    _passwordField(
                      controller: oldPasswordController,
                      label: "Current Password",
                      hidden: hideOld,
                      toggle: () =>
                          setState(() => hideOld = !hideOld),
                    ),

                    const SizedBox(height: 18),

                    _passwordField(
                      controller: newPasswordController,
                      label: "New Password",
                      hidden: hideNew,
                      toggle: () =>
                          setState(() => hideNew = !hideNew),
                    ),

                    const SizedBox(height: 18),

                    _passwordField(
                      controller: confirmPasswordController,
                      label: "Confirm New Password",
                      hidden: hideConfirm,
                      toggle: () =>
                          setState(() => hideConfirm = !hideConfirm),
                    ),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: sendResetEmail,
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: primaryPink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPink,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                        onPressed:
                            isLoading ? null : changePassword,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Update Password",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
      ),
    );
  }

  // ================= GLASS CARD =================

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black12,
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // ================= PASSWORD FIELD =================

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool hidden,
    required VoidCallback toggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: hidden,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            hidden
                ? Icons.visibility_off
                : Icons.visibility,
            color: primaryPink,
          ),
          onPressed: toggle,
        ),
      ),
    );
  }
}