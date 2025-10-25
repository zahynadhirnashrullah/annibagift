import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'pages/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('id_ID', null);
  runApp(const AnnibaGiftApp());
}

class AnnibaGiftApp extends StatelessWidget {
  const AnnibaGiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anniba Gift',
      theme: AppTheme.themeData,
      home: const SplashScreen(), // Show splash screen on app launch
      debugShowCheckedModeBanner: false,
    );
  }
}