import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Import firebase options file
import 'firebase_options.dart';

// Import all screens
import 'screens/welcome_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase correctly for all platforms (including web)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PetPoint());
}

class PetPoint extends StatelessWidget {
  const PetPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetPoint 🐾',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.teal.shade50,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.teal, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),

      // ✅ Define routes for navigation
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
