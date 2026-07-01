import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:wassali/core/utils/currency_formatter.dart';
import 'package:wassali/models/store_model.dart';
import 'package:wassali/models/product_model.dart';
import 'package:wassali/repositories/store_repository_impl.dart';
import 'package:wassali/features/customer/cart/presentation/providers/cart_provider.dart';

// Provider for store products
final storeProductsProvider = FutureProvider.family<List<ProductModel>, String>((ref, storeId) {
  return ref.watch(storeRepositoryProvider).getStoreProducts(storeId);
});

class StoreDetailsScreen extends ConsumerWidget {
  final StoreModel store;

  const StoreDetailsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(storeProductsProvider(store.id));
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: ColorTokens.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: _buildStoreInfo(),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _CategoryTabDelegate(),
          ),
          productsAsync.when(
            data: (products) => products.isEmpty 
              ? const SliverFillRemaining(child: Center(child: Text('لا توجد منتجات في هذا المتجر حالياً')))
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildProductItem(context, ref, products[index]),
                      childCount: products.length,
                    ),
                  ),
                ),
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, st) => SliverFillRemaining(child: Center(child: Text('خطأ في تحميل المنتجات'))),
          ),
        ],
      ),
      bottomNavigationBar: cart.itemCount > 0 ? _buildCartBottomBar(context, cart) : null,
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: ColorTokens.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Colors.grey[200],
              child: const Icon(Icons.storefront_rounded, size: 64, color: ColorTokens.textMuted),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreInfo() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                store.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorTokens.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'مفتوح',
                  style: TextStyle(color: ColorTokens.accent, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
              Text(' ${store.rating}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_rounded, color: ColorTokens.textMuted, size: 18),
              Text(' ${store.deliveryTime}', style: const TextStyle(color: ColorTokens.textMuted)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'توصيل بـ ${CurrencyFormatter.format(store.deliveryFee.toDouble())} • الحد الأدنى ${CurrencyFormatter.format(store.minimumOrder.toDouble())}',
            style: const TextStyle(color: ColorTokens.textSecondary, fontSize: 13),
          ),

        ],
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, WidgetRef ref, ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: const TextStyle(color: ColorTokens.textMuted, fontSize: 12),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Text(
                  CurrencyFormatter.format(product.price.toDouble()),
                  style: const TextStyle(color: ColorTokens.secondary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 100,
              width: 100,
              color: Colors.grey[100],
              child: const Icon(Icons.fastfood_rounded, color: Colors.grey),
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(cartProvider.notifier).addProduct(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تمت إضافة ${product.name} للسلة')),
              );
            },
            icon: const Icon(Icons.add_circle_rounded, color: ColorTokens.secondary, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildCartBottomBar(BuildContext context, dynamic cart) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: ElevatedButton(
          onPressed: () => context.push('/customer/cart'),
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorTokens.secondary,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('سلة المشتريات (${cart.itemCount})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              Text(CurrencyFormatter.format(cart.totalAmount.toDouble()), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTabDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: ColorTokens.background,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 1,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Chip(
              label: const Text('جميع الأصناف'),
              backgroundColor: ColorTokens.secondary,
              labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }

  @override
  double get maxExtent => 76;
  @override
  double get minExtent => 76;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
