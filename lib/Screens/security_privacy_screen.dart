import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/security_service.dart';
import '../core/app_settings.dart';

class SecurityPrivacyScreen extends StatefulWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  State<SecurityPrivacyScreen> createState() => _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends State<SecurityPrivacyScreen> {
  bool _isAppLockEnabled = false;
  bool _isPINSet = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSecurityStatus();
  }

  Future<void> _loadSecurityStatus() async {
    final enabled = await AppSettings.getAppLock();
    final pinSet = await SecurityService.hasPIN();
    if (mounted) {
      setState(() {
        _isAppLockEnabled = enabled;
        _isPINSet = pinSet;
        _isLoading = false;
      });
    }
  }

  void _toggleAppLock(bool value) async {
    if (value) {
      // If enabling, but no PIN, must set PIN first
      if (!_isPINSet) {
        _showSetPINDialog();
        return;
      }
      
      // Verify bio if enabled
      final canAuth = await SecurityService.canAuthenticate();
      if (canAuth) {
        final didAuth = await SecurityService.authenticateBiometrics(reason: "Secure Liora with biometrics");
        if (!didAuth) return;
      }
    }

    await AppSettings.saveAppLock(value);
    setState(() => _isAppLockEnabled = value);
  }

  void _showSetPINDialog() {
    final controller = TextEditingController();
    final confirmController = TextEditingController();
    bool isConfirmStage = false;
    String firstPIN = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: Column(
            children: [
              const Icon(Icons.lock_outline_rounded, size: 48, color: Color(0xFFE67598)),
              const SizedBox(height: 16),
              Text(isConfirmStage ? "Confirm Your PIN" : "Create Security PIN", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text("Enter a 4-digit PIN for app security", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 40),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = (isConfirmStage ? confirmController : controller).text.length > i;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? const Color(0xFFE67598) : Colors.grey.shade200,
                    ),
                  );
                }),
              ),
              
              const Spacer(),
              
              _buildPinPad(isConfirmStage ? confirmController : controller, (val) async {
                 if (val.length == 4) {
                    if (!isConfirmStage) {
                       setModalState(() {
                          firstPIN = val;
                          isConfirmStage = true;
                       });
                    } else {
                       if (val == firstPIN) {
                          await SecurityService.setPIN(val);
                          if (mounted) {
                             Navigator.pop(context);
                             _loadSecurityStatus();
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Security PIN successfully set ✓")));
                          }
                       } else {
                          HapticFeedback.vibrate();
                          setModalState(() {
                             confirmController.clear();
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PINs do not match. Try again.")));
                          });
                       }
                    }
                 }
                 setModalState(() {});
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      appBar: AppBar(
        title: const Text("Security & Privacy", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text("APP PROTECTION", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 2)),
          const SizedBox(height: 16),
          _buildSettingsTile(
            Icons.phonelink_lock_rounded, 
            "Device App Lock", 
            "Required PIN or Fingerprint to open Liora",
            trailing: Switch.adaptive(
              value: _isAppLockEnabled,
              activeColor: const Color(0xFFE67598),
              onChanged: _toggleAppLock,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            Icons.pin_rounded, 
            "Change Security PIN", 
            _isPINSet ? "Currently active" : "Not configured",
            onTap: _showSetPINDialog,
          ),
          
          const SizedBox(height: 40),
          const Text("DATA PRIVACY", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 2)),
          const SizedBox(height: 16),
          _buildSettingsTile(
            Icons.security_rounded, 
            "Cloud Security", 
            "Your data is fully encrypted end-to-end",
            onTap: () {},
          ),
          _buildSettingsTile(
            Icons.delete_forever_rounded, 
            "Wipe User Data", 
            "Permanently delete your local Liora records",
            isDestructive: true,
            onTap: _confirmDataWipe,
          ),
        ],
      ),
    );
  }

  void _confirmDataWipe() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Local Data?"),
        content: const Text("This will permanently wipe all your cycle history and local preferences from this device. Cloud data will remain."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("WIPE", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle, {Widget? trailing, VoidCallback? onTap, bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon, color: isDestructive ? Colors.redAccent : const Color(0xFFE67598)),
        title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDestructive ? Colors.redAccent : Colors.black87)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildPinPad(TextEditingController ctrl, Function(String) onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ["1", "2", "3"].map((n) => _pinBtn(n, ctrl, onChanged)).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ["4", "5", "6"].map((n) => _pinBtn(n, ctrl, onChanged)).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ["7", "8", "9"].map((n) => _pinBtn(n, ctrl, onChanged)).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 60),
            _pinBtn("0", ctrl, onChanged),
            IconButton(icon: const Icon(Icons.backspace_outlined, color: Colors.grey), onPressed: () {
               if (ctrl.text.isNotEmpty) {
                 ctrl.text = ctrl.text.substring(0, ctrl.text.length - 1);
                 onChanged(ctrl.text);
               }
            }),
          ],
        ),
      ],
    );
  }

  Widget _pinBtn(String n, TextEditingController ctrl, Function(String) onChanged) {
    return InkWell(
      onTap: () {
         if (ctrl.text.length < 4) {
           ctrl.text += n;
           onChanged(ctrl.text);
         }
      },
      borderRadius: BorderRadius.circular(40),
      child: SizedBox(width: 60, height: 60, child: Center(child: Text(n, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)))),
    );
  }
}
