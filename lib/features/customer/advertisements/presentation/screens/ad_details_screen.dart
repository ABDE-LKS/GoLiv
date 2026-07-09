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
import 'package:cached_network_image/cached_network_image.dart';

class AdDetailsScreen extends ConsumerStatefulWidget {
  final AdvertisementModel ad;

  const AdDetailsScreen({super.key, required this.ad});

  @override
  ConsumerState<AdDetailsScreen> createState() => _AdDetailsScreenState();
}

class _AdDetailsScreenState extends ConsumerState<AdDetailsScreen> {
  late AdvertisementModel _currentAd;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentAd = widget.ad;
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح الرابط')));
    }
  }

  Future<void> _markAsSold() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تمييز كمباع؟'),
        content: const Text('هل أنت متأكد أنك تريد تمييز هذا الإعلان كـ "تم البيع"؟ لن يظهر في نتائج البحث بعد الآن.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: ColorTokens.success),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(advertisementRepositoryProvider).updateAdvertisement(_currentAd.id, {'status': 'SOLD'});
        setState(() {
          _currentAd = AdvertisementModel(
            id: _currentAd.id,
            title: _currentAd.title,
            description: _currentAd.description,
            price: _currentAd.price,
            images: _currentAd.images,
            categoryId: _currentAd.categoryId,
            sellerId: _currentAd.sellerId,
            location: _currentAd.location,
            status: 'SOLD',
            createdAt: _currentAd.createdAt,
            views: _currentAd.views,
            isFavorite: _currentAd.isFavorite,
            isNegotiable: _currentAd.isNegotiable,
            sellerName: _currentAd.sellerName,
            sellerPhone: _currentAd.sellerPhone,
          );
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تمييز الإعلان كمباع بنجاح')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل في تحديث حالة الإعلان')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isOwner = authState.userId == _currentAd.sellerId;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(isOwner),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceAndStatus(),
                  const SizedBox(height: 12),
                  _buildTitle(),
                  const SizedBox(height: 16),
                  _buildMetadataChips(),
                  const Divider(height: 48, thickness: 1, color: Color(0xFFF1F1F1)),
                  _buildSectionTitle('الوصف'),
                  const SizedBox(height: 12),
                  _buildDescription(),
                  const SizedBox(height: 32),
                  _buildSellerCard(),
                  const SizedBox(height: 32),
                  if (isOwner && _currentAd.status != 'SOLD') _buildOwnerActions(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: !isOwner ? _buildBottomActions(authState) : null,
    );
  }

  Widget _buildSliverAppBar(bool isOwner) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (_currentAd.images.isNotEmpty)
              PageView.builder(
                onPageChanged: (index) => setState(() => _currentImageIndex = index),
                itemCount: _currentAd.images.length,
                itemBuilder: (context, index) => CachedNetworkImage(
                  imageUrl: _currentAd.images[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[100]),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              )
            else
              Container(
                color: Colors.grey[100],
                child: const Icon(Icons.image_outlined, size: 64, color: Colors.grey),
              ),
            // Gradient Overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.2), Colors.transparent, Colors.black.withOpacity(0.4)],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
            // Image Counter
            if (_currentAd.images.isNotEmpty)
              Positioned(
                bottom: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentImageIndex + 1} / ${_currentAd.images.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
            child: const Icon(Icons.share_outlined, color: Colors.black, size: 20),
          ),
          onPressed: () => Share.share('${_currentAd.title}\n${_currentAd.price} دج\nتطبيق GoLiv'),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
            child: Icon(
              _currentAd.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _currentAd.isFavorite ? Colors.red : Colors.black,
              size: 20,
            ),
          ),
          onPressed: () async {
            await ref.read(advertisementRepositoryProvider).toggleFavorite(_currentAd.id);
            // Local state update for feedback
            setState(() {
              _currentAd = AdvertisementModel(
                id: _currentAd.id,
                title: _currentAd.title,
                description: _currentAd.description,
                price: _currentAd.price,
                images: _currentAd.images,
                categoryId: _currentAd.categoryId,
                sellerId: _currentAd.sellerId,
                location: _currentAd.location,
                status: _currentAd.status,
                createdAt: _currentAd.createdAt,
                views: _currentAd.views,
                isFavorite: !_currentAd.isFavorite,
                isNegotiable: _currentAd.isNegotiable,
                sellerName: _currentAd.sellerName,
                sellerPhone: _currentAd.sellerPhone,
              );
            });
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildPriceAndStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_currentAd.price.toStringAsFixed(0)} دج',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: ColorTokens.primary, letterSpacing: -0.5),
            ),
            if (_currentAd.isNegotiable)
              const Text('قابل للتفاوض', style: TextStyle(color: ColorTokens.secondary, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        if (_currentAd.status == 'SOLD')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)),
            child: const Text('تم البيع', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12)),
            child: const Text('نشط', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      _currentAd.title,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ColorTokens.textPrimary, height: 1.3),
    );
  }

  Widget _buildMetadataChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildChip(Icons.location_on_rounded, _currentAd.location),
        _buildChip(Icons.calendar_today_rounded, DateFormat('dd MMM yyyy', 'ar').format(_currentAd.createdAt)),
        _buildChip(Icons.visibility_rounded, '${_currentAd.views} مشاهدة'),
        if (_currentAd.condition != null) _buildChip(Icons.info_outline_rounded, _currentAd.condition!),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColorTokens.textPrimary));
  }

  Widget _buildDescription() {
    return Text(
      _currentAd.description,
      style: TextStyle(fontSize: 16, color: ColorTokens.textPrimary.withOpacity(0.7), height: 1.6),
    );
  }

  Widget _buildSellerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F1F1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: ColorTokens.primary.withOpacity(0.1),
                child: Text((_currentAd.sellerName ?? 'U')[0], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ColorTokens.primary)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_currentAd.sellerName ?? 'بائع مستخدم', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text('4.8 (12 تقييم)', style: TextStyle(fontSize: 13, color: ColorTokens.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: ColorTokens.textMuted)),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSellerStat('24', 'إعلان'),
              _buildSellerStat('18', 'تم بيعها'),
              _buildSellerStat('2 سنة', 'عضوية'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSellerStat(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ColorTokens.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 12, color: ColorTokens.textMuted)),
      ],
    );
  }

  Widget _buildOwnerActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_rounded),
            label: const Text('تعديل الإعلان'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.background,
              foregroundColor: ColorTokens.textPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _markAsSold,
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text('تمييز كمباع'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.success,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(AuthState auth) {
    if (_currentAd.status == 'SOLD') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFF1F1F1)))),
        child: const Text('هذا المنتج تم بيعه بالفعل', textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _handleChat(auth),
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: const Text('دردشة الآن'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildActionIcon(Icons.phone_outlined, ColorTokens.success, () {
            if (_currentAd.sellerPhone != null) _launchUrl('tel:${_currentAd.sellerPhone}');
          }),
          const SizedBox(width: 12),
          _buildActionIcon(Icons.message_outlined, Colors.green, () {
            if (_currentAd.sellerPhone != null) _launchUrl('https://wa.me/${_currentAd.sellerPhone}');
          }),
        ],
      ),
    );
  }

  Future<void> _handleChat(AuthState auth) async {
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى تسجيل الدخول أولاً للمراسلة')));
      return;
    }
    
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.post('/conversations', data: {
        'adId': _currentAd.id,
        'text': 'مرحباً، هل هذا " ${_currentAd.title} " متاح؟',
      });
      
      if (mounted) {
        final convData = response.data['conversation'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: convData['id'],
              adTitle: _currentAd.title,
              adImage: _currentAd.images.isNotEmpty ? _currentAd.images[0] : null,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر بدء المحادثة')));
    }
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: ColorTokens.textMuted),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13, color: ColorTokens.textPrimary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: IconButton(icon: Icon(icon, color: color), onPressed: onTap, iconSize: 24),
    );
  }
}
