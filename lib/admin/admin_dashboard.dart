/*
import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _adminTile(context, "Add Product", Icons.add_box, '/addProduct'),
            _adminTile(context, "View Products", Icons.shopping_bag, '/viewProducts'),
            _adminTile(context, "Manage Users", Icons.people, '/manageUsers'),
          ],
        ),
      ),
    );
  }

  Widget _adminTile(BuildContext context, String title, IconData icon, String route) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.pinkAccent),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🌈 Gradient AppBar
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFfbc2eb), Color(0xFFa6c1ee)], // pastel pink-purple gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("Admin Dashboard"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc)], // soft pastel background
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _adminTile(
                context,
                "Add Product",
                Icons.add_box,
                '/addProduct',
                Colors.greenAccent,
              ),
              _adminTile(
                context,
                "View Products",
                Icons.shopping_bag,
                '/viewProducts',
                Colors.blueAccent,
              ),
              _adminTile(
                context,
                "Manage Users",
                Icons.people,
                '/manageUsers',
                Colors.pinkAccent,
              ),
              _adminTile(
                context,
                "Reports",
                Icons.bar_chart,
                '/reports',
                Colors.orangeAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _adminTile(
    BuildContext context,
    String title,
    IconData icon,
    String route,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Hero(
        tag: title,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.9), color.withOpacity(0.3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
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
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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