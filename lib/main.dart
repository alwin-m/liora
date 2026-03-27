/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'Screens/Splash_Screen.dart';
import 'Screens/Signup_Screen.dart';
import 'Screens/Login_Screen.dart';
import 'Screens/verify_email_screen.dart';
import 'home/Home_Screen.dart';
import 'onboarding/onboarding_screen.dart';

import 'admin/admin_dashboard.dart';
import 'admin/add_product.dart';
import 'admin/view_products.dart';
import 'admin/manage_users.dart';

import 'core/cycle_session.dart';
import 'core/notification_service.dart';
import 'core/app_settings.dart';

final ValueNotifier<ThemeMode> themeNotifier =
    ValueNotifier(ThemeMode.system);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await CycleSession.initialize();
  await NotificationService.initialize();

  // 🔥 Restore scheduled reminder safely
  if (CycleSession.isInitialized) {
    try {
      final nextPeriod =
          CycleSession.algorithm.getNextPeriodDate();

      await NotificationService
          .reschedulePeriodReminder(nextPeriod);
    } catch (e) {
      debugPrint("Reminder restore error: $e");
    }
  }

  bool isDark = await AppSettings.getDarkMode();
  themeNotifier.value =
      isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Liora',
          themeMode: mode,

          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.pink,
            scaffoldBackgroundColor:
                const Color(0xFFFDF6F9),
            useMaterial3: true,
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor:
                const Color(0xFF121212),
            useMaterial3: true,
          ),

          // ✅ IMPORTANT FIX (Removed initialRoute)
          home: const SplashScreen(),

          routes: {
            '/signup': (context) =>
                const SignupScreen(),
            '/login': (context) =>
                const LoginScreen(),
            '/verify-email': (context) =>
                const VerifyEmailScreen(),
            '/home': (context) =>
                const HomeScreen(),
            '/onboarding': (context) =>
                const OnboardingQuestionsScreen(),
            '/admin': (context) =>
                const AdminDashboard(),
            '/addProduct': (context) =>
                const AddProductScreen(),
            '/viewProducts': (context) =>
                const ViewProductsScreen(),
            '/manageUsers': (context) =>
                const ManageUsersScreen(),
          },
        );
      },
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart'; // ✅ added
import 'core/app_theme.dart'; // 🎨 Liora Brand

import 'Screens/Splash_Screen.dart';
import 'Screens/Signup_Screen.dart';
import 'Screens/Login_Screen.dart';
import 'Screens/verify_email_screen.dart';
import 'home/Home_Screen.dart';
import 'onboarding/onboarding_screen.dart';

import 'admin/admin_dashboard.dart';
import 'admin/add_product.dart';
import 'admin/view_products.dart';
import 'admin/manage_users.dart';

import 'core/cycle_session.dart';
import 'core/notification_service.dart';
import 'core/app_settings.dart';

import 'services/cart_provider.dart'; // ✅ added

final ValueNotifier<ThemeMode> themeNotifier =
    ValueNotifier(ThemeMode.system);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await CycleSession.initialize();
  await NotificationService.initialize();

  // 🔥 Restore scheduled reminder safely
  if (CycleSession.isInitialized) {
    try {
      final nextPeriod =
          CycleSession.algorithm.getNextPeriodDate();

      await NotificationService
          .reschedulePeriodReminder(nextPeriod);
    } catch (e) {
      debugPrint("Reminder restore error: $e");
    }
  }

  bool isDark = await AppSettings.getDarkMode();
  themeNotifier.value =
      isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(
    ChangeNotifierProvider( // ✅ only change
      create: (_) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Liora: Kitten Edition',
          themeMode: mode,

          theme: LioraTheme.light,
          darkTheme: LioraTheme.dark,

          home: const SplashScreen(),

          routes: {
            '/signup': (context) =>
                const SignupScreen(),
            '/login': (context) =>
                const LoginScreen(),
            '/verify-email': (context) =>
                const VerifyEmailScreen(),
            '/home': (context) =>
                const HomeScreen(),
            '/onboarding': (context) =>
                const OnboardingQuestionsScreen(),
            '/admin': (context) =>
                const AdminDashboard(),
            '/addProduct': (context) =>
                const AddProductScreen(),
            '/viewProducts': (context) =>
                const ViewProductsScreen(),
            '/manageUsers': (context) =>
                const ManageUsersScreen(),
          },
        );
      },
    );
  }
}

