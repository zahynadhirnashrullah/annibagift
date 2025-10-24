// lib/screens/login_screen.dart
import 'dart:ui'; // <-- TAMBAHKAN IMPORT INI UNTUK EFEK BLUR
import 'package:flutter/material.dart';
// Import service yang benar
import '../services/auth_service.dart';
import '../services/firebase_admin_service.dart'; // Import admin service
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
// --- PERBAIKAN: Sesuaikan jalur impor berdasarkan struktur Anda ---
// (Jika main_screen.dart ada di 'lib/pages/', ini harusnya '../pages/main_screen.dart')
import '../pages/main_screen.dart'; 
import '../models/models.dart'; // Import model untuk Role

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- TIDAK ADA PERUBAHAN PADA LOGIKA ---
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email = _emailController.text;
        final password = _passwordController.text;

        final user = await AuthService.instance.login(
          email,
          password,
        );

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
  // --- AKHIR DARI LOGIKA (TIDAK BERUBAH) ---

  // --- WIDGET BUILDER BARU UNTUK TEXTFIELD KACA ---
  // Kita buat widget helper baru di sini agar tidak merusak
  // `buildTextField` di `shared_widgets.dart` yang dipakai layar lain.
  Widget _buildGlassTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isObscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
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
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),

        // Latar belakang field yang transparan
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),

        // Border yang juga transparan
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
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
    // --- MODIFIKASI TAMPILAN DIMULAI DI SINI ---
    return Scaffold(
      // Kita gunakan Stack agar bisa menumpuk gradient, blur, dan konten
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
              // Kita beri padding agar tidak terlalu mepet di tepi
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Beri jarak dari atas
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                    // Logo Anda
                    Image.asset(
                      'assets/LogoAnnibaTransparant.png',
                      height: 180, // Ukuran logo sedikit disesuaikan
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
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 3. Kartu Kaca (Glassmorphism)
                    // ClipRRect diperlukan agar efek blur tidak "bocor"
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        // Ini adalah efek blur-nya
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            // Warna kaca semi-transparan
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            // Border tipis untuk memberi kesan "tepi" kaca
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Menggunakan TextField kustom kita
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
                                // Menggunakan TextField kustom kita
                                _buildGlassTextField(
                                  _passwordController,
                                  'Password',
                                  Icons.lock_outline_rounded,
                                  isObscure: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32),
                                _isLoading
                                    ? const CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      )
                                    // Menggunakan tombol gradient Anda yang sudah ada
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
                    // Beri jarak di bawah
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
    // --- MODIFIKASI TAMPILAN SELESAI DI SINI ---
  }
}