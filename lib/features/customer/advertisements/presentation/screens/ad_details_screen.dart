import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:wassali/models/advertisement_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wassali/repositories/advertisement_repository.dart';
import 'package:wassali/features/customer/chat/chat_screen.dart';
import 'package:wassali/features/auth/auth_state.dart';
import 'package:wassali/core/network/api_client.dart';

class AdDetailsScreen extends ConsumerWidget {
  final AdvertisementModel ad;

  const AdDetailsScreen({super.key, required this.ad});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: ColorTokens.background,
      body: CustomScrollView(
        slivers: [
          // 1. Image Gallery Toolbar
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (ad.images.isNotEmpty)
                    PageView.builder(
                      itemCount: ad.images.length,
                      itemBuilder: (context, index) => Image.network(
                        ad.images[index],
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_outlined, size: 100, color: Colors.grey),
                    ),
                  // Gradient Overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.white),
                onPressed: () {
                  Share.share('${ad.title}\n${ad.price} دج\nتطبيق GoLiv: https://goliv.app/ad/${ad.id}');
                },
              ),
              IconButton(
                icon: Icon(
                  ad.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: ad.isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () async {
                  await ref.read(advertisementRepositoryProvider).toggleFavorite(ad.id);
                  // Ideally we'd have a family provider for the ad details to invalidate or use a StateProvider
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ad.isFavorite ? 'تمت الإزالة من المفضلة' : 'تمت الإضافة إلى المفضلة')),
                  );
                },
              ),
            ],
          ),

          // 2. Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${ad.price.toStringAsFixed(0)} دج',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: ColorTokens.primary,
                        ),
                      ),
                      if (ad.isNegotiable)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: ColorTokens.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'قابل للتفاوض',
                            style: TextStyle(
                              color: ColorTokens.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ad.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Metadata Row
                  Row(
                    children: [
                      _buildChip(Icons.location_on_outlined, ad.location),
                      const SizedBox(width: 8),
                      _buildChip(Icons.access_time, DateFormat('dd/MM/yyyy').format(ad.createdAt)),
                      const SizedBox(width: 8),
                      _buildChip(Icons.visibility_outlined, '${ad.views} مشاهدة'),
                    ],
                  ),
                  
                  const Divider(height: 40),
                  
                  const Text(
                    'الوصف',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ad.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: ColorTokens.textPrimary.withOpacity(0.8),
                      height: 1.6,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Seller Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: ColorTokens.primary.withOpacity(0.1),
                          child: Text(
                            (ad.sellerName ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: ColorTokens.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ad.sellerName ?? 'بائع مستخدم',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'عضو منذ 2024',
                                style: TextStyle(
                                  color: ColorTokens.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('مشروع البائع'),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 120), // Bottom bar space
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final authState = ref.read(authNotifierProvider);
                  if (!authState.isAuthenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء تسجيل الدخول أولاً')));
                    return;
                  }

                  if (authState.userId == ad.sellerId) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يمكنك مراسلة نفسك!')));
                    return;
                  }

                  // Start conversation
                  final textController = TextEditingController(text: 'سلام، هل " ${ad.title} " ما زال متاحاً؟');
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('بدء محادثة'),
                      content: TextField(
                        controller: textController,
                        maxLines: 3,
                        decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'اكتب رسالتك هنا...'),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                        ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('إرسال')),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    try {
                      final apiClient = ref.read(apiClientProvider);
                      final response = await apiClient.dio.post('/conversations', data: {
                        'adId': ad.id,
                        'text': textController.text,
                      });
                      
                      if (context.mounted) {
                        final convData = response.data['conversation'];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              conversationId: convData['id'],
                              adTitle: ad.title,
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                       if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل في بدء المحادثة')));
                       }
                    }
                  }
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: const Text('دردشة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTokens.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildIconButton(Icons.phone_outlined, ColorTokens.success, () {
              if (ad.sellerPhone != null) {
                _launchUrl('tel:${ad.sellerPhone}');
              }
            }),
            const SizedBox(width: 12),
            _buildIconButton(Icons.message_outlined, Colors.green, () {
              if (ad.sellerPhone != null) {
                _launchUrl('https://wa.me/${ad.sellerPhone}');
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: ColorTokens.textMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: ColorTokens.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onTap,
      ),
    );
  }
}
