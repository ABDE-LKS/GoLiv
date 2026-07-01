import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../products_provider.dart';
import '../../categories/categories_provider.dart';
import '../../stores/stores_provider.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});
  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  void _showForm({Map<String, dynamic>? product}) {
    showDialog(context: context, builder: (_) => _ProductFormDialog(product: product));
  }

  Future<void> _delete(String id, String name) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('حذف المنتج'),
      content: Text('حذف "$name"؟'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
      ],
    ));
    if (ok != true) return;
    try {
      await ref.read(productActionProvider.notifier).deleteProduct(id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحذف'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(productsProvider);
    final storesAsync = ref.watch(allStoresProvider);
    final isActing = ref.watch(productActionProvider);
    final storeFilter = ref.watch(productStoreFilterProvider);
    final statusFilter = ref.watch(productStatusFilterProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('المنتجات', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('منتج جديد'),
            onPressed: () => _showForm(),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C3E50), foregroundColor: Colors.white),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Stack(children: [
        Column(children: [
          Container(
            color: Colors.white, padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(hintText: 'بحث...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                onSubmitted: (v) { ref.read(productSearchProvider.notifier).state = v.trim(); ref.read(productPageProvider.notifier).state = 1; },
              )),
              const SizedBox(width: 12),
              storesAsync.when(
                loading: () => const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                error: (_, __) => const SizedBox(),
                data: (stores) => DropdownButton<String?>(
                  value: storeFilter,
                  hint: const Text('المتجر'),
                  items: [const DropdownMenuItem(value: null, child: Text('كل المتاجر')), ...stores.map((s) => DropdownMenuItem(value: s['id'] as String, child: Text(s['name'] as String)))],
                  onChanged: (v) { ref.read(productStoreFilterProvider.notifier).state = v; ref.read(productPageProvider.notifier).state = 1; },
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: statusFilter,
                items: const [DropdownMenuItem(value: 'all', child: Text('الكل')), DropdownMenuItem(value: 'active', child: Text('متاح')), DropdownMenuItem(value: 'inactive', child: Text('غير متاح'))],
                onChanged: (v) { if (v != null) { ref.read(productStatusFilterProvider.notifier).state = v; ref.read(productPageProvider.notifier).state = 1; } },
              ),
              IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(productsProvider)),
            ]),
          ),
          Expanded(child: dataAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('خطأ: $e'), ElevatedButton(onPressed: () => ref.invalidate(productsProvider), child: const Text('إعادة'))])),
            data: (data) {
              final items = extractListItems(data);
              if (items.isEmpty) return const Center(child: Text('لا توجد منتجات'));
              return Card(
                margin: const EdgeInsets.all(16),
                child: SingleChildScrollView(child: DataTable(
                  columns: const [DataColumn(label: Text('الاسم')), DataColumn(label: Text('المتجر')), DataColumn(label: Text('السعر')), DataColumn(label: Text('المخزون')), DataColumn(label: Text('الحالة')), DataColumn(label: Text('إجراءات'))],
                  rows: items.map<DataRow>((p) => DataRow(cells: [
                    DataCell(Text(p['name'] ?? '')),
                    DataCell(Text(p['store']?['name'] ?? '')),
                    DataCell(Text('${p['price']} دج')),
                    DataCell(Text('${p['stockQuantity'] ?? '-'}')),
                    DataCell(Chip(label: Text(p['isActive'] == true ? 'متاح' : 'غير متاح'))),
                    DataCell(Row(children: [
                      IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showForm(product: Map<String, dynamic>.from(p))),
                      IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => _delete(p['id'], p['name'])),
                    ])),
                  ])).toList(),
                )),
              );
            },
          )),
        ]),
        if (isActing) Positioned.fill(child: Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator()))),
      ]),
    );
  }
}

class _ProductFormDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? product;
  const _ProductFormDialog({this.product});
  @override
  ConsumerState<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl, _descCtrl, _priceCtrl, _stockCtrl, _discountCtrl, _imageCtrl;
  String? _storeId;
  bool _isActive = true, _isFeatured = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?['name'] ?? '');
    _descCtrl = TextEditingController(text: p?['description'] ?? '');
    _priceCtrl = TextEditingController(text: p?['price']?.toString() ?? '');
    _stockCtrl = TextEditingController(text: p?['stockQuantity']?.toString() ?? '');
    _discountCtrl = TextEditingController(text: p?['discountPercentage']?.toString() ?? '');
    _imageCtrl = TextEditingController(text: p?['image'] ?? '');
    _storeId = p?['storeId'] ?? p?['store']?['id'];
    _isActive = p?['isActive'] ?? true;
    _isFeatured = p?['isFeatured'] ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose(); _priceCtrl.dispose(); _stockCtrl.dispose(); _discountCtrl.dispose(); _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _storeId == null) return;
    final data = {
      'storeId': _storeId, 'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      'price': double.parse(_priceCtrl.text),
      'stockQuantity': int.tryParse(_stockCtrl.text),
      'discountPercentage': double.tryParse(_discountCtrl.text),
      'image': _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
      'isActive': _isActive, 'isFeatured': _isFeatured,
    };
    try {
      if (widget.product != null) {
        await ref.read(productActionProvider.notifier).updateProduct(widget.product!['id'], data);
      } else {
        await ref.read(productActionProvider.notifier).createProduct(data);
      }
      if (mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ'), backgroundColor: Colors.green)); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final storesAsync = ref.watch(allStoresProvider);
    final isLoading = ref.watch(productActionProvider);
    return Dialog(
      child: Container(width: 500, padding: const EdgeInsets.all(24), child: Form(key: _formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(widget.product == null ? 'منتج جديد' : 'تعديل المنتج', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        storesAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('خطأ: $e'),
          data: (stores) => DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'المتجر *', border: OutlineInputBorder()),
            value: stores.any((s) => s['id'] == _storeId) ? _storeId : null,
            items: stores.map((s) => DropdownMenuItem(value: s['id'] as String, child: Text(s['name'] as String))).toList(),
            onChanged: (v) => setState(() => _storeId = v),
            validator: (v) => v == null ? 'مطلوب' : null,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'الاسم *', border: OutlineInputBorder()), validator: (v) => v!.trim().isEmpty ? 'مطلوب' : null),
        const SizedBox(height: 12),
        TextFormField(controller: _descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'الوصف', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextFormField(controller: _priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر (دج) *', border: OutlineInputBorder()), validator: (v) => double.tryParse(v ?? '') == null ? 'رقم غير صالح' : null),
        const SizedBox(height: 12),
        TextFormField(controller: _stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'المخزون', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextFormField(controller: _discountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'خصم %', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextFormField(controller: _imageCtrl, decoration: const InputDecoration(labelText: 'رابط الصورة', border: OutlineInputBorder())),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('متاح'), value: _isActive, onChanged: (v) => setState(() => _isActive = v)),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('مميز'), value: _isFeatured, onChanged: (v) => setState(() => _isFeatured = v)),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: isLoading ? null : _save,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C3E50), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
          child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('حفظ'),
        )),
      ])))),
    );
  }
}
