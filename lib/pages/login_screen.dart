// lib/screens/login_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // <-- 1. TAMBAHKAN IMPORT INI

// Import service yang benar
import '../services/auth_service.dart';
import '../services/firebase_admin_service.dart'; // Import admin service
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../pages/main_screen.dart';
import '../models/models.dart'; // Import model untuk Role

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // tambahkan listener untuk memantau perubahan teks
    _passwordController.addListener(() {
      // Panggil setState agar UI diperbarui (untuk menampilkan/menyembunyikan ikon)
      // Kita hanya perlu setState jika panjang teks berubah dari 0 ke 1 atau 1 ke 0
      if (_passwordController.text.isEmpty ||
          _passwordController.text.length == 1) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // --- 2. TAMBAHKAN BLOK PENGECEKAN KONEKSI DI SINI ---
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tidak ada koneksi internet. Silakan periksa jaringan Anda.',
            ),
            backgroundColor: AppColors.accentRed,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return; // Hentikan login jika tidak ada koneksi
      }
      // --- AKHIR TAMBAHAN (Sisa kode di bawah ini adalah milik Anda) ---

      try {
        final email = _emailController.text;
        final password = _passwordController.text;

        final user = await AuthService.instance.login(email, password);

        if (user != null) {
          if (!user.isActive) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Akun Anda telah dinonaktifkan. Hubungi admin.'),
                backgroundColor: AppColors.accentRed,
              ),
            );
            await AuthService.instance.signOut();
          } else {
            if (user.role == Role.admin) {
              await FirebaseAdminService.instance.loginAsAdmin(email, password);
            }

            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(currentUser: user),
              ),
            );
          }
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email atau password salah.'),
              backgroundColor: AppColors.accentRed,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // --- WIDGET BUILDER BARU UNTUK TEXTFIELD KACA ---
  // (Tidak ada perubahan di sini)
  Widget _buildGlassTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isObscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      validator: validator,
      // Teks yang diketik pengguna akan berwarna putih
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        // Label dan ikon akan berwarna putih transparan
        labelStyle: TextStyle(
          color: Colors.white.withAlpha((255 * 0.7).round()),
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white.withAlpha((255 * 0.7).round()),
          size: 20,
        ),
        suffixIcon: suffixIcon,

        // Latar belakang field yang transparan
        filled: true,
        fillColor: Colors.white.withAlpha((255 * 0.1).round()),

        // Border yang juga transparan
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withAlpha((255 * 0.2).round()),
          ),
        ),
        // Border saat diklik (menjadi putih solid)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
        // Border untuk error
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentRed, width: 2),
        ),
      ),
    );
  }
  // --- AKHIR DARI WIDGET BUILDER BARU ---

  @override
  Widget build(BuildContext context) {
    // --- (Tidak ada perubahan di sini) ---
    return Scaffold(
      body: Stack(
        children: [
          // 1. Latar Belakang Gradient (menutupi seluruh layar)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 2. Konten yang bisa di-scroll
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                    // Logo Anda
                    Image.asset(
                      'assets/LogoAnnibaTransparant.png',
                      height: 180,
                      width: 180,
                    ),
                    const SizedBox(height: 16),

                    // Teks Sambutan
                    Text(
                      'Selamat Datang',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading1.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masuk untuk mengelola bisnis Anda',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withAlpha((255 * 0.7).round()),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 3. Kartu Kaca (Glassmorphism)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((255 * 0.15).round()),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withAlpha(
                                (255 * 0.2).round(),
                              ),
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildGlassTextField(
                                  _emailController,
                                  'Email',
                                  Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: TextStyle(
                                      color: Colors.white.withAlpha(
                                        (255 * 0.7).round(),
                                      ),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline_rounded,
                                      color: Colors.white.withAlpha(
                                        (255 * 0.7).round(),
                                      ),
                                      size: 20,
                                    ),

                                    // --- Logika untuk menampilkan ikon ---
                                    suffixIcon: _passwordController.text.isEmpty
                                        ? null // <-- Jangan tampilkan ikon jika field kosong
                                        : IconButton(
                                            icon: Icon(
                                              _isPasswordVisible
                                                  ? Icons.visibility_off_rounded
                                                  : Icons.visibility_rounded,
                                              color: Colors.white.withAlpha(
                                                (255 * 0.7).round(),
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isPasswordVisible =
                                                    !_isPasswordVisible;
                                              });
                                            },
                                          ),

                                    // --- Akhir logika ikon ---
                                    filled: true,
                                    fillColor: Colors.white.withAlpha(
                                      (255 * 0.1).round(),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.white.withAlpha(
                                          (255 * 0.2).round(),
                                        ),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.accentRed,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.accentRed,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                _isLoading
                                    ? const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      )
                                    : buildGradientButton(
                                        'Login',
                                        Icons.login_rounded,
                                        _login,
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
