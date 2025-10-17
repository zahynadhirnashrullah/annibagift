import 'package:flutter/material.dart';
// Hapus import firebase jika Anda belum mengaturnya.
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'pages/login_screen.dart'; // <-- Ubah import ke LoginScreen

// Hapus 'async' dan 'await Firebase' jika Anda tidak menggunakan Firebase
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
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