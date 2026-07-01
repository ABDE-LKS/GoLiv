import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  String? _selectedCategory;
  final TextEditingController _detailsController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'id': 'c1', 'name': 'بقالة', 'icon': Icons.shopping_basket, 'color': Color(0xFF4D96FF)},
    {'id': 'c2', 'name': 'صيدلية', 'icon': Icons.medical_services, 'color': Color(0xFFFF922B)},
    {'id': 'c3', 'name': 'مطعم', 'icon': Icons.restaurant, 'color': Color(0xFFFF6B6B)},
    {'id': 'c4', 'name': 'مخبزة', 'icon': Icons.bakery_dining, 'color': Color(0xFFFFD93D)},
    {'id': 'c5', 'name': 'ملابس', 'icon': Icons.checkroom, 'color': Color(0xFF845EF7)},
    {'id': 'c6', 'name': 'إلكترونيات', 'icon': Icons.devices, 'color': Color(0xFF20C997)},
    {'id': 'c7', 'name': 'وثائق', 'icon': Icons.description, 'color': Color(0xFF74C0FC)},
    {'id': 'c8', 'name': 'طرد', 'icon': Icons.inventory_2, 'color': Color(0xFFFFA94D)},
    {'id': 'c9', 'name': 'أخرى', 'icon': Icons.more_horiz, 'color': Color(0xFFADB5BD)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentStep == 0 ? 'اختر الفئة' : (_currentStep == 1 ? 'تفاصيل الطلب' : 'تأكيد الطلب')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isActive ? ColorTokens.secondary : Colors.grey[200],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        final isSelected = _selectedCategory == cat['name'];
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat['name']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? cat['color'].withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? cat['color'] : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat['icon'], color: cat['color'], size: 36),
                const SizedBox(height: 12),
                Text(
                  cat['name'],
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? cat['color'] : ColorTokens.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: ColorTokens.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 16, color: ColorTokens.secondary),
                const SizedBox(width: 8),
                Text(_selectedCategory ?? '', style: AppTextStyles.labelSmall.copyWith(color: ColorTokens.secondary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppTextField(
            label: 'ماذا تريد أن نشتري لك؟',
            hint: 'اكتب ما تريده بالتفصيل...\nمثال:\n- 2 لتر حليب\n- خبز\n- طماطم',
            controller: _detailsController,
            isMultiline: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildActionIcon(Icons.camera_alt_outlined),
              const SizedBox(width: 12),
              _buildActionIcon(Icons.location_on_outlined),
              const Spacer(),
              Text('${_detailsController.text.length} حرف', style: AppTextStyles.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryItem('الفئة', _selectedCategory ?? ''),
          const Divider(height: 32),
          _buildSummaryItem('تفاصيل الطلب', _detailsController.text),
          const Divider(height: 32),
          _buildSummaryItem('موقع التوصيل', 'القرارة (سيتم تحديد الموقع الدقيق لاحقًا)'),
          const Divider(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorTokens.accent.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: ColorTokens.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'السائق سيخبرك بالتكلفة الفعلية قبل الشراء',
                    style: AppTextStyles.labelSmall.copyWith(color: ColorTokens.secondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryItem('طريقة الدفع', 'نقدًا عند الاستلام', icon: Icons.lock_outline),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: ColorTokens.textSecondary)),
        const SizedBox(height: 8),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: ColorTokens.textMuted),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold))),
          ],
        ),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: ColorTokens.textSecondary, size: 20),
    );
  }

  Widget _buildBottomAction() {
    bool canProceed = false;
    if (_currentStep == 0) canProceed = _selectedCategory != null;
    if (_currentStep == 1) canProceed = _detailsController.text.isNotEmpty;
    if (_currentStep == 2) canProceed = true;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: AppButton(
        label: _currentStep == 2 ? 'إرسال الطلب' : 'التالي',
        onPressed: canProceed
            ? () {
                if (_currentStep < 2) {
                  _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                } else {
                  context.push('/customer/finding-driver');
                }
              }
            : null,
      ),
    );
  }
}


