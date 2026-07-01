import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wassali/core/theme/color_tokens.dart';

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
              _buildEarningsCard(),
              const SizedBox(height: 32),
              const Text('إحصائيات اليوم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildStatsGrid(),
              const SizedBox(height: 32),
              const Text('الطلبات الأخيرة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildRecentOrders(),
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
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مرحبًا أحمد 👋', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('15 جانفي 2024', style: TextStyle(color: ColorTokens.textSecondary)),
          ],
        ),
        const CircleAvatar(radius: 25, backgroundColor: ColorTokens.info, child: Icon(Icons.person, color: Colors.white)),
      ],
    );
  }

  Widget _buildOnlineToggle() {
    return GestureDetector(
      onTap: () => setState(() => _isOnline = !_isOnline),
      child: AnimatedContainer(
        duration: 400.ms,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: _isOnline ? ColorTokens.accent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (_isOnline) BoxShadow(color: ColorTokens.accent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
          ],
          border: Border.all(color: _isOnline ? Colors.transparent : ColorTokens.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.power_settings_new_rounded, color: _isOnline ? Colors.white : ColorTokens.textSecondary),
            const SizedBox(width: 12),
            Text(
              _isOnline ? 'أنت الآن متاح للعمل' : 'أنت غير متاح حاليًا',
              style: TextStyle(
                color: _isOnline ? Colors.white : ColorTokens.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ColorTokens.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: const [
          Text('أرباح اليوم', style: TextStyle(color: Colors.white70)),
          SizedBox(height: 8),
          Text('4 500 دج', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(child: _buildStatItem('طلبات مكتملة', '12', Icons.check_circle_outline_rounded)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatItem('تقييمك', '4.9', Icons.star_rate_rounded)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorTokens.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: ColorTokens.secondary),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: ColorTokens.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildRecentOrders() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorTokens.border),
          ),
          child: Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('طلب #ORD123', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('مطعم الشام • حي النصر', style: TextStyle(color: ColorTokens.textSecondary, fontSize: 12)),
                ],
              ),
              const Spacer(),
              const Text('450 دج', style: TextStyle(fontWeight: FontWeight.bold, color: ColorTokens.accent)),
            ],
          ),
        );
      },
    );
  }
}


