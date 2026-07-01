import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../auth_state.dart';
import 'network_test_screen.dart';
import '../../../../core/network/api_error_mapper.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Logo
                GestureDetector(
                  onLongPress: () {
                    debugPrint('🔎 Entering Network Forensic Lab');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NetworkTestScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ColorTokens.primary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: ColorTokens.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.delivery_dining_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Welcome Message
                Text(
                  'مرحباً بك مجدداً',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter', // Or Arabic font if available
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'سجل دخولك لتوصيل طلباتك في القرارة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColorTokens.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 48),

                // Phone Field
                CustomTextField(
                  controller: _phoneController,
                  hintText: 'رقم الهاتف (05XXXXXXXX)',
                  prefixIcon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'يرجى إدخال رقم الهاتف';
                    if (!RegExp(r'^(05|06|07)[0-9]{8}$').hasMatch(value)) {
                      return 'رقم هاتف جزائري غير صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'كلمة المرور',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'يرجى إدخال كلمة المرور';
                    if (value.length < 6) return 'كلمة المرور قصيرة جداً';
                    return null;
                  },
                ),
                
                // Forgot Password
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text(
                      'نسيت كلمة المرور؟',
                      style: TextStyle(
                        color: ColorTokens.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Login Button
                if (ref.watch(authNotifierProvider).isLoading)
                  const CircularProgressIndicator()
                else
                  CustomButton(
                    text: 'تسجيل الدخول',
                    onPressed: _handleLogin,
                  ),

                
                const SizedBox(height: 24),

                // Create Account Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ليس لديك حساب؟',
                      style: TextStyle(color: ColorTokens.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text(
                        'بحث عن حساب جديد',
                        style: TextStyle(
                          color: ColorTokens.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                CustomButton(
                  text: 'إنشاء حساب جديد',
                  onPressed: () => context.push('/register'),
                  isSecondary: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    debugPrint('🔎 [TRACE] 1. Login Button Pressed');
    if (_formKey.currentState!.validate()) {
      debugPrint('🔎 [TRACE] 2. Form Validated');
      try {
        await ref.read(authNotifierProvider.notifier).login(
          _phoneController.text,
          _passwordController.text,
        );
        // Navigation is handled by router redirect
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(extractErrorMessage(e)),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}



