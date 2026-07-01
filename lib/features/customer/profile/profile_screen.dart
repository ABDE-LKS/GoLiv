import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import '../../../core/theme/text_styles.dart';
import '../../auth/auth_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, auth),
            _buildStats(),
            _buildMenu(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthState auth) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: ColorTokens.secondary,
            child: Text(
              auth.name != null && auth.name!.isNotEmpty ? auth.name!.substring(0, 1) : 'U',
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(auth.name ?? 'مستخدم', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(auth.role?.name.toUpperCase() ?? '', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تعديل الملف الشخصي — قريباً')),
              );
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('تعديل الملف الشخصي'),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatCard('الطلبات', '-'),
          const SizedBox(width: 12),
          _buildStatCard('التوفير', '- دج'),
          const SizedBox(width: 12),
          _buildStatCard('منذ', '-'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
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
            Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: ColorTokens.secondary)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: ColorTokens.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildMenuItem(Icons.shopping_bag_outlined, 'طلباتي', () => context.push('/customer/orders')),
          _buildMenuItem(Icons.account_balance_wallet_outlined, 'محفظتي', () {}),
          _buildMenuItem(Icons.favorite_border, 'المفضلة', () {}),
          _buildMenuItem(Icons.settings_outlined, 'الإعدادات', () {}),
          const Divider(height: 40),
          _buildMenuItem(Icons.help_outline, 'مركز المساعدة', () {}),
          _buildMenuItem(Icons.info_outline, 'حول التطبيق', () {}),
          _buildMenuItem(
            Icons.logout, 
            'تسجيل الخروج', 
            () => ref.read(authNotifierProvider.notifier).logout(), 
            isDanger: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isDanger = false}) {
    return ListTile(
      leading: Icon(icon, color: isDanger ? ColorTokens.error : ColorTokens.textPrimary),
      title: Text(title, style: TextStyle(color: isDanger ? ColorTokens.error : ColorTokens.textPrimary)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: ColorTokens.textMuted),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}



