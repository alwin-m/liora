import 'package:flutter/material.dart';
import '../core/secure_storage_service.dart';

class YourDetailsScreen extends StatefulWidget {
  const YourDetailsScreen({super.key});

  @override
  State<YourDetailsScreen> createState() => _YourDetailsScreenState();
}

class _YourDetailsScreenState extends State<YourDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final details = await SecureStorageService.getUserAddress();
    if (mounted) {
      setState(() {
        _nameController.text = details['name'] ?? "";
        _phoneController.text = details['phone'] ?? "";
        _addressController.text = details['address'] ?? "";
        _pincodeController.text = details['pincode'] ?? "";
        _isLoading = false;
      });
    }
  }

  Future<void> _saveDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await SecureStorageService.saveUserAddress({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'pincode': _pincodeController.text,
      });
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Details saved successfully ✓")));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      appBar: AppBar(
        title: const Text("Your Details", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFE67598)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Delivery Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text("Used for faster checkout and deliveries", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 32),
                  
                  _buildTextField("Full Name", _nameController, Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildTextField("Phone Number", _phoneController, Icons.phone_android_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildTextField("Address / House Name", _addressController, Icons.home_outlined, maxLines: 3),
                  const SizedBox(height: 16),
                  _buildTextField("PIN Code", _pincodeController, Icons.pin_drop_outlined, keyboardType: TextInputType.number),
                  
                  const SizedBox(height: 48),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _saveDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE67598),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text("SAVE DETAILS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: (value) => (value == null || value.isEmpty) ? "This field is required" : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFE67598), size: 20),
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