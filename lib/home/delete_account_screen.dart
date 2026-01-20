import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  bool agreedToDelete = false;
  final TextEditingController _passwordController = TextEditingController();
  String? errorMessage;
  bool _showPassword = false;

  /// Show confirmation dialog
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDFCF8),
        title: const Text(
          'Delete Account',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Are you absolutely sure? This action cannot be undone. All your data, including cycle history, will be permanently deleted.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6F6152),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFE74C3C)),
            ),
          ),
        ],
      ),
    );
  }

  /// Delete user account and all associated data
  Future<void> _deleteAccount() async {
    if (_passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your password to confirm deletion';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email ?? '',
        password: _passwordController.text,
      );

      await user.reauthenticateWithCredential(credential);

      // Delete Firestore data
      try {
        // Delete user document
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete user settings sub-collection
        final settingsDocs = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('settings')
            .get();
        for (var doc in settingsDocs.docs) {
          await doc.reference.delete();
        }

        // Delete cart sub-collection
        final cartDocs = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .get();
        for (var doc in cartDocs.docs) {
          await doc.reference.delete();
        }

        // Delete cycle history sub-collection
        final historyDocs = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cycleHistory')
            .get();
        for (var doc in historyDocs.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        print('Firestore deletion warning: $e');
        // Continue even if Firestore deletion has issues
      }

      // Delete Firebase Auth account
      await user.delete();

      if (mounted) {
        // Navigate to login screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFFE67598),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = _getAuthErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error deleting account: $e';
      });
    }
  }

  /// Get user-friendly error message
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-mismatch':
        return 'Password does not match this account.';
      case 'operation-not-allowed':
        return 'Account deletion is currently disabled.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFCF8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Delete Account',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE74C3C),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_outlined,
                    color: Color(0xFFE74C3C),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'This action cannot be undone',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE74C3C),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'All your data will be permanently deleted',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6F6152),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // What gets deleted section
            const Text(
              'What will be deleted:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _DeletionItem(
              icon: Icons.calendar_month_outlined,
              title: 'Cycle history',
              subtitle: 'All your period tracking data',
            ),
            _DeletionItem(
              icon: Icons.shopping_bag_outlined,
              title: 'Shopping cart',
              subtitle: 'Your saved cart items',
            ),
            _DeletionItem(
              icon: Icons.settings_outlined,
              title: 'Settings & preferences',
              subtitle: 'Notification preferences and personal settings',
            ),
            _DeletionItem(
              icon: Icons.account_circle_outlined,
              title: 'Account',
              subtitle: 'Your email and account information',
            ),

            const SizedBox(height: 32),

            // Password confirmation
            const Text(
              'Confirm with your password:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: !_showPassword,
              enabled: !isLoading,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE8E0D5),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE67598),
                    width: 1,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF6F6152),
                  ),
                  onPressed: () {
                    setState(() => _showPassword = !_showPassword);
                  },
                ),
              ),
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 16),

            // Error message
            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECEC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE74C3C),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFE74C3C),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFE74C3C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Checkbox agreement
            Row(
              children: [
                Checkbox(
                  value: agreedToDelete,
                  onChanged: isLoading
                      ? null
                      : (value) {
                          setState(() => agreedToDelete = value ?? false);
                        },
                  activeColor: const Color(0xFFE67598),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: isLoading
                        ? null
                        : () {
                            setState(() => agreedToDelete = !agreedToDelete);
                          },
                    child: const Text(
                      'I understand that this will permanently delete my account and all associated data',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6F6152),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Delete button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: !agreedToDelete || isLoading
                    ? null
                    : _showConfirmationDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE74C3C),
                  disabledBackgroundColor:
                      const Color(0xFFE74C3C).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Delete My Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white.withOpacity(0.5),
                  side: const BorderSide(
                    color: Color(0xFFE8E0D5),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Keep My Account',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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

/// Deletion item widget
class _DeletionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _DeletionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFE67598),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6F6152),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
