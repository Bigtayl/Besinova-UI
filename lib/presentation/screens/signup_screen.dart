import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/storage_service.dart';
import '../../presentation/providers/user_provider.dart';
import 'signin_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String? _errorText;

  // Tema renkleri
  static const Color midnightBlue = Color(0xFF2C3E50);
  static const Color settingsColor = Color(0xFFBD93F9);
  static const Color tropicalLime = Color(0xFFA3EBB1);

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await StorageService.init();

      // Check if email already exists
      final existingEmail = StorageService.prefs.getString('user_email');
      if (existingEmail == _emailController.text.trim()) {
        setState(() {
          _errorText = 'Bu e-posta adresi zaten kullanımda';
        });
        return;
      }

      // Save credentials
      await StorageService.prefs
          .setString('user_email', _emailController.text.trim());
      await StorageService.prefs
          .setString('user_password', _passwordController.text);

      // Create user data
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateUserField(
        name: _nameController.text,
        email: _emailController.text.trim(),
        gender: 'Belirtilmemiş',
        age: 0,
        avatar: '👤',
        loginCount: 0,
        lastLogin: DateTime.now().toString(),
      );

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _errorText = 'Kayıt sırasında bir hata oluştu';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: midnightBlue,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              tropicalLime.withValues(alpha: 0.8),
              midnightBlue,
            ],
            stops: const [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: tropicalLime.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo/Icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: tropicalLime.withValues(alpha: 0.2),
                          border: Border.all(
                            color: tropicalLime.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.person_add,
                          size: 48,
                          color: tropicalLime,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [tropicalLime, settingsColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          'Hesap Oluştur',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Yeni hesabınızı oluşturun',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Name Field
                      _buildTextField(
                        controller: _nameController,
                        label: "Ad Soyad",
                        icon: Icons.person,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Ad soyad gerekli';
                          }
                          if (v.length < 2) {
                            return 'Ad soyad en az 2 karakter olmalı';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      _buildTextField(
                        controller: _emailController,
                        label: "E-posta",
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'E-posta adresi gerekli';
                          }
                          if (!v.contains('@') || !v.contains('.')) {
                            return 'Geçerli e-posta adresi girin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      _buildTextField(
                        controller: _passwordController,
                        label: "Şifre",
                        icon: Icons.lock,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Şifre gerekli';
                          }
                          if (v.length < 6) {
                            return 'Şifre en az 6 karakter olmalı';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Confirm Password Field
                      _buildTextField(
                        controller: _confirmController,
                        label: "Şifre Tekrarı",
                        icon: Icons.lock_outline,
                        obscureText: _obscureConfirm,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirm = !_obscureConfirm;
                            });
                          },
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Şifre tekrarı gerekli';
                          }
                          if (v != _passwordController.text) {
                            return 'Şifreler eşleşmiyor';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Error Message
                      if (_errorText != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.withValues(alpha: 0.8),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorText!,
                                  style: TextStyle(
                                    color: Colors.red.withValues(alpha: 0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_errorText != null) const SizedBox(height: 20),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tropicalLime,
                            foregroundColor: midnightBlue,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor: tropicalLime.withValues(alpha: 0.3),
                          ),
                          onPressed: _isLoading ? null : _signUp,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: midnightBlue,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Kayıt Ol",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'veya',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Sign In Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Zaten hesabınız var mı? ',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 15,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignInScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Giriş Yap',
                              style: TextStyle(
                                color: settingsColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: tropicalLime, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
