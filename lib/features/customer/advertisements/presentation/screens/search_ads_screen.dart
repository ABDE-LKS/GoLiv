import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:wassali/repositories/advertisement_repository.dart';
import 'package:wassali/features/customer/home/home_provider.dart';
import 'package:wassali/features/customer/advertisements/presentation/screens/ad_details_screen.dart';
import 'package:wassali/features/customer/services/presentation/screens/services_list_screen.dart';
import 'package:wassali/features/customer/jobs/presentation/screens/jobs_list_screen.dart';
import 'package:wassali/models/advertisement_model.dart';
import 'package:wassali/models/service_model.dart';
import 'package:wassali/models/job_model.dart';
import 'package:shimmer/shimmer.dart';

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
  Timer? _debounce;
  int _currentTab = 0; // 0: Ads, 1: Services, 2: Jobs
  final List<String> _recentSearches = ['سيارات', 'كهربائي', 'مطور', 'هواتف']; // Mock history

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() {});
    });
  }

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
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            _buildTabSelector(),
            Expanded(
              child: _buildCurrentTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: ColorTokens.textMuted, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: const InputDecoration(
                            hintText: 'ابحث عن سيارات، عقارات، إلكترونيات...',
                            hintStyle: TextStyle(color: ColorTokens.textMuted, fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () => setState(() => _searchController.clear()),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showFilterSheet(),
                child: Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: ColorTokens.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.tune_rounded, color: ColorTokens.primary),
                ),
              ),
            ],
          ),
          if (_selectedCategoryId != null || _minPriceController.text.isNotEmpty)
            Container(
              height: 48,
              padding: const EdgeInsets.only(top: 12),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_selectedCategoryId != null)
                    _buildActiveFilterChip('القسم محدد', () => setState(() => _selectedCategoryId = null)),
                  if (_minPriceController.text.isNotEmpty)
                    _buildActiveFilterChip('فلتر السعر', () {
                      setState(() {
                        _minPriceController.clear();
                        _maxPriceController.clear();
                      });
                    }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onClear) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: ColorTokens.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabItem(0, 'السوق', Icons.storefront_rounded),
          _buildTabItem(1, 'الخدمات', Icons.handyman_rounded),
          _buildTabItem(2, 'الوظائف', Icons.work_rounded),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon) {
    final isActive = _currentTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTab = index;
          _selectedCategoryId = null; // Reset category when switching tabs
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? ColorTokens.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isActive ? Colors.white : ColorTokens.textMuted),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(
              color: isActive ? Colors.white : ColorTokens.textMuted,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTabContent() {
    final Map<String, dynamic> searchParams = {
      if (_searchController.text.isNotEmpty) 'search': _searchController.text,
      if (_selectedCategoryId != null) 'categoryId': _selectedCategoryId,
    };

    if (_currentTab == 0) {
      if (_minPriceController.text.isNotEmpty) searchParams['minPrice'] = double.tryParse(_minPriceController.text);
      if (_maxPriceController.text.isNotEmpty) searchParams['maxPrice'] = double.tryParse(_maxPriceController.text);
      
      final adsAsync = ref.watch(advertisementsProvider(searchParams));
      return adsAsync.when(
        loading: () => _buildLoadingGrid(),
        error: (e, _) => _buildErrorState(),
        data: (ads) {
          if (ads.isEmpty && _searchController.text.isEmpty) return _buildInitialState();
          if (ads.isEmpty) return _buildNotFoundState();
          return _buildAdsGrid(ads);
        },
      );
    } else if (_currentTab == 1) {
      final servicesAsync = ref.watch(servicesProvider); 
      // Ideal way is fetching services with search params, but we re-use the general provider for display for now
      return servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildErrorState(),
        data: (services) {
          // Local filter for instant UX on Services since provider doesn't directly map yet in UI
          final filtered = services.where((s) => s.title.contains(_searchController.text) || s.description.contains(_searchController.text)).toList();
          if (filtered.isEmpty && _searchController.text.isEmpty) return _buildInitialState();
          if (filtered.isEmpty) return _buildNotFoundState();
          // We can use a lightweight ListView for Services
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
               // Re-use simple tile or list item
               return ListTile(
                 title: Text(filtered[index].title, style: const TextStyle(fontWeight: FontWeight.bold)),
                 subtitle: Text(filtered[index].city),
                 tileColor: Colors.white,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
               );
            },
          );
        },
      );
    } else {
      final jobsAsync = ref.watch(jobsProvider);
      return jobsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildErrorState(),
        data: (jobs) {
          final filtered = jobs.where((j) => j.title.contains(_searchController.text) || j.companyName.contains(_searchController.text)).toList();
          if (filtered.isEmpty && _searchController.text.isEmpty) return _buildInitialState();
          if (filtered.isEmpty) return _buildNotFoundState();
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
               return ListTile(
                 title: Text(filtered[index].title, style: const TextStyle(fontWeight: FontWeight.bold)),
                 subtitle: Text(filtered[index].companyName),
                 tileColor: Colors.white,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
               );
            },
          );
        },
      );
    }
  }

  Widget _buildInitialState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('عمليات البحث الأخيرة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _recentSearches.map((s) => _buildRecentTag(s)).toList(),
          ),
          const SizedBox(height: 40),
          const Text('اكتشف أقسامنا', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Expanded(child: _buildCategoryGrid()),
        ],
      ),
    );
  }

  Widget _buildRecentTag(String label) {
    return GestureDetector(
      onTap: () => setState(() => _searchController.text = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Text(label, style: const TextStyle(color: ColorTokens.textPrimary, fontSize: 14)),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final homeData = ref.watch(homeProvider);
    final categories = homeData.asData?.value['categories'] as List? ?? [];
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: InkWell(
            onTap: () => setState(() => _selectedCategoryId = cat['id']),
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(Icons.category_outlined, color: ColorTokens.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    cat['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 100, color: Colors.grey[200]),
          const SizedBox(height: 24),
          const Text('لم نجد أي نتائج', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 8),
          const Text('جرب كلمات بحث مختلفة أو غير الفلاتر', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 80, color: Colors.red[100]),
          const SizedBox(height: 16),
          const Text('تعذر الاتصال بالخادم', style: TextStyle(fontWeight: FontWeight.bold)),
          TextButton(onPressed: () => setState(() {}), child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }

  Widget _buildAdsGrid(List<AdvertisementModel> ads) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: ads.length,
      itemBuilder: (context, index) => _AdCard(ad: ads[index]),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        minController: _minPriceController,
        maxController: _maxPriceController,
        onApply: () => setState(() {}),
      ),
    );
  }
}

class _AdCard extends StatelessWidget {
  final AdvertisementModel ad;
  const _AdCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdDetailsScreen(ad: ad))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 11,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: ad.images.isNotEmpty
                          ? Image.network(ad.images.first, fit: BoxFit.cover)
                          : const Icon(Icons.image_outlined, color: Colors.grey),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                      child: const Icon(Icons.favorite_border_rounded, size: 18, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 9,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${ad.price.toStringAsFixed(0)} دج',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: ColorTokens.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ad.title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColorTokens.textPrimary, height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: ColorTokens.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(ad.location, style: const TextStyle(fontSize: 11, color: ColorTokens.textMuted, overflow: TextOverflow.ellipsis)),
                        ),
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
}

class _FilterBottomSheet extends StatelessWidget {
  final TextEditingController minController;
  final TextEditingController maxController;
  final VoidCallback onApply;

  const _FilterBottomSheet({required this.minController, required this.maxController, required this.onApply});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          const Text('فلاتر البحث', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 24),
          const Text('نطاق السعر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInput('الأدنى', minController)),
              const SizedBox(width: 16),
              Expanded(child: _buildInput('الأقصى', maxController)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: ['الكل', 'جديد', 'مستعمل'].map((v) => _buildChip(v, v == 'الكل')).toList(),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                onApply();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('تطبيق الفلاتر', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildChip(String label, bool active) {
    return Chip(
      label: Text(label),
      backgroundColor: active ? ColorTokens.primary.withOpacity(0.1) : Colors.white,
      labelStyle: TextStyle(color: active ? ColorTokens.primary : Colors.black87, fontWeight: active ? FontWeight.bold : FontWeight.normal),
      side: BorderSide(color: active ? ColorTokens.primary : const Color(0xFFEEEEEE)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
