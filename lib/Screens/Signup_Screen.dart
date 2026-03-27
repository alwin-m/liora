import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lioraa/Screens/Login_Screen.dart';
import 'package:lioraa/Screens/verify_email_screen.dart';
import '../core/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  String strengthText = "";
  Color strengthColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(checkPasswordStrength);
  }

  void checkPasswordStrength() {
    final password = passwordController.text;

    if (password.isEmpty) {
      setState(() => strengthText = "");
      return;
    }

    if (password.length < 6) {
      strengthText = "Weak";
      strengthColor = Colors.red;
    } else if (password.length < 8) {
      strengthText = "Medium";
      strengthColor = Colors.orange;
    } else {
      strengthText = "Strong";
      strengthColor = const Color(0xFF4CAF50);
    }

    setState(() {});
  }

  Future<void> signup() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      UserCredential userCred =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await userCred.user!.sendEmailVerification();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'createdAt': Timestamp.now(),
        'role': 'user',
        'profileCompleted': false,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Error")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _passwordMatchIndicator() {
    if (confirmPasswordController.text.isEmpty) return const SizedBox();

    bool match = passwordController.text == confirmPasswordController.text;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(
            match ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: match ? const Color(0xFF4CAF50) : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            match ? "Passwords match" : "Passwords do not match",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: match ? const Color(0xFF4CAF50) : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [LioraColors.bgDark, LioraColors.surfaceDark]
                : [const Color(0xFFFFF0F3), LioraColors.bgLight],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                // ── Logo ────────────────────────────────────
                Hero(
                  tag: 'liora_logo',
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: LioraColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: LioraColors.primary.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icon/app_icon1.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Liora',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: LioraColors.primary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Care for your rhythm',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: LioraColors.textMuted,
                  ),
                ),

                const SizedBox(height: 28),

                // ── Form Card ────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark
                        ? LioraColors.surfaceDark
                        : LioraColors.surfaceLight,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: LioraColors.primary
                            .withOpacity(isDark ? 0.1 : 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                    border: Border.all(
                      color: LioraColors.primary.withOpacity(0.12),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Account',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : LioraColors.catBlack,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "Join Liora and track with care 🐱",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: LioraColors.textMuted,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Name
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: "Full Name",
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Email
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: "Email",
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Password
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          hintText: "Password",
                          prefixIcon:
                              const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(
                                () => obscurePassword = !obscurePassword),
                          ),
                        ),
                      ),

                      // Strength indicator
                      if (strengthText.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: strengthColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Strength: $strengthText",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: strengthColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 14),

                      // Confirm password
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirmPassword,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: "Confirm Password",
                          prefixIcon:
                              const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(() =>
                                obscureConfirmPassword =
                                    !obscureConfirmPassword),
                          ),
                        ),
                      ),

                      _passwordMatchIndicator(),

                      const SizedBox(height: 24),

                      // Create account button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : signup,
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Create Account'),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: LioraColors.textMuted,
                              ),
                              children: [
                                const TextSpan(
                                    text: "Already have an account? "),
                                TextSpan(
                                  text: "Login",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: LioraColors.primary,
                                  ),
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
        ),
      ),
    );
  }
}