import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../categories_provider.dart';
import 'create_category_dialog.dart';
import 'edit_category_dialog.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(String id, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف التصنيف'),
        content: Text('هل تريد حذف "$name"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ref.read(categoryActionProvider.notifier).deleteCategory(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الحذف'), backgroundColor: Colors.green),
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
    final dataAsync = ref.watch(categoriesListProvider);
    final isActing = ref.watch(categoryActionProvider);
    final currentStatus = ref.watch(categoryStatusFilterProvider);
    final page = ref.watch(categoryPageProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('إدارة التصنيفات', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('تصنيف جديد'),
            onPressed: () => showDialog(context: context, builder: (_) => const CreateCategoryDialog()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C3E50),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'بحث...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        onSubmitted: (v) {
                          ref.read(categorySearchProvider.notifier).state = v.trim();
                          ref.read(categoryPageProvider.notifier).state = 1;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: currentStatus,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('الكل')),
                        DropdownMenuItem(value: 'active', child: Text('مفعّل')),
                        DropdownMenuItem(value: 'inactive', child: Text('معطّل')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          ref.read(categoryStatusFilterProvider.notifier).state = v;
                          ref.read(categoryPageProvider.notifier).state = 1;
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => ref.invalidate(categoriesListProvider),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: dataAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('خطأ: $e', style: const TextStyle(color: Colors.red)),
                        ElevatedButton(onPressed: () => ref.invalidate(categoriesListProvider), child: const Text('إعادة')),
                      ],
                    ),
                  ),
                  data: (data) {
                    final items = extractListItems(data);
                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text('لا توجد تصنيفات'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('إنشاء تصنيف'),
                              onPressed: () => showDialog(context: context, builder: (_) => const CreateCategoryDialog()),
                            ),
                          ],
                        ),
                      );
                    }

                    final totalPages = data['totalPages'] as int? ?? 1;

                    return Column(
                      children: [
                        Expanded(
                          child: Card(
                            margin: const EdgeInsets.all(16),
                            child: SingleChildScrollView(
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('الأيقونة')),
                                  DataColumn(label: Text('الاسم')),
                                  DataColumn(label: Text('الترتيب')),
                                  DataColumn(label: Text('الحالة')),
                                  DataColumn(label: Text('إجراءات')),
                                ],
                                rows: items.map<DataRow>((c) {
                                  final isActive = c['isActive'] == true;
                                  return DataRow(cells: [
                                    DataCell(Text(c['icon'] ?? '-')),
                                    DataCell(Text(c['name'] ?? '')),
                                    DataCell(Text('${c['sortOrder'] ?? 0}')),
                                    DataCell(
                                      Chip(
                                        label: Text(isActive ? 'مفعّل' : 'معطّل'),
                                        backgroundColor: isActive ? Colors.green.shade50 : Colors.red.shade50,
                                      ),
                                    ),
                                    DataCell(Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 20),
                                          onPressed: () => showDialog(
                                            context: context,
                                            builder: (_) => EditCategoryDialog(category: Map<String, dynamic>.from(c)),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(isActive ? Icons.block : Icons.check_circle, size: 20),
                                          onPressed: () => ref.read(categoryActionProvider.notifier)
                                              .toggleActive(c['id'], !isActive),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                          onPressed: () => _confirmDelete(c['id'], c['name']),
                                        ),
                                      ],
                                    )),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        if (totalPages > 1)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left),
                                  onPressed: page > 1 ? () => ref.read(categoryPageProvider.notifier).state = page - 1 : null,
                                ),
                                Text('صفحة $page / $totalPages'),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: page < totalPages ? () => ref.read(categoryPageProvider.notifier).state = page + 1 : null,
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          if (isActing)
            Positioned.fill(
              child: Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator())),
            ),
        ],
      ),
    );
  }
}
