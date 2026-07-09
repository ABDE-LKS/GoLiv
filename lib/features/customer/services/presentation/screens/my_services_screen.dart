import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:wassali/repositories/service_repository.dart';
import 'package:wassali/models/service_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wassali/features/customer/services/presentation/screens/create_service_screen.dart';

final myServicesProvider = FutureProvider.autoDispose<List<ServiceModel>>((ref) async {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.getMyServices();
});

class MyServicesScreen extends ConsumerWidget {
  const MyServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(myServicesProvider);

    return Scaffold(
      backgroundColor: ColorTokens.background,
      appBar: AppBar(
        title: const Text('خدماتي', style: TextStyle(fontWeight: FontWeight.bold, color: ColorTokens.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: ColorTokens.textPrimary),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateServiceScreen()));
        },
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: servicesAsync.when(
        data: (services) {
          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.handyman_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('لم تقم بإضافة أي خدمات بعد', style: TextStyle(color: ColorTokens.textMuted, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final service = services[index];
              return ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                  child: service.images.isNotEmpty
                      ? ClipRRect(borderRadius: BorderRadius.circular(10), child: CachedNetworkImage(imageUrl: service.images.first, fit: BoxFit.cover))
                      : const Icon(Icons.handyman_rounded, color: Colors.grey),
                ),
                title: Text(service.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${service.city} • المشاهدات: ${service.viewsCount}', style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.edit_rounded, color: Colors.grey, size: 20),
                onTap: () {},
              ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('خطأ في التحميل')),
      ),
    );
  }
}
