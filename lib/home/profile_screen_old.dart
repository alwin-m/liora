import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../Screens/Change_Password_Screen.dart';
import 'cycle_history_screen.dart';
import 'delete_account_screen.dart';
import '../services/cycle_data_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Real user data
  String userName = 'Loading...';
  String? profilePhotoUrl;
  bool isLoadingPhoto = false;

  // Real notification settings
  bool cycleReminders = false;
  bool periodAlerts = false;
  bool cartUpdates = false;

  // Real cart data
  List<CartItem> cartItems = [];

  // Real cycle data
  String nextPeriodText = 'Loading...';
  String? nextPeriodSubtext;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadUserProfile(),
      _loadNotificationSettings(),
      _loadCartData(),
      _loadCycleData(),
    ]);
  }

  /// Load real user data from Firestore and Firebase Auth
  Future<void> _loadUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final docSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (docSnapshot.exists) {
        final data = docSnapshot.data() ?? {};
        setState(() {
          userName = data['name'] ?? 'User';
          profilePhotoUrl = data['profilePhotoUrl'];
        });
      } else {
        setState(() {
          userName = user.displayName ?? 'User';
          profilePhotoUrl = user.photoURL;
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
      if (mounted) {
        setState(() => userName = 'User');
      }
    }
  }

  /// Load real notification preferences from Firestore
  Future<void> _loadNotificationSettings() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final docSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('notifications')
          .get();

      if (!mounted) return;

      if (docSnapshot.exists) {
        final data = docSnapshot.data() ?? {};
        setState(() {
          cycleReminders = data['cycleReminders'] ?? false;
          periodAlerts = data['periodAlerts'] ?? false;
          cartUpdates = data['cartUpdates'] ?? false;
        });
      }
    } catch (e) {
      print('Error loading notification settings: $e');
    }
  }

  /// Load real cart data from Firestore
  Future<void> _loadCartData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final cartSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .get();

      if (!mounted) return;

      final items = <CartItem>[];
      for (var doc in cartSnapshot.docs) {
        final data = doc.data();
        items.add(CartItem(
          id: doc.id,
          name: data['name'] ?? 'Unknown',
          price: data['price'] ?? 0,
          image: data['image'] ?? '',
          quantity: data['quantity'] ?? 1,
        ));
      }

      setState(() => cartItems = items);
    } catch (e) {
      print('Error loading cart data: $e');
    }
  }

  /// Load real cycle data and calculate next period
  Future<void> _loadCycleData() async {
    try {
      final service = CycleDataService();
      await service.loadUserCycleData();

      if (!mounted) return;

      if (service.isDataLoaded) {
        final nextPeriodRange = service.getNextPeriodDateRange();
        if (nextPeriodRange != null) {
          final daysUntil =
              nextPeriodRange.start.difference(DateTime.now()).inDays;

          setState(() {
            if (daysUntil < 0) {
              nextPeriodText = 'Your period is now';
              nextPeriodSubtext = 'Day ${service.getCurrentCycleDay()}';
            } else if (daysUntil == 0) {
              nextPeriodText = 'Your period starts today';
              nextPeriodSubtext = nextPeriodRange.formattedString;
            } else if (daysUntil == 1) {
              nextPeriodText = 'In 1 day';
              nextPeriodSubtext = 'Expected ${nextPeriodRange.formattedString}';
            } else {
              nextPeriodText = 'In $daysUntil days';
              nextPeriodSubtext = 'Expected ${nextPeriodRange.formattedString}';
            }
          });
        } else {
          setState(() {
            nextPeriodText = 'No data';
            nextPeriodSubtext = 'Complete setup to see predictions';
          });
        }
      } else {
        setState(() {
          nextPeriodText = 'Setup needed';
          nextPeriodSubtext = 'Go to calendar to add cycle data';
        });
      }
    } catch (e) {
      print('Error loading cycle data: $e');
      if (mounted) {
        setState(() {
          nextPeriodText = 'Unable to load';
          nextPeriodSubtext = 'Check your connection';
        });
      }
    }
  }

  /// Update notification setting in Firestore
  Future<void> _updateNotificationSetting(
    String setting,
    bool value,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('notifications')
          .set({
        setting: value,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating notification setting: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save setting: $e'),
          backgroundColor: const Color(0xFFE74C3C),
        ),
      );
    }
  }

  /// Handle profile photo selection and upload
  Future<void> _pickAndUploadProfilePhoto() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (pickedFile == null) return;

      setState(() => isLoadingPhoto = true);

      final user = _auth.currentUser;
      if (user == null) return;

      // Upload to Firebase Storage
      final fileName = 'profile_photos/${user.uid}.jpg';
      final uploadTask = await _storage.ref(fileName).putFile(
        File(pickedFile.path),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Save URL to Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'profilePhotoUrl': downloadUrl,
      });

      if (!mounted) return;

      setState(() {
        profilePhotoUrl = downloadUrl;
        isLoadingPhoto = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading photo: $e'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  /// Remove profile photo
  Future<void> _removeProfilePhoto() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      setState(() => isLoadingPhoto = true);

      // Delete from Storage
      try {
        await _storage.ref('profile_photos/${user.uid}.jpg').delete();
      } catch (e) {
        print('Storage deletion warning: $e');
      }

      // Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'profilePhotoUrl': FieldValue.delete(),
      });

      if (!mounted) return;

      setState(() {
        profilePhotoUrl = null;
        isLoadingPhoto = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo removed'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing photo: $e'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  /// Show photo options (change/remove)
  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFDFCF8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Profile Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            _PhotoOption(
              icon: Icons.photo_camera_outlined,
              title: 'Change photo',
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadProfilePhoto();
              },
            ),
            if (profilePhotoUrl != null)
              _PhotoOption(
                icon: Icons.delete_outline,
                title: 'Remove photo',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Open settings menu
  void _openSettingsPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFDFCF8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              _SettingsItem(
                icon: Icons.lock_outline,
                title: 'Change password',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              _SettingsItem(
                icon: Icons.history,
                title: 'Cycle history',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CycleHistoryScreen(),
                    ),
                  );
                },
              ),
              _SettingsItem(
                icon: Icons.logout,
                title: 'Log out',
                onTap: () async {
                  Navigator.pop(context);
                  await _logout();
                },
              ),
              _SettingsItem(
                icon: Icons.delete_outline,
                title: 'Delete account',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DeleteAccountScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Logout user from Firebase
  Future<void> _logout() async {
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormatter = DateFormat('d MMMM yyyy');
    final todayText = dateFormatter.format(now);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand + Settings button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'LIORA',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.4,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: _openSettingsPopup,
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // User profile section
              Row(
                children: [
                  // Profile photo
                  GestureDetector(
                    onTap: _showPhotoOptions,
                    child: Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFF4C7D8),
                              width: 2,
                            ),
                            color: Colors.white,
                          ),
                          child: ClipOval(
                            child: profilePhotoUrl != null && !isLoadingPhoto
                                ? Image.network(
                                    profilePhotoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.person_outline,
                                          size: 48,
                                          color: Color(0xFFE67598),
                                        ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: isLoadingPhoto
                                        ? const SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                Color(0xFFE67598),
                                              ),
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.person_outline,
                                            size: 48,
                                            color: Color(0xFFE67598),
                                          ),
                                  ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE67598),
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $userName!',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Here's your gentle overview today",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6F6152),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Text(
                'Today · $todayText',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6F6152),
                ),
              ),

              const SizedBox(height: 32),

              // Next cycle card
              _InfoCard(
                title: 'Next cycle',
                mainText: nextPeriodText,
                subText: nextPeriodSubtext ?? '',
                highlight: true,
              ),

              const SizedBox(height: 16),

              // Cart section
              _CardContainer(
                title: 'Your Cart',
                child: cartItems.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 32,
                                color: Color(0xFFE8E0D5),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Your cart is empty',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6F6152),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cartItems.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return _CartItemWidget(
                            image: item.image,
                            name: item.name,
                            quantity: item.quantity,
                            price: item.price,
                          );
                        },
                      ),
              ),

              const SizedBox(height: 16),

              // Notifications section
              _CardContainer(
                title: 'Notifications',
                child: Column(
                  children: [
                    _ToggleRow(
                      title: 'Cycle reminders',
                      subtitle: 'Gentle nudges about your cycle phases',
                      value: cycleReminders,
                      onChanged: (v) {
                        setState(() => cycleReminders = v);
                        _updateNotificationSetting('cycleReminders', v);
                      },
                    ),
                    _ToggleRow(
                      title: 'Upcoming period alerts',
                      subtitle: '2–3 days before your expected period',
                      value: periodAlerts,
                      onChanged: (v) {
                        setState(() => periodAlerts = v);
                        _updateNotificationSetting('periodAlerts', v);
                      },
                    ),
                    _ToggleRow(
                      title: 'Cart & order updates',
                      subtitle: 'When items ship or arrive',
                      value: cartUpdates,
                      onChanged: (v) {
                        setState(() => cartUpdates = v);
                        _updateNotificationSetting('cartUpdates', v);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper widget: Info card
class _InfoCard extends StatelessWidget {
  final String title;
  final String mainText;
  final String subText;
  final bool highlight;

  const _InfoCard({
    required this.title,
    required this.mainText,
    required this.subText,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFF4C7D8) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8E0D5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6F6152),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mainText,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subText,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6F6152),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Helper widget: Card container
class _CardContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const _CardContainer({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8E0D5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: child,
          ),
        ],
      ),
    );
  }
}

// Helper widget: Cart item
class _CartItemWidget extends StatelessWidget {
  final String image;
  final String name;
  final int quantity;
  final int price;

  const _CartItemWidget({
    required this.image,
    required this.name,
    required this.quantity,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: image.isNotEmpty
              ? Image.network(
                  image,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: const Color(0xFFE8E0D5),
                      child: const Icon(Icons.image_not_supported_outlined),
                    );
                  },
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: const Color(0xFFE8E0D5),
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Qty: $quantity',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6F6152),
                ),
              ),
            ],
          ),
        ),
        Text(
          '\$$price',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Helper widget: Toggle row
class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                const SizedBox(height: 4),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFFE67598),
          ),
        ],
      ),
    );
  }
}

// Helper widget: Settings item
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive
                  ? const Color(0xFFE74C3C)
                  : const Color(0xFF6F6152),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isDestructive ? const Color(0xFFE74C3C) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget: Photo option
class _PhotoOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _PhotoOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive
                  ? const Color(0xFFE74C3C)
                  : const Color(0xFF6F6152),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isDestructive ? const Color(0xFFE74C3C) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Updated CartItem with quantity
class CartItem {
  final String id;
  final String name;
  final int price;
  final String image;
  final int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
  });
}
