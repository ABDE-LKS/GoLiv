import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import '../../home_provider.dart';
import 'package:wassali/core/utils/store_mapper.dart';
import 'package:wassali/features/customer/store/presentation/screens/store_details_screen.dart';
import 'package:wassali/features/auth/auth_state.dart';
import 'package:wassali/features/customer/orders/orders_provider.dart';

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
              // 1. Greeting Header
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
                            'مرحباً، $customerName 👋',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: ColorTokens.primary, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'القرارة',
                                style: TextStyle(color: ColorTokens.textSecondary, fontWeight: FontWeight.w600),
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
                        hintText: 'ابحث عن متجر أو منتج...',
                        hintStyle: TextStyle(color: ColorTokens.textSecondary.withOpacity(0.5)),
                        prefixIcon: const Icon(Icons.search, color: ColorTokens.primary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      readOnly: true,
                      onTap: () => context.push('/customer/search'),
                    ),
                  ),
                ),
              ),

              // 3. BIG CUSTOM REQUEST BUTTON ⭐
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to Custom Request Chat
                      context.push('/custom-request');
                    },
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [ColorTokens.primary, ColorTokens.primary.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: ColorTokens.primary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Decorative Circle
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'اطلب أي شيء',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'أخبر السائق بما تحتاجه وسنقوم بشرائه لك.',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 13,
                                          height: 1.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'ابدأ الطلب',
                                          style: TextStyle(
                                            color: ColorTokens.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Icon placeholder for Motorcycle
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.two_wheeler_rounded, size: 40, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Dynamic Backend Data Section
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
                        Text('تعذر تحميل البيانات', style: TextStyle(color: ColorTokens.textSecondary)),
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
                  final offers = data['offers'] as List? ?? [];
                  final categories = data['categories'] as List? ?? [];
                  final featuredStores = data['featuredStores'] as List? ?? [];
                  final featuredProducts = data['featuredProducts'] as List? ?? [];
                  final banners = data['banners'] as List? ?? [];
                  final announcements = data['announcements'] as List? ?? [];

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      if (announcements.isNotEmpty) ...[
                        _buildAnnouncements(announcements),
                        const SizedBox(height: 16),
                      ],
                      // 8. Promotional Banner (Top Priority)
                      if (banners.isNotEmpty) ...[
                        _buildBannerSlider(banners),
                        const SizedBox(height: 24),
                      ],

                      // 6. Categories
                      if (categories.isNotEmpty) ...[
                        _buildSectionTitle('التصنيفات'),
                        _buildCategoriesList(categories),
                        const SizedBox(height: 24),
                      ],

                      // 4. Today's Offers
                      if (offers.isNotEmpty) ...[
                        _buildSectionTitle('عروض اليوم ⚡'),
                        _buildOffersSlider(offers),
                        const SizedBox(height: 24),
                      ],

                      // 5. Stores Section (Replaces Favorites)
                      if (featuredStores.isNotEmpty) ...[
                        _buildSectionTitle('المتاجر المميزة المتاحة'),
                        _buildStoresList(featuredStores, context),
                        const SizedBox(height: 24),
                      ],

                      // 7. Featured Products
                      if (featuredProducts.isNotEmpty) ...[
                        _buildSectionTitle('منتجات قد تعجبك'),
                        _buildFeaturedProductsGrid(featuredProducts),
                        const SizedBox(height: 24),
                      ],

                      if (authState.isAuthenticated) ...[
                        _buildRecentOrdersSection(ref, context),
                        const SizedBox(height: 40),
                      ] else
                        const SizedBox(height: 40),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
      height: 100,
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
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: ColorTokens.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: cat['image'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(cat['image'], fit: BoxFit.cover),
                        )
                      : Icon(Icons.category_rounded, color: ColorTokens.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  cat['name'],
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOffersSlider(List offers) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: ColorTokens.surface,
              borderRadius: BorderRadius.circular(20),
              image: offer['bannerImage'] != null
                  ? DecorationImage(
                      image: NetworkImage(offer['bannerImage']),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                    )
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      offer['store']?['name'] ?? 'عرض خاص',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    offer['title'],
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoresList(List stores, BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return GestureDetector(
          onTap: () {
            final storeModel = mapStoreFromBackend(Map<String, dynamic>.from(store));
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => StoreDetailsScreen(store: storeModel)),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: ColorTokens.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Image
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    image: store['banner'] != null
                        ? DecorationImage(image: NetworkImage(store['banner']), fit: BoxFit.cover)
                        : null,
                  ),
                  child: store['banner'] == null ? const Center(child: Icon(Icons.storefront, color: Colors.grey)) : null,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Logo
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                          ],
                        ),
                        child: store['logo'] != null
                            ? ClipOval(child: Image.network(store['logo'], fit: BoxFit.cover))
                            : Icon(Icons.store, color: ColorTokens.primary),
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  store['name'],
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      store['rating']?.toString() ?? '0.0',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.delivery_dining, size: 14, color: ColorTokens.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  '${store['deliveryFee']} دج',
                                  style: TextStyle(color: ColorTokens.textSecondary, fontSize: 12),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.access_time_rounded, size: 14, color: ColorTokens.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  '${store['minDeliveryTime']}-${store['maxDeliveryTime']} دقيقة',
                                  style: TextStyle(color: ColorTokens.textSecondary, fontSize: 12),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedProductsGrid(List products) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length > 4 ? 4 : products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final discount = product['discountPercentage'];
        return Container(
          decoration: BoxDecoration(
            color: ColorTokens.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Stack(
                    children: [
                      if (product['image'] != null)
                        Positioned.fill(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: Image.network(product['image'], fit: BoxFit.cover)))
                      else
                        const Center(child: Icon(Icons.fastfood_rounded, color: Colors.grey, size: 40)),
                      
                      if (discount != null && discount > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                            child: Text('-$discount%', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['store']?['name'] ?? '',
                      style: TextStyle(color: ColorTokens.textSecondary, fontSize: 11),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product['price']} دج',
                          style: TextStyle(color: ColorTokens.primary, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: ColorTokens.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.add_shopping_cart_rounded, color: ColorTokens.primary, size: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBannerSlider(List banners) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: PageView.builder(
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(banner['imageUrl']),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
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

  Widget _buildRecentOrdersSection(WidgetRef ref, BuildContext context) {
    final recentAsync = ref.watch(recentOrdersProvider);
    return recentAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (orders) {
        if (orders.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('طلباتك الأخيرة'),
            ...orders.map((order) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.receipt_long, color: ColorTokens.primary),
                title: Text(order.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${order.totalAmount.toStringAsFixed(0)} دج • ${order.status}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () => context.push('/customer/orders'),
              ),
            )),
          ],
        );
      },
    );
  }
}
