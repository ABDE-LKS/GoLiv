import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../complaints_provider.dart';
import '../../categories/categories_provider.dart';

class ComplaintsScreen extends ConsumerWidget {
  const ComplaintsScreen({super.key});

  void _reply(BuildContext context, WidgetRef ref, Map<String, dynamic> c) {
    final replyCtrl = TextEditingController(text: c['reply'] ?? '');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(c['subject'] ?? 'شكوى'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(c['body'] ?? ''), const SizedBox(height: 12),
        TextField(controller: replyCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'الرد', border: OutlineInputBorder())),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
        FilledButton(onPressed: () async {
          try {
            await ref.read(complaintActionProvider.notifier).update(c['id'], {'reply': replyCtrl.text.trim(), 'status': 'IN_PROGRESS'});
            if (ctx.mounted) { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم'), backgroundColor: Colors.green)); }
          } catch (e) { if (ctx.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red)); }
        }, child: const Text('إرسال')),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.green), onPressed: () async {
          try {
            await ref.read(complaintActionProvider.notifier).update(c['id'], {'reply': replyCtrl.text.trim(), 'status': 'RESOLVED'});
            if (ctx.mounted) { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحل'), backgroundColor: Colors.green)); }
          } catch (e) { if (ctx.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red)); }
        }, child: const Text('حل')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(complaintsProvider);
    final isActing = ref.watch(complaintActionProvider);
    final status = ref.watch(complaintStatusFilterProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('الشكاوى', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.white, surfaceTintColor: Colors.white),
      body: Stack(children: [
        Column(children: [
          Container(color: Colors.white, padding: const EdgeInsets.all(16), child: Row(children: [
            DropdownButton<String>(value: status, items: const [
              DropdownMenuItem(value: 'all', child: Text('الكل')),
              DropdownMenuItem(value: 'OPEN', child: Text('مفتوحة')),
              DropdownMenuItem(value: 'IN_PROGRESS', child: Text('قيد المعالجة')),
              DropdownMenuItem(value: 'RESOLVED', child: Text('محلولة')),
              DropdownMenuItem(value: 'CLOSED', child: Text('مغلقة')),
            ], onChanged: (v) { if (v != null) ref.read(complaintStatusFilterProvider.notifier).state = v; }),
            IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(complaintsProvider)),
          ])),
          Expanded(child: dataAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: ElevatedButton(onPressed: () => ref.invalidate(complaintsProvider), child: Text('إعادة'))),
            data: (data) {
              final items = extractListItems(data);
              if (items.isEmpty) return const Center(child: Text('لا توجد شكاوى'));
              return Card(margin: const EdgeInsets.all(16), child: SingleChildScrollView(child: DataTable(
                columns: const [DataColumn(label: Text('الموضوع')), DataColumn(label: Text('العميل')), DataColumn(label: Text('الحالة')), DataColumn(label: Text('التاريخ')), DataColumn(label: Text('إجراءات'))],
                rows: items.map<DataRow>((c) {
                  final customer = c['customer'] ?? {};
                  return DataRow(cells: [
                    DataCell(Text(c['subject'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis)),
                    DataCell(Text('${customer['firstName'] ?? ''} ${customer['lastName'] ?? ''}')),
                    DataCell(Chip(label: Text(c['status'] ?? ''))),
                    DataCell(Text('${c['createdAt'] ?? ''}'.substring(0, 10))),
                    DataCell(IconButton(icon: const Icon(Icons.reply, size: 20), onPressed: () => _reply(context, ref, Map<String, dynamic>.from(c)))),
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
