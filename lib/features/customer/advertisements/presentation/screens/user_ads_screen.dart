import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:wassali/repositories/advertisement_repository.dart';
import 'package:wassali/models/advertisement_model.dart';
import 'package:go_router/go_router.dart';
import 'package:wassali/features/auth/auth_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

final userAdsProvider = FutureProvider<List<AdvertisementModel>>((ref) async {
  final repository = ref.watch(advertisementRepositoryProvider);
  final authState = ref.watch(authNotifierProvider);
  if (!authState.isAuthenticated || authState.userId == null) return [];
  return repository.getAdvertisements(sellerId: authState.userId);
});

class UserAdsScreen extends ConsumerWidget {
  const UserAdsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adsAsync = ref.watch(userAdsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('إعلاناتي', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: ColorTokens.textPrimary,
      ),
      body: adsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildErrorState(ref),
        data: (ads) {
          if (ads.isEmpty) return _buildEmptyState(context);
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: ads.length,
            itemBuilder: (context, index) => _UserAdCard(ad: ads[index]).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
            child: Icon(Icons.inventory_2_outlined, size: 64, color: ColorTokens.primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          const Text('لا توجد إعلانات نشطة', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          const SizedBox(height: 8),
          const Text('ابدأ ببيع أغراضك التي لا تحتاجها الآن', style: TextStyle(color: ColorTokens.textMuted)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => GoRouter.of(context).push('/customer/ad/create'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('أضف إعلانك الأول', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('عذراً، تعذر تحميل بياناتك'),
          TextButton(onPressed: () => ref.invalidate(userAdsProvider), child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}

class _UserAdCard extends ConsumerWidget {
  final AdvertisementModel ad;
  const _UserAdCard({required this.ad});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSold = ad.status == 'SOLD';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Image Container
              Stack(
                children: [
                   Container(
                    width: 110,
                    height: 110,
                    color: Colors.grey[100],
                    child: ad.images.isNotEmpty
                        ? CachedNetworkImage(imageUrl: ad.images.first, fit: BoxFit.cover)
                        : const Icon(Icons.image_outlined, color: Colors.grey),
                  ),
                  if (isSold)
                    Container(
                      width: 110,
                      height: 110,
                      color: Colors.black.withOpacity(0.4),
                      child: const Center(child: Text('تم البيع', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ad.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('${ad.price.toStringAsFixed(0)} دج', style: const TextStyle(color: ColorTokens.primary, fontWeight: FontWeight.w900, fontSize: 16)),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 12, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text('${ad.views} مشاهدة', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Actions Menu
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: ColorTokens.textMuted),
                  onSelected: (val) => _handleAction(context, ref, val),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('تعديل')])),
                    if (!isSold)
                      const PopupMenuItem(value: 'sold', child: Row(children: [Icon(Icons.check_circle_outline, size: 18), SizedBox(width: 8), Text('تمييز كمباع')])),
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text('حذف', style: TextStyle(color: Colors.red))])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref, String action) async {
    final repo = ref.read(advertisementRepositoryProvider);
    if (action == 'sold') {
      await repo.updateAdvertisement(ad.id, {'status': 'SOLD'});
      ref.invalidate(userAdsProvider);
    } else if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('حذف الإعلان'),
          content: const Text('هل أنت متأكد من حذف هذا الإعلان؟ لا يمكن التراجع عن هذا الإجراء.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('حذف')),
          ],
        ),
      );
      if (confirm == true) {
        await repo.deleteAdvertisement(ad.id);
        ref.invalidate(userAdsProvider);
      }
    }
  }
}
