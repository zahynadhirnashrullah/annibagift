import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'pages/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AnnibaGiftApp());
}

class AnnibaGiftApp extends StatelessWidget {
  const AnnibaGiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anniba Gift',
      theme: AppTheme.themeData,
      home: const LoginScreen(), // <-- Atur LoginScreen sebagai halaman utama
      debugShowCheckedModeBanner: false,
    );
  }
}