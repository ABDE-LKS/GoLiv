import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';

class IncomingOrderScreen extends StatefulWidget {
  const IncomingOrderScreen({super.key});

  @override
  State<IncomingOrderScreen> createState() => _IncomingOrderScreenState();
}

class _IncomingOrderScreenState extends State<IncomingOrderScreen> with SingleTickerProviderStateMixin {
  late AnimationController _countdownController;

  @override
  void initState() {
    super.initState();
    _countdownController = AnimationController(vsync: this, duration: const Duration(seconds: 30));
    _countdownController.reverse(from: 1.0);
    _countdownController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        context.pop();
      }
    });
  }

  @override
  void dispose() {
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Text(
                'طلب جديد!',
                style: AppTextStyles.h1.copyWith(color: Colors.white),
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
              const SizedBox(height: 48),
              
              _buildOrderCard(),
              
              const Spacer(),
              
              _buildCountdown(),
              
              const SizedBox(height: 48),
              
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'رفض',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      label: 'قبول',
                      variant: AppButtonVariant.success,
                      onPressed: () => context.go('/driver/navigation'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: ColorTokens.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_basket, color: ColorTokens.secondary, size: 16),
                    const SizedBox(width: 8),
                    Text('بقالة', style: AppTextStyles.labelSmall.copyWith(color: ColorTokens.secondary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Spacer(),
              Text('المكسب: 350 دج', style: AppTextStyles.bodyMedium.copyWith(color: ColorTokens.accent, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Text('محتاج:\n- 2 لتر حليب\n- خبز\n- 1 كيلو طماطم\n- كوكا كولا', style: AppTextStyles.bodyLarge),
          const Divider(height: 40),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18, color: ColorTokens.textMuted),
              const SizedBox(width: 8),
              Text('المسافة: 2.3 كم', style: AppTextStyles.labelSmall),
              const Spacer(),
              Text('حي المسجد، القرارة', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: 0.2, end: 0).fadeIn();
  }

  Widget _buildCountdown() {
    return AnimatedBuilder(
      animation: _countdownController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: _countdownController.value,
                strokeWidth: 8,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(ColorTokens.accent),
              ),
            ),
            Text(
              '${(_countdownController.value * 30).ceil()}',
              style: AppTextStyles.h1.copyWith(color: Colors.white),
            ),
          ],
        );
      },
    );
  }
}


