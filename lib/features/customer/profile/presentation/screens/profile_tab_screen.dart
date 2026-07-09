import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:go_router/go_router.dart';
import 'package:wassali/features/auth/auth_state.dart';
import 'package:wassali/features/customer/favorites/presentation/screens/favorites_screen.dart';
import 'package:wassali/features/customer/advertisements/presentation/screens/user_ads_screen.dart';
import 'package:wassali/features/customer/chat/conversations_list_screen.dart';
import 'package:wassali/features/customer/services/presentation/screens/my_services_screen.dart';
import 'package:wassali/features/customer/jobs/presentation/screens/my_jobs_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileTabScreen extends ConsumerWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, auth),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('إدارة النشاط'),
                  const SizedBox(height: 12),
                  _buildActionCard([
                    _ProfileAction(Icons.inventory_2_outlined, 'إعلاناتي', 'تحكم في ما تعرضه للبيع', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserAdsScreen()))),
                    _ProfileAction(Icons.handyman_outlined, 'خدماتي', 'إدارة خدماتك المهنية', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyServicesScreen()))),
                    _ProfileAction(Icons.work_outline_rounded, 'وظائفي', 'الوظائف التي قمت بنشرها', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyJobsScreen()))),
                    _ProfileAction(Icons.favorite_border_rounded, 'المفضلة', 'الإعلانات التي تهمك', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()))),
                    _ProfileAction(Icons.chat_bubble_outline_rounded, 'المحادثات', 'تواصل مع البائعين والمشترين', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConversationsListScreen()))),
                  ]),
                  const SizedBox(height: 32),
                  _buildSectionHeader('الحساب والإعدادات'),
                  const SizedBox(height: 12),
                  _buildActionCard([
                    _ProfileAction(Icons.person_outline_rounded, 'المعلومات الشخصية', 'تعديل بياناتك والتحقق', () {}),
                    _ProfileAction(Icons.settings_outlined, 'الإعدادات العامة', 'اللغة، التنبيهات، والخصوصية', () => context.push('/customer/settings')),
                    _ProfileAction(Icons.help_outline_rounded, 'مركز المساعدة', 'الدعم الفني والأسئلة الشائعة', () {}),
                  ]),
                  const SizedBox(height: 40),
                  _buildLogoutButton(ref, context),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {},
                    child: const Text('حذف الحساب', style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AuthState auth) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: ColorTokens.primary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [ColorTokens.primary, Color(0xFF1E3A8A)],
                ),
              ),
            ),
            Positioned(
              top: 80,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.blue[50],
                      child: Text(
                        (auth.name ?? 'Z')[0].toUpperCase(),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: ColorTokens.primary),
                      ),
                    ),
                  ).animate().scale(delay: 100.ms, duration: 400.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 12),
                  Text(
                    auth.name ?? 'زائر',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ).animate().fadeIn(delay: 300.ms),
                  Text(
                    auth.phone ?? 'لم يتم ربط الهاتف',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatItem('12', 'نشط', Colors.blue),
        _buildStatItem('5', 'مباع', Colors.green),
        _buildStatItem('120', 'مشاهدة', Colors.orange),
      ],
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildStatItem(String val, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: ColorTokens.textMuted, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: ColorTokens.textPrimary)),
      ],
    );
  }

  Widget _buildActionCard(List<_ProfileAction> actions) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
      ),
      child: Column(
        children: actions.asMap().entries.map((e) {
          final isLast = e.key == actions.length - 1;
          final a = e.value;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: ColorTokens.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
                  child: Icon(a.icon, color: ColorTokens.primary, size: 22),
                ),
                title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: Text(a.subtitle, style: const TextStyle(color: ColorTokens.textMuted, fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: ColorTokens.textMuted),
                onTap: a.onTap,
              ),
              if (!isLast) const Divider(height: 1, indent: 70, endIndent: 20, color: Color(0xFFF3F4F6)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton(WidgetRef ref, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: () async {
          await ref.read(authNotifierProvider.notifier).logout();
          if (context.mounted) context.go('/login');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.redAccent,
          elevation: 0,
          minimumSize: const Size.fromHeight(60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFFEE2E2))),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 20),
            SizedBox(width: 8),
            Text('تسجيل الخروج', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _ProfileAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _ProfileAction(this.icon, this.title, this.subtitle, this.onTap);
}
