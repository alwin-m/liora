
/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();

  bool loading = false;

  Future<void> addProduct() async {
    try {
      setState(() => loading = true);

      await FirebaseFirestore.instance.collection('products').add({
        'name': nameController.text.trim(),
        'price': double.parse(priceController.text),
        'description': descController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Product Name")),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
            TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : addProduct,
              child: loading ? const CircularProgressIndicator() : const Text("Add Product"),
            )
          ],
        ),
      ),
    );
  }
}
*/
/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();

  bool loading = false;

  Future<void> addProduct() async {
    try {
      setState(() => loading = true);

      await FirebaseFirestore.instance.collection('products').add({
        'name': nameController.text.trim(),
        'price': double.parse(priceController.text),
        'description': descController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🌈 Gradient AppBar
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFfbc2eb), Color(0xFFa6c1ee)], // pastel pink-purple
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("Add Product"),
      ),

      // 🌈 Gradient background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc)], // soft pastel background
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildTextField(
                controller: nameController,
                label: "Product Name",
                icon: Icons.label,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: priceController,
                label: "Price",
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: descController,
                label: "Description",
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              // 🚀 Animated Button
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
                          "Add Product",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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

  // 🌟 Custom Glassmorphism TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.pinkAccent),
          labelText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}*/
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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

  final ImagePicker picker = ImagePicker();

  /// Works for Web + Mobile
  Uint8List? imageBytes;

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descController.dispose();
    stockController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  // 📸 Pick image (Web + Mobile)
  Future<void> pickImage() async {
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          imageBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  // ☁️ Upload image to Firebase Storage (Web-safe)
  Future<String> uploadImage() async {
    try {
      if (imageBytes == null || imageBytes!.isEmpty) {
        return ''; // Return empty if no image data
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = FirebaseStorage.instance
          .ref()
          .child('product_images/$timestamp.jpg');

      // ✅ Upload with metadata
      final uploadTask = ref.putData(
        imageBytes!,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // ✅ Wait for upload to complete
      final snapshot = await uploadTask;

      // ✅ Get download URL after upload completes
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('Image uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Image upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: $e')),
      );
      return '';
    }
  }

  // ➕ Add product
  Future<void> addProduct() async {
    // ✅ Validation
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        stockController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      String imageUrl = imageUrlController.text.trim();

      // ✅ Only upload if image was picked
      if (imageBytes != null && imageBytes!.isNotEmpty) {
        print('Uploading image...');
        imageUrl = await uploadImage();
        print('Upload complete. URL: $imageUrl');
      }

      // ✅ Add to Firestore
      await FirebaseFirestore.instance.collection('products').add({
        'name': nameController.text.trim(),
        'price': int.parse(priceController.text.trim()),
        'details': [descController.text.trim()],
        'stock': int.parse(stockController.text.trim()),
        'image': imageUrl.isEmpty
            ? 'https://via.placeholder.com/300x200?text=No+Image'
            : imageUrl,
        'trending': trending,
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added successfully!'),
          duration: Duration(seconds: 2),
        ),
      );

      // ✅ Clear form
      nameController.clear();
      priceController.clear();
      descController.clear();
      stockController.clear();
      imageUrlController.clear();
      imageBytes = null;
      trending = false;

      setState(() {});

      // ✅ Go back after delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error adding product: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
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
        title: const Text("Add Product"),
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
            children: [
              // 🖼️ Image Picker
              GestureDetector(
                onTap: loading ? null : pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(0.85),
                    border: Border.all(
                      color: Colors.pinkAccent.withOpacity(0.5),
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
                                'Tap to add product image',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.memory(
                            imageBytes!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: nameController,
                label: "Product Name",
                icon: Icons.label,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: priceController,
                label: "Price (₹)",
                icon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: stockController,
                label: "Stock Quantity",
                icon: Icons.inventory_2_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: imageUrlController,
                label: "Image URL (optional)",
                icon: Icons.image_outlined,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: descController,
                label: "Description",
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.85),
                ),
                child: SwitchListTile(
                  value: trending,
                  onChanged: loading ? null : (v) => setState(() => trending = v),
                  title: const Text(
                    "Mark as Trending",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  activeColor: Colors.pinkAccent,
                ),
              ),

              const SizedBox(height: 30),

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
                          "Add Product",
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.85),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: !loading,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.pinkAccent),
          labelText: label,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
