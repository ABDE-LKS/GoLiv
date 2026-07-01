import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../categories_provider.dart';
import '../presentation/create_category_dialog.dart';

/// Category dropdown with empty state and inline create button.
class CategoryDropdownField extends ConsumerWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const CategoryDropdownField({super.key, required this.value, required this.onChanged});

  Future<void> _openCreateDialog(BuildContext context, WidgetRef ref) async {
    final created = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const CreateCategoryDialog(),
    );
    if (created != null && created['id'] != null) {
      ref.invalidate(categoriesProvider);
      onChanged(created['id'] as String);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('خطأ: $e', style: const TextStyle(color: Colors.red)),
          TextButton(onPressed: () => ref.invalidate(categoriesProvider), child: const Text('إعادة المحاولة')),
        ],
      ),
      data: (cats) {
        if (cats.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('لا توجد تصنيفات.', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('+ إنشاء تصنيف'),
                  onPressed: () => _openCreateDialog(context, ref),
                ),
              ],
            ),
          );
        }

        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'التصنيف *', border: OutlineInputBorder()),
          value: cats.any((c) => c['id'] == value) ? value : null,
          items: cats.map<DropdownMenuItem<String>>((c) {
            final icon = c['icon'] as String?;
            final name = c['name'] as String;
            return DropdownMenuItem(
              value: c['id'] as String,
              child: Text(icon != null && icon.isNotEmpty ? '$icon $name' : name),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? 'الرجاء اختيار التصنيف' : null,
        );
      },
    );
  }
}
