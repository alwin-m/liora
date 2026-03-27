import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          // ================= HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              bottom: 30,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFADADD),
                  Color(0xFFE6E6FA),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: Column(
              children: const [
                Icon(
                  Icons.favorite,
                  size: 40,
                  color: Color(0xFFE67598),
                ),
                SizedBox(height: 10),
                Text(
                  "LIORA",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Menstrual Wellness Companion",
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),

          // ================= BODY =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _sectionTitle("About Liora"),
                  _sectionText(
                    "Liora is a menstrual cycle tracking and wellness companion app "
                    "designed to help users better understand and manage their cycle patterns. "
                    "The application combines personalized cycle prediction logic with "
                    "a curated wellness experience."
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle("How It Works"),
                  _sectionText(
                    "Liora uses user-provided data such as cycle length, period duration, "
                    "stress levels, and other cycle-related inputs to calculate predictions. "
                    "The prediction model adapts based on historical cycle data."
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle("Prediction Accuracy"),
                  _sectionText(
                    "Cycle predictions are based on historical data patterns and "
                    "personalized algorithm adjustments. Accuracy typically ranges "
                    "between 80–90% depending on cycle consistency and data reliability. "
                    "Predictions may vary for irregular cycles."
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle("Wellness Integration"),
                  _sectionText(
                    "Liora also provides access to curated menstrual wellness "
                    "products to support self-care and cycle comfort."
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle("Privacy & Security"),
                  _sectionText(
                    "User data is securely stored and used only for personalized "
                    "prediction and app functionality. Liora does not collect "
                    "sensitive physical or sensor-based health data."
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle("Medical Disclaimer"),
                  _sectionText(
                    "Liora is not a medical diagnostic tool. "
                    "All predictions are for informational purposes only. "
                    "For medical advice or health concerns, please consult a qualified healthcare professional."
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: Text(
                      "Version 1.0.0",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
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

  // ================= SECTION TITLE =================
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE67598),
      ),
    );
  }

  // ================= SECTION TEXT =================
  Widget _sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          height: 1.6,
        ),
      ),
    );
  }
}