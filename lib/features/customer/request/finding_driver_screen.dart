import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import '../../../core/theme/text_styles.dart';

class FindingDriverScreen extends StatefulWidget {
  const FindingDriverScreen({super.key});

  @override
  State<FindingDriverScreen> createState() => _FindingDriverScreenState();
}

class _FindingDriverScreenState extends State<FindingDriverScreen> {
  @override
  void initState() {
    super.initState();
    _simulateFindingDriver();
  }

  void _simulateFindingDriver() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      context.go('/customer/tracking');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated concentric rings
            Stack(
              alignment: Alignment.center,
              children: [
                ...List.generate(3, (index) {
                  return Container(
                    width: 100.0 + (index * 60),
                    height: 100.0 + (index * 60),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ColorTokens.secondary.withOpacity(0.1),
                        width: 2,
                      ),
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.2, 1.2),
                    duration: (1000 + (index * 400)).ms,
                    curve: Curves.easeInOut,
                  )
                  .fadeIn(duration: 800.ms)
                  .fadeOut(delay: 500.ms);
                }),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: ColorTokens.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.motorcycle, color: Colors.white, size: 40),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              ],
            ),
            const SizedBox(height: 60),
            Text('نبحث عن سائق قريب منك...', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            Text('عادةً يستغرق أقل من 2 دقيقة', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: const BoxDecoration(
                    color: ColorTokens.secondary,
                    shape: BoxShape.circle,
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .fadeIn(delay: (index * 200).ms, duration: 400.ms)
                .fadeOut(delay: 200.ms);
              }),
            ),
            const SizedBox(height: 100),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'إلغاء الطلب',
                style: AppTextStyles.bodyMedium.copyWith(color: ColorTokens.error, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


