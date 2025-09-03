import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../../core/utils/validators.dart';
import 'register_page.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    print('🔐 [LOGIN_PAGE] Login attempt started');
    
    if (!_formKey.currentState!.validate()) {
      print('❌ [LOGIN_PAGE] Form validation failed');
      return;
    }

    print('✅ [LOGIN_PAGE] Form validation passed');
    print('📝 [LOGIN_PAGE] Login data: {email: ${_emailController.text.trim()}}');
    
    setState(() => _isLoading = true);
    print('⏳ [LOGIN_PAGE] Loading state set to true');

    try {
      print('🚀 [LOGIN_PAGE] Calling auth service...');
      
      await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      print('✅ [LOGIN_PAGE] Login successful, navigating to home');
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print('❌ [LOGIN_PAGE] Login error: $e');
      print('❌ [LOGIN_PAGE] Error type: ${e.runtimeType}');
      
      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        print('📝 [LOGIN_PAGE] Showing error snackbar: $errorMessage');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        print('✅ [LOGIN_PAGE] Loading state set to false');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo dan Title
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: const Icon(
                            Icons.account_balance_wallet,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text('Money Tracker', style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        Text('Masuk ke akun Anda', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 32),

                        // Email Field
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        CustomTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          prefixIcon: Icons.lock,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        CustomButton(
                          onPressed: _isLoading ? null : _login,
                          text: _isLoading ? 'Memproses...' : 'Masuk',
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 24),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Belum punya akun? ',
                              style: TextStyle(color: Colors.grey),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Daftar',
                                style: TextStyle(
                                  color: Color(0xFF667eea),
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
}
