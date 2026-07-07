import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:go_router/go_router.dart';
import 'package:wassali/features/auth/auth_state.dart';

import 'package:wassali/features/customer/favorites/presentation/screens/favorites_screen.dart';
import 'package:wassali/features/customer/advertisements/presentation/screens/user_ads_screen.dart';
import 'package:wassali/features/customer/chat/conversations_list_screen.dart';

class ProfileTabScreen extends ConsumerWidget {
  const ProfileTabScreen({super.key});

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — قريباً'), behavior: SnackBarBehavior.floating),
    );
  }

  void _showPersonalInfo(BuildContext context, AuthState auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('المعلومات الشخصية', textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('الاسم'),
              subtitle: Text(auth.name ?? 'زائر'),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('رقم الهاتف'),
              subtitle: Text(auth.phone ?? 'غير متوفر'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
        ],
      ),
    );
  }

  void _showAddresses(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('عناوين التوصيل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.home, color: ColorTokens.primary),
              title: const Text('المنزل'),
              subtitle: const Text('حي المسجد، القرارة'),
              trailing: const Icon(Icons.check_circle, color: ColorTokens.success),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.work, color: ColorTokens.textMuted),
              title: const Text('العمل'),
              subtitle: const Text('وسط المدينة، بجوار البلدية'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.add),
              label: const Text('إضافة عنوان جديد'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مركز المساعدة', textAlign: TextAlign.right),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: Icon(Icons.phone), title: Text('اتصل بنا'), subtitle: Text('0555 12 34 56')),
            ListTile(leading: Icon(Icons.email), title: Text('راسلنا'), subtitle: Text('support@wassali.dz')),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق'))],
      ),
    );
  }

  void _showDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الحساب', style: TextStyle(color: Colors.red), textAlign: TextAlign.right),
        content: const Text('هل أنت متأكد من رغبتك في حذف حسابك نهائياً؟', textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلب حذف الحساب')));
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: ColorTokens.background,
      appBar: AppBar(
        title: const Text('حسابي', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            _buildProfileCard(auth),
            const SizedBox(height: 32),
            _buildActionGroup(context, [
              _ProfileAction(Icons.person_outline_rounded, 'المعلومات الشخصية', () => _showPersonalInfo(context, auth)),
              _ProfileAction(Icons.inventory_2_outlined, 'إعلاناتي', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserAdsScreen()))),
              _ProfileAction(Icons.favorite_border_rounded, 'الإعلانات المحفوظة', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()))),
              _ProfileAction(Icons.chat_bubble_outline_rounded, 'المحادثات', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConversationsListScreen()))),
            ]),
            const SizedBox(height: 24),
            _buildActionGroup(context, [
              _ProfileAction(Icons.language_rounded, 'اللغة', () => context.push('/customer/settings')),
              _ProfileAction(Icons.dark_mode_outlined, 'الوضع الليلي', () => context.push('/customer/settings')),
              _ProfileAction(Icons.settings_outlined, 'الإعدادات', () => context.push('/customer/settings')),
            ]),
            const SizedBox(height: 24),
            _buildActionGroup(context, [
              _ProfileAction(Icons.help_outline_rounded, 'مركز المساعدة', () => _showSupport(context)),
              _ProfileAction(Icons.info_outline_rounded, 'حول سوق القرارة', () => showAboutDialog(
                context: context,
                applicationName: 'سوق القرارة',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.storefront_rounded, size: 50, color: ColorTokens.primary),
                children: const [Text('السوق المحلي الأول في القرارة. بع واشتر بكل سهولة وأمان.')],
              )),
            ]),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTokens.error,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _showDeleteAccount(context),
              child: const Text('حذف الحساب', style: TextStyle(color: ColorTokens.textMuted)),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(AuthState auth) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: ColorTokens.primary,
            child: Icon(Icons.person_rounded, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.name ?? 'زائر',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(auth.userId != null ? 'معرف: ${auth.userId!.substring(0, 8)}...' : '', style: const TextStyle(color: ColorTokens.textMuted)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorTokens.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'حساب مفعل',
                    style: TextStyle(color: ColorTokens.success, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGroup(BuildContext context, List<_ProfileAction> actions) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)],
      ),
      child: Column(
        children: actions.asMap().entries.map((entry) {
          final idx = entry.key;
          final action = entry.value;
          return Column(
            children: [
              ListTile(
                onTap: action.onTap,
                leading: Icon(action.icon, color: ColorTokens.primary),
                title: Text(action.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: ColorTokens.textMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              ),
              if (idx < actions.length - 1)
                const Divider(height: 1, indent: 60, endIndent: 20),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ProfileAction {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _ProfileAction(this.icon, this.title, this.onTap);
}
