/*import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Screens/Splash_Screen.dart';
import 'Screens/Signup_Screen.dart';
import 'Screens/Login_Screen.dart'; // ✅ ADDED
import 'home/Home_Screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Liora',
      theme: ThemeData(primarySwatch: Colors.pink),
      routes: {
        '/': (context) => const SplashScreen(),
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(), // ✅ ADDED

        // ✅ HomeScreen has NO parameters now
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// 🔹 AUTH & USER SCREENS
import 'Screens/Splash_Screen.dart';
import 'Screens/Signup_Screen.dart';
import 'Screens/Login_Screen.dart';
import 'home/Home_Screen.dart';

// 🔹 ONBOARDING (🔥 MISSING BEFORE)
import 'onboarding/onboarding_screen.dart';

// 🔹 ADMIN SCREENS
import 'admin/admin_dashboard.dart';
import 'admin/add_product.dart';
import 'admin/view_products.dart';
import 'admin/manage_users.dart';

// 🔹 DESIGN SYSTEM
import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Liora',
      theme: AppTheme.lightTheme,

      routes: {
        '/': (context) => const SplashScreen(),
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),

        // USER
        '/home': (context) => const HomeScreen(),
        '/onboarding': (context) => const OnboardingQuestionsScreen(),

        // ADMIN
        '/admin': (context) => const AdminDashboard(),
        '/addProduct': (context) => const AddProductScreen(),
        '/viewProducts': (context) => const ViewProductsScreen(),
        '/manageUsers': (context) => const ManageUsersScreen(),
      },
    );
  }
}
