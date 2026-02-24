import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/app_theme.dart';

// Screens
import 'Screens/splash_screen.dart';
import 'Screens/signup_screen.dart';
import 'Screens/login_screen.dart';
import 'home/home_screen.dart';
import 'onboarding/onboarding_screen.dart';

// Admin
import 'admin/admin_dashboard.dart';
import 'admin/add_product.dart';
import 'admin/view_products.dart';
import 'admin/manage_users.dart';

// Providers
import 'services/cart_provider.dart';
import 'services/cycle_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Low-glare immersive display for luxury feel
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: LioraTheme.offWhiteWarm,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CycleProvider()),
      ],
      child: const LioraApp(),
    ),
  );
}

class LioraApp extends StatelessWidget {
  const LioraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Liora',
      theme: LioraTheme.lightTheme,
      routes: {
        '/': (context) => const SplashScreen(),
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/onboarding': (context) => const OnboardingQuestionsScreen(),
        '/admin': (context) => const AdminDashboard(),
        '/addProduct': (context) => const AddProductScreen(),
        '/viewProducts': (context) => const ViewProductsScreen(),
        '/manageUsers': (context) => const ManageUsersScreen(),
      },
    );
  }
}
