import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../stores_provider.dart';
import '../../categories/widgets/category_dropdown_field.dart';
import '../../categories/presentation/create_category_dialog.dart';

class CreateStoreDialog extends ConsumerStatefulWidget {
  const CreateStoreDialog({super.key});
  @override
  ConsumerState<CreateStoreDialog> createState() => _CreateStoreDialogState();
}

class _CreateStoreDialogState extends ConsumerState<CreateStoreDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _latCtrl = TextEditingController(text: '32.7897');
  final _lngCtrl = TextEditingController(text: '3.5000');
  final _deliveryFeeCtrl = TextEditingController(text: '200');
  final _minOrderCtrl = TextEditingController(text: '500');
  final _minTimeCtrl = TextEditingController(text: '20');
  final _maxTimeCtrl = TextEditingController(text: '45');
  final _openingCtrl = TextEditingController(text: '08:00');
  final _closingCtrl = TextEditingController(text: '22:00');
  final _logoCtrl = TextEditingController();
  final _bannerCtrl = TextEditingController();

  String? _selectedCategory;
  bool _isActive = true;
  bool _isFeatured = false;

  @override
  void dispose() {
    for (final c in [_nameCtrl, _phoneCtrl, _descCtrl, _addressCtrl, _latCtrl, _lngCtrl,
        _deliveryFeeCtrl, _minOrderCtrl, _minTimeCtrl, _maxTimeCtrl, _openingCtrl, _closingCtrl, _logoCtrl, _bannerCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _openCreateCategory() async {
    final created = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const CreateCategoryDialog(),
    );
    if (created != null && created['id'] != null) {
      setState(() => _selectedCategory = created['id'] as String);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار التصنيف'), backgroundColor: Colors.red),
      );
      return;
    }

    final data = {
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'latitude': double.tryParse(_latCtrl.text),
      'longitude': double.tryParse(_lngCtrl.text),
      'categoryId': _selectedCategory,
      'deliveryFee': double.tryParse(_deliveryFeeCtrl.text) ?? 0.0,
      'minOrderAmount': double.tryParse(_minOrderCtrl.text) ?? 0.0,
      'minDeliveryTime': int.tryParse(_minTimeCtrl.text) ?? 20,
      'maxDeliveryTime': int.tryParse(_maxTimeCtrl.text) ?? 45,
      'openingHours': _openingCtrl.text.trim(),
      'closingHours': _closingCtrl.text.trim(),
      'logo': _logoCtrl.text.trim().isEmpty ? null : _logoCtrl.text.trim(),
      'banner': _bannerCtrl.text.trim().isEmpty ? null : _bannerCtrl.text.trim(),
      'isActive': _isActive,
      'isFeatured': _isFeatured,
    };

    try {
      await ref.read(storeActionProvider.notifier).createStore(data);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء المتجر بنجاح'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الإنشاء: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(storeActionProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 650,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('إنشاء متجر جديد', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(height: 32),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _field(_nameCtrl, 'اسم المتجر', required: true),
                      const SizedBox(height: 12),
                      _field(_phoneCtrl, 'رقم الهاتف', required: true),
                      const SizedBox(height: 12),
                      CategoryDropdownField(
                        value: _selectedCategory,
                        onChanged: (v) => setState(() => _selectedCategory = v),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('+ إنشاء تصنيف'),
                          onPressed: _openCreateCategory,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _field(_addressCtrl, 'العنوان', required: true),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: _field(_latCtrl, 'خط العرض', keyboard: const TextInputType.numberWithOptions(decimal: true))),
                        const SizedBox(width: 12),
                        Expanded(child: _field(_lngCtrl, 'خط الطول', keyboard: const TextInputType.numberWithOptions(decimal: true))),
                      ]),
                      const SizedBox(height: 12),
                      _field(_descCtrl, 'الوصف', maxLines: 2),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: _field(_deliveryFeeCtrl, 'سعر التوصيل (دج)', keyboard: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _field(_minOrderCtrl, 'الحد الأدنى للطلب (دج)', keyboard: TextInputType.number)),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: _field(_minTimeCtrl, 'وقت التوصيل min (د)', keyboard: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _field(_maxTimeCtrl, 'وقت التوصيل max (د)', keyboard: TextInputType.number)),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: _field(_openingCtrl, 'ساعة الافتتاح')),
                        const SizedBox(width: 12),
                        Expanded(child: _field(_closingCtrl, 'ساعة الإغلاق')),
                      ]),
                      const SizedBox(height: 12),
                      _field(_logoCtrl, 'رابط الشعار (Logo)'),
                      const SizedBox(height: 12),
                      _field(_bannerCtrl, 'رابط صورة الغلاف'),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('المتجر متاح'),
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('مميز'),
                        value: _isFeatured,
                        onChanged: (v) => setState(() => _isFeatured = v),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3E50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('حفظ المتجر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, {bool required = false, int maxLines = 1, TextInputType? keyboard}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null : null,
    );
  }
}
