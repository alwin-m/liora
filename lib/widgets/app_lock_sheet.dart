import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/security_service.dart';
import '../core/session_security_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Screens/Login_Screen.dart';
import 'package:flutter/foundation.dart';

class AppLockSheet extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const AppLockSheet({super.key, required this.onAuthenticated});

  @override
  State<AppLockSheet> createState() => _AppLockSheetState();
}

class _AppLockSheetState extends State<AppLockSheet> {
  final TextEditingController _pinController = TextEditingController();
  bool _isPinError = false;
  bool _isBiometricAvailable = false;
  int _failedAttempts = 0;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  Future<void> _initializeState() async {
    await _checkBiometrics();
    await _checkLockoutStatus();
  }

  Future<void> _checkLockoutStatus() async {
    final isLocked = await SessionSecurityService.isLockedOut();
    if (mounted) {
      setState(() => _isLocked = isLocked);
    }
  }

  Future<void> _checkBiometrics() async {
    final available = await SecurityService.canAuthenticate();
    final enabled = await SecurityService.isBiometricEnabled();
    if (mounted) {
      setState(() => _isBiometricAvailable = available && enabled);
      if (available && enabled && !_isLocked) {
        _triggerBiometrics();
      }
    }
  }

  Future<void> _triggerBiometrics() async {
    final success = await SecurityService.authenticateBiometrics(
      reason: "Please unlock Liora to continue.",
    );
    if (success) {
      _complete();
    }
  }

  void _onNumberPressed(String number) {
    if (_pinController.text.length < 4) {
      setState(() {
        _pinController.text += number;
        _isPinError = false;
      });

      if (_pinController.text.length == 4) {
        _verifyPIN();
      }
    }
  }

  void _onDelete() {
    if (_pinController.text.isNotEmpty) {
      setState(() {
        _pinController.text = _pinController.text.substring(
          0,
          _pinController.text.length - 1,
        );
        _isPinError = false;
      });
    }
  }

  Future<void> _verifyPIN() async {
    // Check if user is locked out
    final isLocked = await SessionSecurityService.isLockedOut();
    if (isLocked) {
      final remaining =
          await SessionSecurityService.getRemainingLockoutSeconds();
      final minutes = (remaining / 60).ceil();

      HapticFeedback.vibrate();
      setState(() => _isLocked = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Too many failed attempts. Try again in $minutes minute(s).",
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final isValid = await SecurityService.verifyPIN(_pinController.text);
    if (isValid) {
      // Clear failed attempts on success
      await SessionSecurityService.clearFailedAttempts();
      _complete();
    } else {
      // Record failed attempt
      final updatedFailures =
          await SessionSecurityService.recordFailedAttempt();
      final remaining = SessionSecurityService.maxAttempts - updatedFailures;

      HapticFeedback.vibrate();
      setState(() {
        _isPinError = true;
        _failedAttempts = updatedFailures;
        _pinController.clear();
      });

      // Show warning on last attempt
      if (remaining <= 0) {
        setState(() => _isLocked = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "🔒 Too many failed attempts. Account locked for 15 minutes.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else if (remaining <= 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("⚠️  $remaining attempt(s) remaining before lockout"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _complete() {
    HapticFeedback.mediumImpact();
    widget.onAuthenticated();
  }

  void _forgotPIN() async {
    // Show recovery dialog: email + password verification
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isLoading = false;
    bool obscurePassword = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFFDF6F9),
          title: const Text("Recovery - Verify Account"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "To reset your PIN, please verify your account with your login credentials.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: emailController,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "your@email.com",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  enabled: !isLoading,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setDialogState(
                        () => obscurePassword = !obscurePassword,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setDialogState(() => isLoading = true);

                      try {
                        // Verify credentials with Firebase
                        final email = emailController.text.trim();
                        final password = passwordController.text;

                        if (email.isEmpty || password.isEmpty) {
                          throw Exception("Email and password are required");
                        }

                        // Re-authenticate with email and password
                        final credential = EmailAuthProvider.credential(
                          email: email,
                          password: password,
                        );

                        await FirebaseAuth.instance.currentUser!
                            .reauthenticateWithCredential(credential);

                        // Credentials valid - clear old PIN and send user to security screen
                        await SecurityService.clearPIN();

                        if (mounted) {
                          Navigator.pop(context);

                          // Show success and ask to set new PIN
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "✓ Account verified! Please set a new PIN in Security Settings.",
                              ),
                              duration: Duration(seconds: 3),
                            ),
                          );

                          // Navigate to security screen after closing lock sheet
                          Future.delayed(const Duration(seconds: 1), () {
                            if (mounted) {
                              Navigator.pushNamed(context, '/security');
                            }
                          });
                        }
                      } on FirebaseAuthException catch (e) {
                        setDialogState(() => isLoading = false);

                        String errorMsg =
                            "Invalid credentials. Please try again.";
                        if (e.code == 'invalid-credential') {
                          errorMsg = "Email or password is incorrect.";
                        } else if (e.code == 'invalid-email') {
                          errorMsg = "Invalid email format.";
                        }

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(errorMsg)));
                      } catch (e) {
                        setDialogState(() => isLoading = false);

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE67598),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text("VERIFY", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.75, // Half screen or a bit more
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),

          Icon(
            _isLocked ? Icons.lock_clock_rounded : Icons.lock_person_rounded,
            size: 60,
            color: _isLocked ? Colors.red : const Color(0xFFE67598),
          ),
          const SizedBox(height: 16),
          Text(
            _isLocked ? "Account Locked" : "Liora Security",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          Text(
            _isLocked
                ? "Too many failed attempts"
                : "Protecting your private data",
            style: TextStyle(
              color: _isLocked ? Colors.red : Colors.grey,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 32),

          if (!_isLocked) ...[
            // PIN Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final filled = _pinController.text.length > index;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled
                        ? const Color(0xFFE67598)
                        : (_isPinError
                              ? Colors.red.shade100
                              : Colors.grey.shade200),
                    border: _isPinError && !filled
                        ? Border.all(color: Colors.red)
                        : null,
                  ),
                );
              }),
            ),

            if (_isPinError)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  "Incorrect PIN. Attempt ${_failedAttempts}/${SessionSecurityService.maxAttempts}",
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ] else ...[
            // Lockout Message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Please try again later",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "For security, your account is temporarily locked after multiple failed attempts.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<int>(
                    future: SessionSecurityService.getRemainingLockoutSeconds(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final remaining = snapshot.data ?? 0;
                        final minutes = (remaining / 60).ceil();
                        return Text(
                          "Locked for ${minutes > 0 ? '$minutes minute(s)' : '${remaining} second(s)'}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        );
                      }
                      return const SizedBox(
                        height: 20,
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],

          const Spacer(),

          if (!_isLocked) ...[
            // Custom Number Pad
            _buildNumPad(),

            const SizedBox(height: 24),

            TextButton(
              onPressed: _forgotPIN,
              child: Text(
                "FORGOT PIN? SIGN IN AGAIN",
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ] else ...[
            ElevatedButton(
              onPressed: _initializeState, // Refresh lockout status
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE67598),
              ),
              child: const Text(
                "CHECK STATUS",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNumPad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_numButton("1"), _numButton("2"), _numButton("3")],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_numButton("4"), _numButton("5"), _numButton("6")],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_numButton("7"), _numButton("8"), _numButton("9")],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _isBiometricAvailable
                ? IconButton(
                    icon: const Icon(
                      Icons.fingerprint_rounded,
                      size: 30,
                      color: Color(0xFFE67598),
                    ),
                    onPressed: _triggerBiometrics,
                  )
                : const SizedBox(width: 48),
            _numButton("0"),
            IconButton(
              icon: const Icon(
                Icons.backspace_outlined,
                size: 24,
                color: Colors.grey,
              ),
              onPressed: _onDelete,
            ),
          ],
        ),
      ],
    );
  }

  Widget _numButton(String num) {
    return InkWell(
      onTap: () => _onNumberPressed(num),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        child: Text(
          num,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
