import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:wassali/core/network/api_error_mapper.dart';
import 'package:wassali/repositories/store_repository_impl.dart';
import 'package:wassali/features/customer/store/presentation/screens/store_details_screen.dart';

class StoresListScreen extends ConsumerWidget {
  const StoresListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(storesFutureProvider);

    return Scaffold(
      backgroundColor: ColorTokens.background,
      appBar: AppBar(
        title: const Text('المتاجر', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/customer/search'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(storesFutureProvider),
        child: storesAsync.when(
          loading: () => _buildShimmer(),
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: ColorTokens.error),
                      const SizedBox(height: 12),
                      Text(extractErrorMessage(e)),
                      TextButton(
                        onPressed: () => ref.invalidate(storesFutureProvider),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          data: (stores) {
            if (stores.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.storefront_outlined, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text('لا توجد متاجر.', style: TextStyle(color: ColorTokens.textMuted, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: stores.length,
              itemBuilder: (context, index) => _StoreCard(store: stores[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 5,
        itemBuilder: (_, __) => Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final dynamic store;
  const _StoreCard({required this.store});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => StoreDetailsScreen(store: store)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ColorTokens.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: store.coverImage.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(store.coverImage, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.store, color: ColorTokens.primary)),
                    )
                  : const Icon(Icons.store, color: ColorTokens.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(store.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(store.category, style: const TextStyle(color: ColorTokens.textMuted, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('${store.deliveryFee} دج • ${store.deliveryTime}', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: ColorTokens.textMuted),
          ],
        ),
      ),
    );
  }
}

class SearchStoresScreen extends ConsumerStatefulWidget {
  const SearchStoresScreen({super.key});

  @override
  ConsumerState<SearchStoresScreen> createState() => _SearchStoresScreenState();
}

class _SearchStoresScreenState extends ConsumerState<SearchStoresScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storesAsync = _query.isEmpty
        ? const AsyncValue<List>.data([])
        : ref.watch(_searchStoresProvider(_query));

    return Scaffold(
      appBar: AppBar(title: const Text('بحث')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'ابحث عن متجر...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          Expanded(
            child: storesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(extractErrorMessage(e))),
              data: (stores) {
                if (_query.isEmpty) {
                  return const Center(child: Text('اكتب اسم المتجر للبحث', style: TextStyle(color: ColorTokens.textMuted)));
                }
                if (stores.isEmpty) {
                  return const Center(child: Text('لا توجد نتائج', style: TextStyle(color: ColorTokens.textMuted)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: stores.length,
                  itemBuilder: (context, index) {
                    final store = stores[index];
                    return ListTile(
                      leading: const Icon(Icons.storefront),
                      title: Text(store.name),
                      subtitle: Text(store.category),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => StoreDetailsScreen(store: store)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

final _searchStoresProvider = FutureProvider.family<List, String>((ref, query) {
  return ref.watch(storeRepositoryProvider).getAllStores(search: query);
});
