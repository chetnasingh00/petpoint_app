import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Screens
import 'screens/welcome_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/home_page.dart';
import 'screens/reset_password_page.dart';
import 'screens/add_pet_page.dart';
import 'screens/appointment_form_page.dart';
import 'screens/doctor_list_page.dart';
import 'screens/my_appointments_page.dart';
import 'screens/pet_list_page.dart';

// Notification Service
import 'notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Initialize notifications
  await NotificationService.init();

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
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomeScreen(),
        '/reset-password': (context) => const ResetPasswordPage(),

        // ✅ Newly added routes
        '/add-pet': (context) => const AddPetPage(),
        '/doctors': (context) => const DoctorListScreen(),
        '/pets': (context) => const PetListPage(),
        '/my-appointments': (context) => const MyAppointmentsPage(),
        '/appointments': (context) => const AppointmentFormPage(),
       

      },
    );
  }
}
