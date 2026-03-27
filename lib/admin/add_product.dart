import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

// 🔥 Cloudinary config — move to --dart-define or a config file for production
const String cloudName = 'ddr1p1mv7';
const String uploadPreset = 'products_unsigned';

// ✅ Max image size: 5 MB
const int _maxImageBytes = 5 * 1024 * 1024;

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();
  final stockController = TextEditingController();
  final imageUrlController = TextEditingController();

  bool trending = false;
  bool loading = false;

  Uint8List? imageBytes;
  final ImagePicker picker = ImagePicker();

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descController.dispose();
    stockController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  // 📸 Pick image from gallery
  Future<void> pickImage() async {
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final bytes = await picked.readAsBytes();

      // ✅ Validate image size before uploading
      if (bytes.lengthInBytes > _maxImageBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image too large. Please choose one under 5 MB.'),
            ),
          );
        }
        return;
      }

      setState(() => imageBytes = bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Image pick error: $e')));
      }
    }
  }

  // ☁️ Upload image to Cloudinary
  Future<String> uploadToCloudinary(Uint8List bytes) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: 'product.jpg'),
      );

    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final data = jsonDecode(resStr);
      return data['secure_url'] as String;
    } else {
      throw Exception('Cloudinary upload failed (${response.statusCode})');
    }
  }

  // ➕ Add product to Firestore
  Future<void> addProduct() async {
    final name = nameController.text.trim();
    final priceText = priceController.text.trim();
    final stockText = stockController.text.trim();
    final desc = descController.text.trim();

    // ✅ Validate required fields
    if (name.isEmpty || priceText.isEmpty || stockText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // ✅ Validate numeric fields — no more int.parse crash
    final price = int.tryParse(priceText);
    final stock = int.tryParse(stockText);

    if (price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid whole number for price')),
      );
      return;
    }

    if (stock == null || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid whole number for stock')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      String imageUrl = imageUrlController.text.trim();

      // Upload to Cloudinary if image was picked from gallery
      if (imageBytes != null && imageBytes!.isNotEmpty) {
        imageUrl = await uploadToCloudinary(imageBytes!);
      }

      // ✅ Use 'description' field consistently (was 'details' — caused mismatch)
      await FirebaseFirestore.instance.collection('products').add({
        'name': name,
        'price': price,
        'description': desc, // ✅ Fixed: was 'details': [desc]
        'stock': stock,
        'image': imageUrl.isEmpty
            ? 'https://via.placeholder.com/300x200?text=No+Image'
            : imageUrl,
        'trending': trending,
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFfbc2eb), Color(0xFFa6c1ee)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('Add Product'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼 Image Picker
              GestureDetector(
                onTap: loading ? null : pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withValues(alpha: 0.85),
                    border: Border.all(
                      color: Colors.pinkAccent.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: imageBytes == null
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 40,
                                color: Colors.pinkAccent,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to add product image (max 5 MB)',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.memory(
                                imageBytes!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            // ✅ Remove image button
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => setState(() => imageBytes = null),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),

              _buildTextField(nameController, 'Product Name', Icons.label),
              const SizedBox(height: 12),
              _buildTextField(
                priceController,
                'Price (₹)',
                Icons.currency_rupee,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                stockController,
                'Stock Quantity',
                Icons.inventory_2_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                descController,
                'Description',
                Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              // Optional image URL
              _buildTextField(
                imageUrlController,
                'Or paste image URL (optional)',
                Icons.image_outlined,
              ),

              const SizedBox(height: 12),

              // ✅ Trending toggle — properly disabled during loading
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withValues(alpha: 0.85),
                ),
                child: SwitchListTile(
                  value: trending,
                  // ✅ Disabled during loading
                  onChanged: loading
                      ? null
                      : (v) => setState(() => trending = v),
                  title: const Text(
                    'Mark as Trending',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  activeThumbColor: Colors.pinkAccent,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.pinkAccent,
                    elevation: 6,
                  ),
                  onPressed: loading ? null : addProduct,
                  child: loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Add Product',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.85),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        // ✅ Disabled during loading (was missing in active version)
        enabled: !loading,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.pinkAccent),
          labelText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
