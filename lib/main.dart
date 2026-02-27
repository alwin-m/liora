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
import 'services/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Parallel initialization for faster cold-start ──────────────
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    _configureSystemUI(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CycleProvider()),
      ],
      child: const LioraApp(),
    ),
  );
}

/// Configure immersive edge-to-edge display (Samsung S26 / 120Hz).
Future<void> _configureSystemUI() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge, // full edge-to-edge immersive
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class LioraApp extends StatelessWidget {
  const LioraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Liora',
      theme: LioraTheme.lightTheme,
      themeMode: ThemeMode.light,
      // Route table — eagerly pre-registered (no lazy overhead on first push)
      routes: {
        '/': (_) => const SplashScreen(),
        '/signup': (_) => const SignupScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/onboarding': (_) => const OnboardingQuestionsScreen(),
        '/admin': (_) => const AdminDashboard(),
        '/addProduct': (_) => const AddProductScreen(),
        '/viewProducts': (_) => const ViewProductsScreen(),
        '/manageUsers': (_) => const ManageUsersScreen(),
      },
    );
  }
}
