import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null || user.email == null) return;

        // Re-authenticate user
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: _oldPasswordController.text,
        );
        
        await user.reauthenticateWithCredential(cred);
        await user.updatePassword(_newPasswordController.text);
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password Updated ✓")));
           Navigator.pop(context);
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "An error occurred")));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      appBar: AppBar(
        title: const Text("Change Password", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Security Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text("Update your Liora primary account password", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 32),
              
              _buildPasswordField("Old Password", _oldPasswordController, _obscureOld, () => setState(() => _obscureOld = !_obscureOld)),
              const SizedBox(height: 24),
              _buildPasswordField("New Password", _newPasswordController, _obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
              const SizedBox(height: 16),
              _buildPasswordField("Confirm New Password", _confirmPasswordController, _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm), validator: (val) {
                 if (val != _newPasswordController.text) return "Passwords do not match";
                 return null;
              }),
              
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE67598),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("UPDATE PASSWORD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool obscure, VoidCallback onToggle, {String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator ?? (val) => (val == null || val.length < 6) ? "Enter at least 6 characters" : null,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFFE67598), size: 20),
            suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20), onPressed: onToggle),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
