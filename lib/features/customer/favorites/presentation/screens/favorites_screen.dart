import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:wassali/repositories/advertisement_repository.dart';
import 'package:wassali/features/customer/advertisements/presentation/screens/ad_details_screen.dart';
import 'package:wassali/models/advertisement_model.dart';

final favoriteAdsProvider = FutureProvider<List<AdvertisementModel>>((ref) async {
  final repository = ref.watch(advertisementRepositoryProvider);
  return repository.getFavorites();
});

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteAdsProvider);

    return Scaffold(
      backgroundColor: ColorTokens.background,
      appBar: AppBar(
        title: const Text('الإعلانات المحفوظة', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: favoritesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('حدث خطأ أثناء تحميل المفضلة')),
        data: (ads) {
          if (ads.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('لا توجد إعلانات محفوظة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Text('احفظ الإعلانات التي تهمك للرجوع إليها لاحقاً', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: ads.length,
            itemBuilder: (context, index) {
              final ad = ads[index];
              return _buildAdCard(context, ad, ref);
            },
          );
        },
      ),
    );
  }

  Widget _buildAdCard(BuildContext context, AdvertisementModel ad, WidgetRef ref) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AdDetailsScreen(ad: ad)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    if (ad.images.isEmpty) const Center(child: Icon(Icons.image_outlined, color: Colors.grey)),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () async {
                          await ref.read(advertisementRepositoryProvider).toggleFavorite(ad.id);
                          ref.invalidate(favoriteAdsProvider);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.favorite_rounded, color: Colors.red, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(ad.location, style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
