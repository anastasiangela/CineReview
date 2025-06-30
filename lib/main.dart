import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_flutter_uaspemob/edit_email_screen.dart';
import 'package:project_flutter_uaspemob/edit_name_screen.dart';
import 'package:project_flutter_uaspemob/forgot_password_screen.dart';
import 'package:project_flutter_uaspemob/profile_screen.dart';
import 'package:project_flutter_uaspemob/user_provider.dart';

import 'splash_screen.dart';
import 'welcome_screen.dart'; // SignUpScreen
import 'login_screen.dart';
import 'home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider()..loadUserData(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CineReview',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Splash screen sebagai halaman awal
      home: const SplashScreen(),
      routes: {
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/forgot': (context) => const ForgotPasswordScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-name': (context) => const EditNameScreen(),
        '/edit-email': (context) => const EditEmailScreen(),
      },
    );
  }
}
