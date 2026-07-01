import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _currentStep = 1;
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
        ),
        title: const Text('استعادة كلمة المرور'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: _buildStepContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
        return _buildStep4();
      default:
        return _buildStep1();
    }
  }

  // Step 1: Enter Phone Number
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.lock_reset_rounded, size: 80, color: ColorTokens.primary),
        const SizedBox(height: 32),
        const Text(
          'أدخل رقم هاتفك',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'سنقوم بإرسال رمز التحقق (OTP) إلى هاتفك لتأكيد هويتك',
          textAlign: TextAlign.center,
          style: TextStyle(color: ColorTokens.textSecondary),
        ),
        const SizedBox(height: 48),
        CustomTextField(
          controller: _phoneController,
          hintText: 'رقم الهاتف',
          prefixIcon: Icons.phone_android_rounded,
          keyboardType: TextInputType.phone,
          validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: 'إرسال الرمز',
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              setState(() => _currentStep = 2);
            }
          },
        ),
      ],
    );
  }

  // Step 2 & 3: Receive and Verify OTP (Combined for simplicity in UI flow)
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.app_registration_rounded, size: 80, color: ColorTokens.primary),
        const SizedBox(height: 32),
        const Text(
          'تحقق من الرمز',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          'أدخل الرمز المكون من 6 أرقام المرسل إلى ${_phoneController.text}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: ColorTokens.textSecondary),
        ),
        const SizedBox(height: 48),
        CustomTextField(
          controller: _otpController,
          hintText: 'رمز التحقق (123456)',
          prefixIcon: Icons.security_rounded,
          keyboardType: TextInputType.number,
          validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: 'تأكيد الرمز',
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              setState(() => _currentStep = 4);
            }
          },
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم إرسال رمز جديد'), behavior: SnackBarBehavior.floating),
            );
          },
          child: const Text('إعادة إرسال الرمز'),
        ),
      ],
    );
  }

  // Step 3 is internal to the transition between Step 2 and 4 (validation)
  Widget _buildStep3() => const Center(child: CircularProgressIndicator());

  // Step 4: Create New Password
  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.vpn_key_rounded, size: 80, color: ColorTokens.primary),
        const SizedBox(height: 32),
        const Text(
          'كلمة مرور جديدة',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'يرجى إنشاء كلمة مرور قوية وسهلة التذكر',
          textAlign: TextAlign.center,
          style: TextStyle(color: ColorTokens.textSecondary),
        ),
        const SizedBox(height: 48),
        CustomTextField(
          controller: _newPasswordController,
          hintText: 'كلمة المرور الجديدة',
          prefixIcon: Icons.lock_outline_rounded,
          isPassword: true,
          validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _confirmPasswordController,
          hintText: 'تأكيد كلمة المرور',
          prefixIcon: Icons.lock_reset_rounded,
          isPassword: true,
          validator: (v) {
            if (v != _newPasswordController.text) return 'كلمات المرور غير متطابقة';
            return null;
          },
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: 'تغيير كلمة المرور',
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
              );
              context.go('/login');
            }
          },
        ),
      ],
    );
  }
}


