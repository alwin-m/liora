import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class YourDetailsScreen extends StatefulWidget {
  const YourDetailsScreen({super.key});

  @override
  State<YourDetailsScreen> createState() => _YourDetailsScreenState();
}

class _YourDetailsScreenState extends State<YourDetailsScreen> {

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final nearbyController = TextEditingController();
  final pincodeController = TextEditingController();

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  // ================= LOAD USER DATA =================

  Future<void> _loadUserDetails() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final data = doc.data();

    nameController.text = data?["name"] ?? "";
    phoneController.text = data?["phone"] ?? "";
    addressController.text = data?["address"] ?? "";
    nearbyController.text = data?["nearby"] ?? "";
    pincodeController.text = data?["pincode"] ?? "";
    emailController.text = user.email ?? "";

    setState(() {
      loading = false;
    });
  }

  // ================= SAVE DETAILS =================

  Future<void> _saveDetails() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      saving = true;
    });

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .set({

      "name": nameController.text.trim(),
      "phone": phoneController.text.trim(),
      "address": addressController.text.trim(),
      "nearby": nearbyController.text.trim(),
      "pincode": pincodeController.text.trim(),

    }, SetOptions(merge: true));

    setState(() {
      saving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Details Updated Successfully 💖"),
      ),
    );
  }

  // ================= INPUT FIELD =================

  Widget _inputField(
      String label,
      TextEditingController controller,
      {int maxLines = 1,
      bool readOnly = false}) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(
              fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 6),

        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: "Enter $label",
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 14),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 18),
      ],
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Your Details"),
        backgroundColor: const Color(0xFFE67598),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [

                  Container(
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.05),
                          blurRadius: 10,
                        )
                      ],
                    ),

                    child: Column(
                      children: [

                        _inputField(
                            "Name", nameController),

                        _inputField(
                            "Phone Number",
                            phoneController),

                        _inputField(
                            "Email",
                            emailController,
                            readOnly: true),

                        _inputField(
                            "Address",
                            addressController,
                            maxLines: 3),

                        _inputField(
                            "Nearby / Landmark",
                            nearbyController),

                        _inputField(
                            "Pincode",
                            pincodeController),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          height: 50,

                          child: ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(
                                      0xFFE67598),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(12),
                              ),
                            ),

                            onPressed: saving
                                ? null
                                : _saveDetails,

                            child: saving
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child:
                                        CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text(
                                    "Save Details",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}