import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';

class DriverNavigationScreen extends StatefulWidget {
  const DriverNavigationScreen({super.key});

  @override
  State<DriverNavigationScreen> createState() => _DriverNavigationScreenState();
}

class _DriverNavigationScreenState extends State<DriverNavigationScreen> {
  int _currentStep = 0; // 0: To Store, 1: To Customer

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Placeholder
          Container(color: const Color(0xFFEEF2F7), child: const Center(child: Icon(Icons.map_outlined, size: 80, color: Colors.grey))),
          
          _buildInfoPanel(),
          
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ColorTokens.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 5))],
        ),
        child: Row(
          children: [
            const Icon(Icons.navigation, color: ColorTokens.accent, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_currentStep == 0 ? 'متجهًا إلى: بقالة "الوفاء"' : 'متجهًا إلى: حي المسجد', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('1.8 كم • ~8 دقائق', style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _buildProgressStep(0, 'الاستلام'),
                const SizedBox(width: 12),
                Expanded(child: Container(height: 2, color: _currentStep > 0 ? ColorTokens.accent : Colors.grey[200])),
                const SizedBox(width: 12),
                _buildProgressStep(1, 'التوصيل'),
              ],
            ),
            const SizedBox(height: 24),
            AppButton(
              label: _currentStep == 0 ? 'وصلت للمجر' : 'تم التسليم بنجاح',
              variant: _currentStep == 0 ? AppButtonVariant.primary : AppButtonVariant.success,
              onPressed: () {
                if (_currentStep == 0) {
                  setState(() => _currentStep = 1);
                } else {
                  _showCompletionDialog();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep(int step, String label) {
    final isActive = _currentStep == step;
    final isDone = _currentStep > step;
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isDone ? ColorTokens.accent : (isActive ? ColorTokens.secondary : Colors.grey[200]),
            shape: BoxShape.circle,
          ),
          child: isDone ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: isActive || isDone ? ColorTokens.textPrimary : ColorTokens.textMuted)),
      ],
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد التسليم'),
        content: const Text('هل استلمت مبلغ 1 200 دج وأكملت الطلب؟'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('لا')),
          TextButton(onPressed: () => context.go('/driver/dashboard'), child: const Text('نعم، تم التسليم')),
        ],
      ),
    );
  }
}


