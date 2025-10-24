import 'package:flutter/material.dart';
import 'package:annibagift/pages/login_screen.dart'; // Pastikan path ini benar

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigasi ke layar login setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () async {
      // Guard against using context if the widget was disposed while waiting
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