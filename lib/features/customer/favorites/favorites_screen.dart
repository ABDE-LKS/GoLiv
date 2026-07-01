import 'package:flutter/material.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/empty_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool hasFavorites = true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
      ),
      body: hasFavorites
          ? ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 2,
              itemBuilder: (context, index) {
                return _buildFavoriteCard(context, index);
              },
            )
          : const EmptyState(
              title: 'لا توجد قوائم محفوظة بعد',
              subtitle: 'أضف أولى قوائمك لتطلبها بسرعة لاحقًا',
              actionLabel: 'أضف الآن',
            ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, int index) {
    final titles = ['بقالة معتادة', 'صيدلية'];
    final texts = ['- 2 لتر حليب\n- خبز\n- بيض', 'دواء للضغط + فيتامين C'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: ColorTokens.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(index == 0 ? Icons.shopping_basket : Icons.medical_services, color: ColorTokens.secondary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(titles[index], style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('خيارات القائمة — قريباً')),
                  );
                },
                icon: const Icon(Icons.more_vert, color: ColorTokens.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            texts[index],
            style: AppTextStyles.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('استخدام القالب — قريباً')),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('استخدام هذا القالب'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


