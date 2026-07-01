import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../categories_provider.dart';

class EditCategoryDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> category;
  const EditCategoryDialog({super.key, required this.category});

  @override
  ConsumerState<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends ConsumerState<EditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _iconCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _sortOrderCtrl;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _nameCtrl = TextEditingController(text: c['name'] ?? '');
    _iconCtrl = TextEditingController(text: c['icon'] ?? '');
    _imageCtrl = TextEditingController(text: c['image'] ?? '');
    _sortOrderCtrl = TextEditingController(text: (c['sortOrder'] ?? 0).toString());
    _isActive = c['isActive'] ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _iconCtrl.dispose();
    _imageCtrl.dispose();
    _sortOrderCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref.read(categoryActionProvider.notifier).updateCategory(widget.category['id'], {
        'name': _nameCtrl.text.trim(),
        'icon': _iconCtrl.text.trim().isEmpty ? null : _iconCtrl.text.trim(),
        'image': _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
        'sortOrder': int.tryParse(_sortOrderCtrl.text) ?? 0,
        'isActive': _isActive,
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم التحديث'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(categoryActionProvider);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('تعديل التصنيف', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'اسم التصنيف *', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _iconCtrl, decoration: const InputDecoration(labelText: 'أيقونة', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextFormField(controller: _imageCtrl, decoration: const InputDecoration(labelText: 'رابط الصورة', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sortOrderCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ترتيب', border: OutlineInputBorder()),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('مفعّل'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C3E50), foregroundColor: Colors.white),
                  child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('حفظ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
