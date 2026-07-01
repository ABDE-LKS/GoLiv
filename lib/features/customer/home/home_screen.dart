import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/notification_bell.dart';
import '../orders/orders_provider.dart';
import 'home_provider.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNewRequestButton(ref),
                  const SizedBox(height: 32),
                  _buildActiveOrderBanner(context, ref),
                  const SizedBox(height: 32),
                  homeDataAsync.when(
                    data: (data) => _buildHomeContent(context, data),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('حدث خطأ في تحميل البيانات', style: AppTextStyles.bodyMedium),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => ref.refresh(homeProvider),
                            child: const Text('إعادة المحاولة'),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, Map<String, dynamic> data) {
    final categories = data['categories'] as List<dynamic>? ?? [];
    final banners = data['banners'] as List<dynamic>? ?? [];
    final featuredStores = data['featuredStores'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (banners.isNotEmpty) ...[
          _buildBannersSection(banners),
          const SizedBox(height: 32),
        ],
        _buildCategoriesSection(context, categories),
        const SizedBox(height: 32),
        if (featuredStores.isNotEmpty) ...[
          _buildFeaturedStoresSection(context, featuredStores),
        ] else ...[
          _buildRecentOrdersSection(),
        ]
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      expandedHeight: 120,
      backgroundColor: ColorTokens.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: ColorTokens.accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('التوصيل إلى', style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
                    Text('حي المسجد، القرارة', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const NotificationBell(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewRequestButton(WidgetRef ref) {
    final activeOrder = ref.watch(activeOrderProvider);
    final hasActive = activeOrder != null;

    return Tooltip(
      message: hasActive ? 'لديك طلب نشط بالفعل' : '',
      child: Consumer(
        builder: (context, ref, _) {
          return GestureDetector(
            onTap: hasActive ? null : () => context.push('/customer/request/new'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 64,
              decoration: BoxDecoration(
                color: hasActive ? const Color(0xFF94A3B8) : const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(20),
                boxShadow: hasActive ? null : [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasActive ? Icons.access_time : Icons.add_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    hasActive ? 'طلبك قيد التوصيل...' : 'طلب جديد',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ).animate().scale(
                  begin: const Offset(1, 1),
                  end: const Offset(0.97, 0.97),
                  duration: const Duration(milliseconds: 80),
                ),
          );
        },
      ),
    );
  }

  Widget _buildActiveOrderBanner(BuildContext context, WidgetRef ref) {
    final activeOrder = ref.watch(activeOrderProvider);
    if (activeOrder == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorTokens.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorTokens.secondary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.delivery_dining, color: ColorTokens.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('طلبك #ORD-001', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text('السائق في الطريق إليك', style: AppTextStyles.labelSmall),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/customer/tracking'),
            child: const Text('تتبع'),
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildBannersSection(List<dynamic> banners) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: ColorTokens.primary.withOpacity(0.1),
                  image: banner['imageUrl'] != null
                      ? DecorationImage(
                          image: NetworkImage(banner['imageUrl']),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: banner['imageUrl'] == null
                    ? Center(
                        child: Text(
                          banner['title'] ?? 'حدث مميز',
                          style: AppTextStyles.h3.copyWith(color: ColorTokens.primary),
                        ),
                      )
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(BuildContext context, List<dynamic> categories) {
    if (categories.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('الأصناف', style: AppTextStyles.h3),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('عرض جميع الأصناف — قريباً')),
                );
              },
              child: const Text('كل الأصناف'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return _buildCategoryItem(
                cat['name'] ?? 'صنف',
                _getCategoryIcon(cat['name'] ?? ''),
                Colors.blue,
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String name) {
    if (name.contains('بقالة')) return Icons.shopping_basket;
    if (name.contains('صيدلية')) return Icons.medical_services;
    if (name.contains('مطعم')) return Icons.restaurant;
    if (name.contains('هدايا')) return Icons.card_giftcard;
    return Icons.category;
  }

  Widget _buildCategoryItem(String label, IconData icon, Color color) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(left: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }

  Widget _buildFeaturedStoresSection(BuildContext context, List<dynamic> stores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('متاجر مميزة', style: AppTextStyles.h3),
            TextButton(
              onPressed: () {},
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stores.length,
          itemBuilder: (context, index) {
            final store = stores[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: ListTile(
                onTap: () {
                  // Navigate to store details
                },
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: ColorTokens.primary.withOpacity(0.1),
                    image: store['logoUrl'] != null
                        ? DecorationImage(image: NetworkImage(store['logoUrl']), fit: BoxFit.cover)
                        : null,
                  ),
                  child: store['logoUrl'] == null ? const Icon(Icons.store, color: ColorTokens.primary) : null,
                ),
                title: Text(store['name'] ?? 'متجر', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(store['address'] ?? '', style: AppTextStyles.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text('${store['rating'] ?? 5.0}', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('آخر الطلبات', style: AppTextStyles.h3),
        const SizedBox(height: 16),
        // Placeholder for recent orders list
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: const Center(child: Text('لا توجد طلبات سابقة مؤخرًا')),
        ),
      ],
    );
  }
}


