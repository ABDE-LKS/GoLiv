import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/rating_stars.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Placeholder
          Container(
            color: const Color(0xFFE8F4FD),
            child: const Center(
              child: Icon(Icons.map_outlined, size: 100, color: Colors.blueAccent),
            ),
          ),
          
          _buildTopBar(context),
          
          _buildDraggableSheet(),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: ColorTokens.primary),
              onPressed: () => context.go('/customer/home'),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: ColorTokens.accent, shape: BoxShape.circle),
                ).animate(onPlay: (c) => c.repeat()).scale(duration: 600.ms),
                const SizedBox(width: 8),
                Text('جاري التوصيل', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5)),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              
              // Driver Info
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: ColorTokens.secondary,
                    child: Text('أ ب', style: TextStyle(color: Colors.white, fontSize: 20)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('أحمد بلقاسم', style: AppTextStyles.h3),
                        const RatingStars(rating: 4.8, size: 14),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ColorTokens.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('~12 دقيقة', style: AppTextStyles.labelSmall.copyWith(color: ColorTokens.accent, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('دراجة نارية — 09234-224-09', style: AppTextStyles.labelSmall.copyWith(color: ColorTokens.textSecondary)),
              
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'اتصل',
                      icon: Icons.phone_outlined,
                      variant: AppButtonVariant.secondary,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('اتصل بالسائق على: 09234-224-09')),
                        );
                      },
                      size: AppButtonSize.medium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'راسل',
                      icon: Icons.chat_bubble_outline,
                      onPressed: () => context.push('/customer/chat'),
                      size: AppButtonSize.medium,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              Text('تتبع الطلب', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              
              _buildTimeline(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        _buildTimelineStep('تم استلام الطلب', '2:30 م', true, true),
        _buildTimelineStep('السائق في طريقه للمتجر', '2:35 م', true, true),
        _buildTimelineStep('السائق يتسوق حاليًا', 'جاري...', true, false, isCurrent: true),
        _buildTimelineStep('في طريقه إليك', '', false, false),
        _buildTimelineStep('تم التسليم', '', false, false, isLast: true),
      ],
    );
  }

  Widget _buildTimelineStep(String title, String time, bool isDone, bool showLine, {bool isCurrent = false, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isDone ? ColorTokens.accent : (isCurrent ? ColorTokens.secondary : Colors.grey[200]),
                  shape: BoxShape.circle,
                  border: isCurrent ? Border.all(color: Colors.white, width: 4) : null,
                  boxShadow: isCurrent ? [BoxShadow(color: ColorTokens.secondary.withOpacity(0.4), blurRadius: 10)] : null,
                ),
                child: isDone ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone ? ColorTokens.accent : Colors.grey[200],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: isDone || isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isDone || isCurrent ? ColorTokens.textPrimary : ColorTokens.textMuted,
                    ),
                  ),
                  Text(time, style: AppTextStyles.labelSmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


