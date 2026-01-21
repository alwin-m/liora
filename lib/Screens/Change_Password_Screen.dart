import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> changePassword() async {
    if (newPasswordController.text !=
        confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Update Password',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: oldPasswordController,
              obscureText: _obscureOldPassword,
              decoration: InputDecoration(
                labelText: "Old password",
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureOldPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureOldPassword = !_obscureOldPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: newPasswordController,
              obscureText: _obscureNewPassword,
              decoration: InputDecoration(
                labelText: "New password",
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: "Confirm new password",
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : changePassword,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
