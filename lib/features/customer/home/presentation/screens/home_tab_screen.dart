import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import '../../home_provider.dart';
import 'package:wassali/features/auth/auth_state.dart';

import 'package:wassali/models/advertisement_model.dart';
import 'package:wassali/features/customer/advertisements/presentation/screens/ad_details_screen.dart';

class HomeTabScreen extends ConsumerWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeProvider);
    final authState = ref.watch(authNotifierProvider);
    final customerName = authState.name ?? 'ضيف';

    return Scaffold(
      backgroundColor: ColorTokens.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(homeProvider);
          },
          child: CustomScrollView(
            slivers: [
              // 1. Marketplace Header
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'سوق القرارة',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Inter',
                              color: ColorTokens.primary,
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: ColorTokens.textSecondary, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'تبحث في القرارة وما حولها',
                                style: TextStyle(color: ColorTokens.textSecondary, fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: ColorTokens.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          color: ColorTokens.textPrimary,
                          onPressed: () => context.push('/customer/notifications'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Search Bar
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorTokens.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'ابحث عن سيارات، هواتف، عقارات...',
                        hintStyle: TextStyle(color: ColorTokens.textSecondary.withOpacity(0.5)),
                        prefixIcon: const Icon(Icons.search, color: ColorTokens.primary),
                        suffixIcon: const Icon(Icons.tune_rounded, color: ColorTokens.textMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      readOnly: true,
                      onTap: () => context.push('/customer/search'),
                    ),
                  ),
                ),
              ),

              // Dynamic Home Data
              homeDataAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text('تعذر تحميل الإعلانات', style: TextStyle(color: ColorTokens.textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(homeProvider),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (data) {
                  final categories = data['categories'] as List? ?? [];
                  final announcements = data['announcements'] as List? ?? [];
                  // Map raw featuredAdvertisements to Advertisement models
                  final latestAdsRaw = data['featuredAdvertisements'] as List? ?? [];
                  final latestAds = latestAdsRaw.map((e) => AdvertisementModel.fromJson(Map<String, dynamic>.from(e))).toList();

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      if (announcements.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildAnnouncements(announcements),
                      ],
                      const SizedBox(height: 24),

                      // Categories
                      if (categories.isNotEmpty) ...[
                        _buildSectionTitle('تصفح الأقسام'),
                        _buildCategoriesList(categories),
                        const SizedBox(height: 24),
                      ],

                      // Quick Filters
                      _buildQuickFilters(),
                      const SizedBox(height: 24),

                      // Latest Ads Grid
                      _buildSectionTitle('أحدث الإعلانات'),
                      if (latestAds.isEmpty)
                        _buildEmptyState()
                      else
                        _buildMarketplaceGrid(context, latestAds),
                      
                      const SizedBox(height: 80), // Padding for BottomNavBar and FAB
                    ]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          Text(
            'عرض الكل',
            style: TextStyle(
              color: ColorTokens.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(List categories) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: ColorTokens.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: cat['image'] != null
                      ? ClipOval(child: Image.network(cat['image'], fit: BoxFit.cover))
                      : Icon(Icons.category_rounded, color: ColorTokens.primary, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  cat['name'],
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickFilters() {
    final filters = ['الأقرب إليك', 'أقل سعر', 'للمقايضة فقط', 'مستعمل', 'جديد'];
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: index == 0 ? ColorTokens.secondary : ColorTokens.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: index == 0 ? Colors.transparent : Colors.grey.withOpacity(0.2)),
            ),
            child: Center(
              child: Text(
                filters[index],
                style: TextStyle(
                  color: index == 0 ? Colors.white : ColorTokens.textPrimary,
                  fontSize: 13,
                  fontWeight: index == 0 ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMarketplaceGrid(BuildContext context, List<AdvertisementModel> products) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final ad = products[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdDetailsScreen(ad: ad),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: ColorTokens.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      image: ad.images.isNotEmpty
                          ? DecorationImage(image: NetworkImage(ad.images.first), fit: BoxFit.cover)
                          : null,
                    ),
                    child: Stack(
                      children: [
                        if (ad.images.isEmpty)
                          const Center(child: Icon(Icons.image_outlined, color: Colors.grey, size: 40)),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Icon(
                              ad.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 18,
                              color: ad.isFavorite ? Colors.red : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Ad Content
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${ad.price.toStringAsFixed(0)} دج',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: ColorTokens.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ad.title,
                          style: TextStyle(fontSize: 13, color: ColorTokens.textPrimary, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(child: Text(ad.location, style: const TextStyle(fontSize: 11, color: Colors.grey, overflow: TextOverflow.ellipsis))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('اليوم', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('لم يتم العثور على أية إعلانات.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            const Text('كن أول من يضيف إعلاناً في مدينتك!', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncements(List announcements) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: announcements.map((a) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorTokens.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorTokens.secondary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.campaign_outlined, color: ColorTokens.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (a['body'] != null)
                        Text(a['body'], style: const TextStyle(fontSize: 12, color: ColorTokens.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
