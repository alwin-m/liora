import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  // 🎨 Shared gradient colors
  static const _appBarGradient = LinearGradient(
    colors: [Color(0xFFfbc2eb), Color(0xFFa6c1ee)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const _bodyGradient = LinearGradient(
    colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: _appBarGradient),
        ),
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: _bodyGradient),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _adminTile(
                context,
                label: 'Add Product',
                icon: Icons.add_box,
                route: '/addProduct',
                color: Colors.greenAccent,
              ),
              _adminTile(
                context,
                label: 'View Products',
                icon: Icons.shopping_bag,
                route: '/viewProducts',
                color: Colors.blueAccent,
              ),
              _adminTile(
                context,
                label: 'Manage Users',
                icon: Icons.people,
                route: '/manageUsers',
                color: Colors.pinkAccent,
              ),
              _adminTile(
                context,
                label: 'Reports',
                icon: Icons.bar_chart,
                route: '/reports',
                color: Colors.orangeAccent,
                comingSoon: true, // 🔒 guarded — route not yet built
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _adminTile(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String route,
    required Color color,
    bool comingSoon = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (comingSoon) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Coming soon!')));
          return;
        }
        Navigator.pushNamed(context, route);
      },
      child: Hero(
        // ✅ Unique tag prevents conflicts with other Hero widgets in the app
        tag: 'admin_tile_$label',
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.9),
                  color.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: color,
                        child: Icon(icon, color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                if (comingSoon)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Soon',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
