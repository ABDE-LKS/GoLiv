import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../customers_provider.dart';
import '../../categories/categories_provider.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});
  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _searchCtrl = TextEditingController();
  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  void _showDetail(String id) {
    showDialog(context: context, builder: (_) => _CustomerDetailDialog(customerId: id));
  }

  Future<void> _delete(String id, String name) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('حذف العميل'), content: Text('حذف $name؟'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')), FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف'))],
    ));
    if (ok == true) {
      try { await ref.read(customerActionProvider.notifier).delete(id); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحذف'), backgroundColor: Colors.green)); }
      catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red)); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(customersProvider);
    final isActing = ref.watch(customerActionProvider);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('العملاء', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.white, surfaceTintColor: Colors.white),
      body: Stack(children: [
        Column(children: [
          Container(color: Colors.white, padding: const EdgeInsets.all(16), child: Row(children: [
            Expanded(child: TextField(controller: _searchCtrl, decoration: InputDecoration(hintText: 'بحث بالاسم أو الهاتف...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)), onSubmitted: (v) { ref.read(customerSearchProvider.notifier).state = v.trim(); ref.read(customerPageProvider.notifier).state = 1; })),
            IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(customersProvider)),
          ])),
          Expanded(child: dataAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: ElevatedButton(onPressed: () => ref.invalidate(customersProvider), child: Text('إعادة - $e'))),
            data: (data) {
              final items = extractListItems(data);
              if (items.isEmpty) return const Center(child: Text('لا يوجد عملاء'));
              return Card(margin: const EdgeInsets.all(16), child: SingleChildScrollView(child: DataTable(
                columns: const [DataColumn(label: Text('الاسم')), DataColumn(label: Text('الهاتف')), DataColumn(label: Text('الطلبات')), DataColumn(label: Text('الشكاوى')), DataColumn(label: Text('إجراءات'))],
                rows: items.map<DataRow>((c) {
                  final name = '${c['firstName'] ?? ''} ${c['lastName'] ?? ''}';
                  return DataRow(cells: [
                    DataCell(Text(name)), DataCell(Text(c['phone'] ?? '')),
                    DataCell(Text('${c['_count']?['orders'] ?? 0}')), DataCell(Text('${c['_count']?['complaints'] ?? 0}')),
                    DataCell(Row(children: [
                      IconButton(icon: const Icon(Icons.visibility, size: 20), onPressed: () => _showDetail(c['id'])),
                      IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => _delete(c['id'], name)),
                    ])),
                  ]);
                }).toList(),
              )));
            },
          )),
        ]),
        if (isActing) Positioned.fill(child: Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator()))),
      ]),
    );
  }
}

class _CustomerDetailDialog extends ConsumerWidget {
  final String customerId;
  const _CustomerDetailDialog({required this.customerId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(customerDetailProvider(customerId));
    return Dialog(
      child: Container(width: 600, padding: const EdgeInsets.all(24), constraints: const BoxConstraints(maxHeight: 500),
        child: detailAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('خطأ: $e'),
          data: (c) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${c['firstName']} ${c['lastName']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('${c['phone']}'),
            const SizedBox(height: 16),
            Text('الطلبات (${(c['orders'] as List?)?.length ?? 0})', style: const TextStyle(fontWeight: FontWeight.bold)),
            Expanded(child: ListView(children: [
              ...((c['orders'] as List?) ?? []).map((o) => ListTile(dense: true, title: Text('${o['status']} - ${o['totalAmount']} دج'), subtitle: Text('${o['createdAt']}')))
            ])),
            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق'))),
          ]),
        ),
      ),
    );
  }
}
