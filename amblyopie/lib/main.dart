import 'package:amblyopie/firebase_options.dart';
import 'package:amblyopie/pages/auth/login_page.dart';
import 'package:amblyopie/pages/auth/register_page.dart';
import 'package:amblyopie/pages/onboarding/onboarding_page.dart';
import 'package:amblyopie/pages/profile/create_profile_page.dart';
import 'package:amblyopie/pages/home/home_shell.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> safeInitFirebase() async {
  try {
    if (Firebase.apps.isNotEmpty) {
      return;
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

  } on FirebaseException catch (e) {
      if (e.code == 'duplicate-app') {
        Firebase.app();
      } else {
        rethrow;
      }
    }
  }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await safeInitFirebase();
  await initializeDateFormatting('fr_FR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final peach = const Color(0xFFFBE1C5);
  final orange = const Color(0xFFF58F5D);
  final blue = const Color(0xFF8FB4E3);
  final ink = const Color(0xFF2F2A24);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: orange,
          background: peach,
          surface: Colors.white,
          primary: orange,
          secondary: blue,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: ink,
          onSurface: ink.withOpacity(0.9),
        ),
        scaffoldBackgroundColor: peach,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w800),
          bodyMedium: TextStyle(height: 1.25),
        ),
      ),
      title: 'Amblyopie',
      routes: {
        '/onboarding': (context) => const OnboardingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomeShell(),
        '/createProfile' : (context) => CreateProfilePage(),
      },
      initialRoute: 
        '/onboarding',
    );
  }
}
