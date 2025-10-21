// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
// Import service yang benar
import '../services/auth_service.dart'; 
import '../services/firebase_admin_service.dart'; // Import admin service
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'main_screen.dart';
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

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email = _emailController.text;
        final password = _passwordController.text;
        
        // Ganti ke AuthService.instance.login
        final user = await AuthService.instance.login(
          email,
          password,
        );

        if (user != null) {
          // Cek apakah user aktif
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
            // PERBAIKAN: Jika user adalah admin, login juga ke admin-app
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                const Icon(
                  Icons.card_giftcard_rounded,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Anniba Gift',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan login untuk melanjutkan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 204),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Container(
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      )
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildTextField(
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
                        buildTextField(
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
                          ? const CircularProgressIndicator()
                          : buildGradientButton(
                              'Login', 
                              Icons.login_rounded, 
                              _login,
                            ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}