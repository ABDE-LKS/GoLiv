import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/price_tag.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  bool _isOnline = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildOnlineToggle(),
              const SizedBox(height: 32),
              _buildStatsRow(),
              const SizedBox(height: 32),
              _buildEarningsCard(),
              const SizedBox(height: 32),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مرحبًا أحمد بلقاسم', style: AppTextStyles.h2),
            Text('الجمعة، 15 يناير 2024', style: AppTextStyles.labelSmall),
          ],
        ),
        const CircleAvatar(
          radius: 24,
          backgroundColor: ColorTokens.secondary,
          child: Text('أ ب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildOnlineToggle() {
    return GestureDetector(
      onTap: () {
        setState(() => _isOnline = !_isOnline);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: _isOnline ? ColorTokens.accent : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isOnline ? [BoxShadow(color: ColorTokens.accent.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))] : null,
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (_isOnline)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                  ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 1000.ms).fadeOut(),
                const Icon(Icons.power_settings_new, color: Colors.white, size: 32),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _isOnline ? 'أنت الآن متاح لتلقي الطلبات' : 'أنت الآن غير متاح (أوفلاين)',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Opacity(
      opacity: _isOnline ? 1.0 : 0.5,
      child: Row(
        children: [
          _buildStatItem('طلبات اليوم', '12', Icons.shopping_bag_outlined),
          const SizedBox(width: 12),
          _buildStatItem('التقييم', '4.8', Icons.star_outline),
          const SizedBox(width: 12),
          _buildStatItem('ساعات العمل', '6.5', Icons.timer_outlined),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Icon(icon, color: ColorTokens.secondary, size: 20),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 9, color: ColorTokens.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Opacity(
      opacity: _isOnline ? 1.0 : 0.5,
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: ColorTokens.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('أرباح اليوم المتوقعة', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            const PriceTag(amount: 3200, size: PriceTagSize.large, color: Colors.white),
            const SizedBox(height: 16),
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('العمولة المستحقة', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text('640 دج', style: AppTextStyles.labelSmall.copyWith(color: ColorTokens.error, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('آخر العمليات', style: AppTextStyles.h3),
        const SizedBox(height: 16),
        ...List.generate(3, (index) => _buildActivityItem(index)),
      ],
    );
  }

  Widget _buildActivityItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: ColorTokens.background, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.check_circle_outline, color: ColorTokens.accent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('طلب بقالة #ORD-00${12 - index}', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text('حي المسجد، القرارة', style: AppTextStyles.labelSmall),
              ],
            ),
          ),
          const PriceTag(amount: 350, size: PriceTagSize.medium, color: ColorTokens.accent),
        ],
      ),
    );
  }
}


