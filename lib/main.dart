// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'pages/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/firebase_admin_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Inisialisasi Firebase default (aman untuk semua platform)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Abaikan error duplicate app (misalnya saat hot reload)
    if (!e.toString().contains('duplicate-app')) {
      rethrow;
    }
  }

  // ✅ Inisialisasi secondary admin app (opsional, dan dicegah error duplikat)
  try {
    await Firebase.initializeApp(
      name: 'admin-app',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Abaikan error duplicate app
  }

  // ✅ Inisialisasi service admin setelah semua app siap
  await FirebaseAdminService.initialize();

  // ✅ Aktifkan penyimpanan offline Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
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
      home: const SplashScreen(), // Splash screen saat pertama kali app dibuka
      debugShowCheckedModeBanner: false,
    );
  }
}
