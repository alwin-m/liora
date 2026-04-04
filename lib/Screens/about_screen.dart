import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showSecretZen(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFDF6F9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("🌸 Zen Moment", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE67598))),
        content: const Text(
          "Take a deep breath. You are doing great. Liora is here to support you, one cycle at a time.\n\nKeep shining ✨",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Gratitude", style: TextStyle(color: Color(0xFFE67598))))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      body: Column(
        children: [
          // ================= HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFADADD), Color(0xFFE6E6FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFE67598)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                GestureDetector(
                  onLongPress: () {
                    HapticFeedback.lightImpact();
                    _showSecretZen(context);
                  },
                  child: ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.15).animate(
                      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                    ),
                    child: const Icon(Icons.favorite, size: 50, color: Color(0xFFE67598)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "LIORA",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2, color: Color(0xFF3B1A2A)),
                ),
                const Text(
                  "MENSTRUAL WELLNESS COMPANION",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey),
                ),
              ],
            ),
          ),

          // ================= BODY =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("The Hathaway Logic"),
                  _sectionText(
                    "Liora is powered by the 'Annie Hathaway' algorithm—our advanced, on-device self-learning engine. "
                    "Unlike static trackers, Hathaway observes your unique flow patterns and symptoms to predict your cycle with up to 90% accuracy. "
                    "It evolves with you, becoming more precise with every log."
                  ),

                  const SizedBox(height: 24),

                  _sectionTitle("Menstrual Companion Status"),
                  _sectionText(
                    "We are currently focusing 100% on perfecting our predictive health modules. "
                    "As a result, our Wellness Shop and E-commerce sections are temporarily offline for system refinements. "
                    "Our mission is to provide the most reliable health intelligence first."
                  ),

                  const SizedBox(height: 24),

                  _sectionTitle("Privacy-First Architecture"),
                  _sectionText(
                    "Your health data never leaves your device. Liora uses a local-only storage model to ensure maximum privacy. "
                    "⚠️ IMPORTANT: Because we do not store your data on our servers, it is unrecoverable if you uninstall the app or clear its data. "
                    "Please keep your device secure."
                  ),

                  const SizedBox(height: 24),

                  _sectionTitle("Medical Disclaimer"),
                  _sectionText(
                    "Liora is NOT a medically certified diagnostic or contraceptive tool. "
                    "All predictions are based on user-provided data and algorithmic estimations. "
                    "Calculations are subject to human or computer error and should not be used as the sole basis for medical decisions. "
                    "Always consult a qualified healthcare professional for medical concerns."
                  ),

                  const SizedBox(height: 40),

                  const Center(
                    child: Text(
                      "Crafted with ♥ for Wellness\nVersion 2.2.2",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5, fontWeight: FontWeight.w500),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFFE67598), letterSpacing: 1),
    );
  }

  Widget _sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey.shade800),
      ),
    );
  }
}