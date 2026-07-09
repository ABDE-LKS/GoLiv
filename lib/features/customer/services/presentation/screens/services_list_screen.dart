import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:wassali/repositories/service_repository.dart';
import 'package:wassali/models/service_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

final servicesProvider = FutureProvider.autoDispose<List<ServiceModel>>((ref) async {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.fetchServices();
});

class ServicesListScreen extends ConsumerWidget {
  const ServicesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      backgroundColor: ColorTokens.background,
      appBar: AppBar(
        title: const Text('الخدمات المحلية', style: TextStyle(fontWeight: FontWeight.bold, color: ColorTokens.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: ColorTokens.textPrimary),
      ),
      body: servicesAsync.when(
        data: (services) {
          if (services.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final service = services[index];
              return _ServiceCard(service: service)
                  .animate()
                  .fade(duration: 400.ms, delay: (50 * index).ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: ColorTokens.primary)),
        error: (e, st) => Center(child: Text('حدث خطأ: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.handyman_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('لا توجد خدمات متاحة حالياً', style: TextStyle(fontSize: 18, color: ColorTokens.textMuted, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to Details
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (service.images.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: service.images.first,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              else
                Container(
                  height: 160,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (service.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: ColorTokens.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              service.category!.name,
                              style: const TextStyle(color: ColorTokens.primary, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(service.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      service.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColorTokens.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 16, color: ColorTokens.textMuted),
                        const SizedBox(width: 4),
                        Text(service.city, style: const TextStyle(color: ColorTokens.textMuted, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
