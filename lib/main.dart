// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- 1. IMPORT FIRESTORE
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'pages/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- 2. TAMBAHKAN BLOK INI ---
  // Mengaktifkan penyimpanan offline Firestore (Persistence)
  // Ini akan otomatis menyimpan data saat offline dan sinkronisasi saat online
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  // --- AKHIR TAMBAHAN ---

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