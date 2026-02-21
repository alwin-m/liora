import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lioraa/core/app_theme.dart';
import 'package:lioraa/Screens/Login_Screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Admin Portal",
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: cs.error),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(LioraTheme.space24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, Admin",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Manage your wellness boutique operations",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: LioraTheme.space24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: LioraTheme.space16,
                mainAxisSpacing: LioraTheme.space16,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildListDelegate([
                _buildAdminCard(
                  context,
                  "Inventory",
                  "Add items",
                  Icons.add_business_rounded,
                  '/addProduct',
                  cs.primary,
                ),
                _buildAdminCard(
                  context,
                  "Products",
                  "View all",
                  Icons.inventory_2_outlined,
                  '/viewProducts',
                  cs.secondary,
                ),
                _buildAdminCard(
                  context,
                  "Customers",
                  "Manage users",
                  Icons.people_alt_outlined,
                  '/manageUsers',
                  cs.tertiary,
                ),
                _buildAdminCard(
                  context,
                  "Statistics",
                  "View insights",
                  Icons.analytics_outlined,
                  '/reports',
                  cs.secondaryContainer,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String route,
    Color color,
  ) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(LioraTheme.space16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(LioraTheme.radiusCard),
          border: Border.all(color: cs.outlineVariant.withAlpha(50)),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withAlpha(120),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
