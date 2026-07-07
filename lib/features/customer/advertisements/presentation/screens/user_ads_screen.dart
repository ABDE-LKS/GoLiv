import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:wassali/repositories/advertisement_repository.dart';
import 'package:wassali/models/advertisement_model.dart';
import 'package:go_router/go_router.dart';

import 'package:wassali/features/auth/auth_state.dart';

final userAdsProvider = FutureProvider<List<AdvertisementModel>>((ref) async {
  final repository = ref.watch(advertisementRepositoryProvider);
  final authState = ref.watch(authNotifierProvider);
  
  if (!authState.isAuthenticated || authState.userId == null) {
    return [];
  }
  
  return repository.getAdvertisements(sellerId: authState.userId); 
});

class UserAdsScreen extends ConsumerWidget {
  const UserAdsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adsAsync = ref.watch(userAdsProvider);

    return Scaffold(
      backgroundColor: ColorTokens.background,
      appBar: AppBar(
        title: const Text('إعلاناتي', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: adsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('حدث خطأ أثناء تحميل إعلاناتك')),
        data: (ads) {
          if (ads.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('لم تنشر أي إعلان بعد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      GoRouter.of(context).push('/customer/ad/create');
                    },
                    child: const Text('انشر إعلانك الأول'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ads.length,
            itemBuilder: (context, index) {
              final ad = ads[index];
              return _buildAdListItem(context, ad, ref);
            },
          );
        },
      ),
    );
  }

  Widget _buildAdListItem(BuildContext context, AdvertisementModel ad, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: ad.images.isNotEmpty ? DecorationImage(image: NetworkImage(ad.images.first), fit: BoxFit.cover) : null,
              color: Colors.grey[200],
            ),
            child: ad.images.isEmpty ? const Icon(Icons.image_outlined, color: Colors.grey) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ad.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text('${ad.price.toStringAsFixed(0)} دج', style: const TextStyle(color: ColorTokens.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ad.status == 'ACTIVE' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ad.status == 'ACTIVE' ? 'نشط' : 'قيد المراجعة',
                    style: TextStyle(color: ad.status == 'ACTIVE' ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (val) async {
              switch (val) {
                case 'edit':
                  // TODO: Implement Edit
                  break;
                case 'sold':
                  await ref.read(advertisementRepositoryProvider).updateAdvertisement(ad.id, {'status': 'SOLD'});
                  ref.invalidate(userAdsProvider);
                  break;
                case 'delete':
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('حذف الإعلان'),
                      content: const Text('هل أنت متأكد من حذف هذا الإعلان؟'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref.read(advertisementRepositoryProvider).deleteAdvertisement(ad.id);
                    ref.invalidate(userAdsProvider);
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('تعديل')),
              const PopupMenuItem(value: 'sold', child: Text('تم البيع')),
              const PopupMenuItem(value: 'delete', child: Text('حذف', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }
}
