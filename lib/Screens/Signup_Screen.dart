import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lioraa/Screens/Login_Screen.dart';
import 'package:lioraa/Screens/verify_email_screen.dart';

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
      setState(() {
        strengthText = "";
      });
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
      strengthColor = Colors.green;
    }

    setState(() {});
  }

  Future<void> signup() async {
    if (passwordController.text !=
        confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Passwords do not match")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      UserCredential userCred =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 🔥 Send verification email
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
        MaterialPageRoute(
          builder: (_) => const VerifyEmailScreen(),
        ),
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
    if (confirmPasswordController.text.isEmpty) {
      return const SizedBox();
    }

    bool match =
        passwordController.text ==
            confirmPasswordController.text;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1,
      child: Row(
        children: [
          Icon(
            match ? Icons.check_circle : Icons.cancel,
            color: match ? Colors.green : Colors.red,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            match
                ? "Passwords match"
                : "Passwords do not match",
            style: TextStyle(
              fontSize: 12,
              color: match ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 247, 211, 228),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'Liora',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Care for your rhythm',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12
                          .withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _inputField(
                      controller: nameController,
                      label: "Name",
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _inputField(
                      controller: emailController,
                      label: "Email",
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),

                    // PASSWORD
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(
                            Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              obscurePassword =
                                  !obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  16),
                        ),
                      ),
                    ),

                    if (strengthText.isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                                top: 6),
                        child: Align(
                          alignment:
                              Alignment.centerLeft,
                          child: Text(
                            "Strength: $strengthText",
                            style: TextStyle(
                              fontSize: 12,
                              color: strengthColor,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // CONFIRM PASSWORD
                    TextField(
                      controller:
                          confirmPasswordController,
                      obscureText:
                          obscureConfirmPassword,
                      onChanged: (_) =>
                          setState(() {}),
                      decoration: InputDecoration(
                        labelText:
                            "Confirm Password",
                        prefixIcon: const Icon(
                            Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                              obscureConfirmPassword
                                  ? Icons
                                      .visibility_off
                                  : Icons
                                      .visibility),
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword =
                                  !obscureConfirmPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),
                    _passwordMatchIndicator(),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            isLoading ? null : signup,
                        style: ElevatedButton
                            .styleFrom(
                          backgroundColor:
                              const Color(
                                  0xFFE67598),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color:
                                    Colors.white,
                              )
                            : Text(
                                'Create Account',
                                style: GoogleFonts
                                    .poppins(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight
                                          .w500,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style:
                              GoogleFonts.poppins(
                                  fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Login",
                            style: GoogleFonts
                                .poppins(
                              fontSize: 13,
                              fontWeight:
                                  FontWeight
                                      .w600,
                              color:
                                  const Color(
                                      0xFFE67598),
                              decoration:
                                  TextDecoration
                                      .underline,
                            ),
                          ),
                        ),
                      ],
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

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),
      ),
    );
  }
}