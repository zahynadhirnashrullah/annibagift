import 'package:flutter/material.dart';
import 'package:annibagift/pages/login_screen.dart'; // Pastikan path ini benar
import '../services/auth_service.dart';
import '../models/models.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check for persisted user session and navigate accordingly
    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted) return;
      try {
        final restored = await AuthService.instance.restoreUserSession();
        if (restored != null) {
          // If user was previously admin, attempt to sign in admin secondary app if possible
          if (restored.role == Role.admin) {
            // We don't store passwords for security reasons; admin secondary auth
            // will remain signed-in if Firebase persisted it. The admin service
            // initialization runs in main.dart, so we just navigate.
          }
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainScreen(currentUser: restored)),
          );
          return;
        }
      } catch (_) {}

      // No persisted session — go to Login
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A5ACD), // Warna ungu seperti di contoh
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/LogoAnnibaTransparant.png', // Sesuaikan dengan nama file gambar baru Anda
              width: 300,
              height: 300,
              errorBuilder: (context, error, stackTrace) {
                // Use debugPrint instead of print for better control in production
                debugPrint('Error loading image: $error');
                return const Icon(
                  Icons.error_outline,
                  size: 100,
                  color: Colors.white, // Sesuaikan warna ikon error agar terlihat
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}