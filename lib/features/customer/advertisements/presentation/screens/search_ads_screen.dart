import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:wassali/repositories/advertisement_repository.dart';
import 'package:wassali/features/customer/home/home_provider.dart';
import 'package:wassali/features/customer/advertisements/presentation/screens/ad_details_screen.dart';
import 'package:wassali/models/advertisement_model.dart';

class SearchAdsScreen extends ConsumerStatefulWidget {
  const SearchAdsScreen({super.key});

  @override
  ConsumerState<SearchAdsScreen> createState() => _SearchAdsScreenState();
}

class _SearchAdsScreenState extends ConsumerState<SearchAdsScreen> {
  final _searchController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final searchParams = {
      if (_searchController.text.isNotEmpty) 'search': _searchController.text,
      if (_selectedCategoryId != null) 'categoryId': _selectedCategoryId,
      if (_minPriceController.text.isNotEmpty) 'minPrice': double.tryParse(_minPriceController.text),
      if (_maxPriceController.text.isNotEmpty) 'maxPrice': double.tryParse(_maxPriceController.text),
    };

    final adsAsync = ref.watch(advertisementsProvider(searchParams));

    return Scaffold(
      backgroundColor: ColorTokens.background,
      appBar: AppBar(
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'ابحث عن أي شيء...',
              prefixIcon: Icon(Icons.search, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
            onSubmitted: (_) => setState(() {}),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: adsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('عذراً، حدث خطأ أثناء البحث')),
        data: (ads) {
          if (ads.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('لم نجد أي نتائج لبحثك', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Text('حاول البحث بكلمات مختلفة أو تعديل الفلاتر', style: TextStyle(color: Colors.grey)),
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
              return _buildAdCard(context, ad);
            },
          );
        },
      ),
    );
  }

  Widget _buildAdCard(BuildContext context, AdvertisementModel ad) {
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
                child: ad.images.isEmpty ? const Center(child: Icon(Icons.image_outlined, color: Colors.grey)) : null,
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
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(child: Text(ad.location, style: const TextStyle(fontSize: 11, color: Colors.grey, overflow: TextOverflow.ellipsis))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('فلاتر البحث', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 24),
            const Text('السعر بالدينار', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildFilterInput(_minPriceController, 'الأقل')),
                const SizedBox(width: 16),
                Expanded(child: _buildFilterInput(_maxPriceController, 'الأعلى')),
              ],
            ),
            const SizedBox(height: 24),
            const Text('القسم', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // We need access to categories here. 
            // For simplicity, let's assume we can fetch them or pass them.
            // Since we're in a ConsumerWidget, we can watch the homeProvider.
            _buildCategorySelector(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {});
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTokens.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('تطبيق الفلاتر', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final homeData = ref.watch(homeProvider);
    final categories = homeData.asData?.value['categories'] as List? ?? [];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final category = isAll ? null : categories[index - 1];
          final id = isAll ? null : category['id'] as String;
          final name = isAll ? 'الكل' : category['name'] as String;
          final isSelected = _selectedCategoryId == id;

          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              label: Text(name),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedCategoryId = id),
              selectedColor: ColorTokens.primary.withOpacity(0.2),
              labelStyle: TextStyle(color: isSelected ? ColorTokens.primary : Colors.black87),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterInput(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
