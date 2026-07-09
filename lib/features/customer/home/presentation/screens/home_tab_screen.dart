import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import '../../home_provider.dart';
import 'package:wassali/features/auth/auth_state.dart';
import 'package:wassali/models/advertisement_model.dart';
import 'package:wassali/features/customer/advertisements/presentation/screens/ad_details_screen.dart';
import 'package:wassali/features/customer/services/presentation/screens/services_list_screen.dart';
import 'package:wassali/features/customer/jobs/presentation/screens/jobs_list_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeTabScreen extends ConsumerWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(homeProvider),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(context, authState),
              _buildSearchBar(context),
              _buildHeroShortcuts(context),
              homeDataAsync.when(
                loading: () => _buildLoadingState(),
                error: (e, _) => _buildErrorState(ref),
                data: (data) => _buildContent(context, data),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthState auth) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سوق القرارة',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: ColorTokens.primary, letterSpacing: -0.5),
                ).animate().fadeIn().slideX(begin: -0.2),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.location_on_rounded, color: ColorTokens.textMuted, size: 14),
                    SizedBox(width: 4),
                    Text('القرارة، الجزائر', style: TextStyle(color: ColorTokens.textMuted, fontWeight: FontWeight.w600, fontSize: 12)),
                  ],
                ),
              ],
            ),
            _buildNotificationBadge(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationBadge(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: IconButton(
        icon: const Icon(Icons.notifications_none_rounded, color: ColorTokens.textPrimary),
        onPressed: () => context.push('/customer/notifications'),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverToBoxAdapter(
        child: GestureDetector(
          onTap: () => context.push('/customer/search'),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: const Row(
              children: [
                Icon(Icons.search_rounded, color: ColorTokens.primary),
                SizedBox(width: 12),
                Text('ابحث عن أي شيء تحتاجه...', style: TextStyle(color: ColorTokens.textMuted, fontSize: 14)),
                Spacer(),
                Icon(Icons.tune_rounded, color: ColorTokens.textMuted, size: 20),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
      ),
    );
  }

  Widget _buildHeroShortcuts(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Expanded(
              child: _ShortcutCard(
                title: 'دليل الخدمات',
                subtitle: 'حرفيين ومهنيين',
                icon: Icons.handyman_rounded,
                color: const Color(0xFF6366F1), // Indigo
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicesListScreen())),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ShortcutCard(
                title: 'فرص العمل',
                subtitle: 'ابحث عن وظيفة',
                icon: Icons.work_rounded,
                color: const Color(0xFF10B981), // Emerald Green
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JobsListScreen())),
              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> data) {
    final categories = data['categories'] as List? ?? [];
    final latestAdsRaw = data['featuredAdvertisements'] as List? ?? [];
    final ads = latestAdsRaw.map((e) => AdvertisementModel.fromJson(Map<String, dynamic>.from(e))).toList();

    return SliverList(
      delegate: SliverChildListDelegate([
        if (categories.isNotEmpty) ...[
          _buildSectionHeader('الأقسام'),
          _buildCategories(categories),
          const SizedBox(height: 24),
        ],
        _buildSectionHeader('أحدث الإعلانات'),
        if (ads.isEmpty) _buildEmptyState() else _buildAdsGrid(context, ads),
        const SizedBox(height: 100),
      ]),
    );
  }

  Widget _buildCategories(List categories) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Container(
            width: 80,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                  ),
                  child: Center(
                    child: cat['image'] != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(16), child: CachedNetworkImage(imageUrl: cat['image'], width: 40, height: 40, fit: BoxFit.cover))
                        : const Icon(Icons.category_rounded, color: ColorTokens.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Text(cat['name'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1),
              ],
            ),
          ).animate().fadeIn(delay: (index * 50).ms).scale();
        },
      ),
    );
  }

  Widget _buildAdsGrid(BuildContext context, List<AdvertisementModel> ads) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: ads.length,
      itemBuilder: (context, index) => _AdCard(ad: ads[index]).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: ColorTokens.textPrimary)),
          TextButton(onPressed: () {}, child: const Text('عرض الكل', style: TextStyle(color: ColorTokens.primary, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildLoadingState() => const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
  Widget _buildErrorState(WidgetRef ref) => SliverFillRemaining(child: Center(child: TextButton(onPressed: () => ref.invalidate(homeProvider), child: const Text('خطأ في التحميل، حاول مجدداً'))));
  Widget _buildEmptyState() => const Center(child: Text('لا توجد إعلانات متاحة حالياً'));
}

class _AdCard extends StatelessWidget {
  final AdvertisementModel ad;
  const _AdCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdDetailsScreen(ad: ad))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 11,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: ad.images.isNotEmpty
                          ? CachedNetworkImage(imageUrl: ad.images.first, fit: BoxFit.cover)
                          : const Icon(Icons.image_outlined, color: Colors.grey, size: 40),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                      child: Icon(ad.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 16, color: ad.isFavorite ? Colors.red : Colors.black45),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 9,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${ad.price.toStringAsFixed(0)} دج', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: ColorTokens.primary)),
                    const SizedBox(height: 4),
                    Text(ad.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: ColorTokens.textMuted),
                        const SizedBox(width: 4),
                        Expanded(child: Text(ad.location, style: const TextStyle(fontSize: 11, color: ColorTokens.textMuted, overflow: TextOverflow.ellipsis))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ShortcutCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: ColorTokens.textPrimary)),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: ColorTokens.textMuted, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
