import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../offers_provider.dart';
import '../../stores/stores_provider.dart';
import '../../../core/network/api_error.dart';

class OffersScreen extends ConsumerStatefulWidget {
  const OffersScreen({super.key});
  @override
  ConsumerState<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends ConsumerState<OffersScreen> {
  void _showForm({Map<String, dynamic>? offer}) {
    final title = TextEditingController(text: offer?['title'] ?? '');
    final desc = TextEditingController(text: offer?['description'] ?? '');
    final banner = TextEditingController(text: offer?['bannerImage'] ?? '');
    final priority = TextEditingController(text: (offer?['displayPriority'] ?? 0).toString());
    String? storeId = offer?['storeId'] ?? offer?['store']?['id'];
    bool isActive = offer?['isActive'] ?? true;
    final start = offer?['startDate'] != null ? DateTime.parse(offer!['startDate']) : DateTime.now();
    final end = offer?['endDate'] != null ? DateTime.parse(offer!['endDate']) : DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final storesAsync = ref.watch(allStoresProvider);
          return AlertDialog(
            title: Text(offer == null ? 'عرض جديد' : 'تعديل العرض'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    storesAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('خطأ في تحميل المتاجر: $e', style: const TextStyle(color: Colors.red)),
                      data: (stores) {
                        if (stores.isEmpty) {
                          return const Text('لا توجد متاجر. أنشئ متجراً أولاً.', style: TextStyle(color: Colors.orange));
                        }
                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'المتجر *', border: OutlineInputBorder()),
                          value: stores.any((s) => s['id'] == storeId) ? storeId : null,
                          items: stores
                              .map((s) => DropdownMenuItem(value: s['id'] as String, child: Text(s['name'] as String)))
                              .toList(),
                          onChanged: (v) => setS(() => storeId = v),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: title, decoration: const InputDecoration(labelText: 'العنوان *', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: desc, decoration: const InputDecoration(labelText: 'الوصف', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: banner, decoration: const InputDecoration(labelText: 'رابط صورة البanner', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priority,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'الأولوية', border: OutlineInputBorder()),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('مفعّل'),
                      value: isActive,
                      onChanged: (v) => setS(() => isActive = v),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              FilledButton(
                onPressed: () async {
                  if (storeId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('الرجاء اختيار المتجر'), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  if (title.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('الرجاء إدخال عنوان العرض'), backgroundColor: Colors.red),
                    );
                    return;
                  }

                  final data = {
                    'storeId': storeId,
                    'title': title.text.trim(),
                    'description': desc.text.trim().isEmpty ? null : desc.text.trim(),
                    'bannerImage': banner.text.trim(),
                    'startDate': start.toIso8601String(),
                    'endDate': end.toIso8601String(),
                    'isActive': isActive,
                    'displayPriority': int.tryParse(priority.text) ?? 0,
                  };

                  try {
                    if (offer != null) {
                      await ref.read(offerActionProvider.notifier).update(offer['id'], data);
                    } else {
                      await ref.read(offerActionProvider.notifier).create(data);
                    }
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم حفظ العرض بنجاح'), backgroundColor: Colors.green),
                      );
                    }
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(extractApiErrorMessage(e)), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                child: const Text('حفظ'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(offersProvider);
    final isActing = ref.watch(offerActionProvider);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('العروض', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('عرض جديد'),
            onPressed: () => _showForm(),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C3E50), foregroundColor: Colors.white),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Stack(
        children: [
          dataAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(extractApiErrorMessage(e), style: const TextStyle(color: Colors.red)),
                  ElevatedButton(onPressed: () => ref.invalidate(offersProvider), child: const Text('إعادة')),
                ],
              ),
            ),
            data: (items) {
              if (items.isEmpty) return const Center(child: Text('لا توجد عروض'));
              return Card(
                margin: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('العنوان')),
                      DataColumn(label: Text('المتجر')),
                      DataColumn(label: Text('الأولوية')),
                      DataColumn(label: Text('الحالة')),
                      DataColumn(label: Text('إجراءات')),
                    ],
                    rows: items.map<DataRow>((o) {
                      return DataRow(cells: [
                        DataCell(Text(o['title'] ?? '')),
                        DataCell(Text(o['store']?['name'] ?? '')),
                        DataCell(Text('${o['displayPriority'] ?? 0}')),
                        DataCell(Chip(label: Text(o['isActive'] == true ? 'مفعّل' : 'معطّل'))),
                        DataCell(Row(children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _showForm(offer: Map<String, dynamic>.from(o)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('حذف العرض'),
                                  content: const Text('هل تريد حذف هذا العرض؟'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('إلغاء')),
                                    FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('حذف')),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                try {
                                  await ref.read(offerActionProvider.notifier).delete(o['id']);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('تم الحذف'), backgroundColor: Colors.green),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(extractApiErrorMessage(e)), backgroundColor: Colors.red),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ])),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
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
