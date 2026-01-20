
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Screens/Splash_Screen.dart';
import 'Screens/Signup_Screen.dart';
import 'Screens/Login_Screen.dart';
import 'home/home_screen.dart';

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
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
