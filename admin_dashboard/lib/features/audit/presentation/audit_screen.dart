import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audit_provider.dart';
import '../../categories/categories_provider.dart';

class AuditScreen extends ConsumerStatefulWidget {
  const AuditScreen({super.key});
  @override
  ConsumerState<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends ConsumerState<AuditScreen> {
  final _searchCtrl = TextEditingController();
  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(auditLogsProvider);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('سجل التدقيق', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.white, surfaceTintColor: Colors.white),
      body: Column(children: [
        Container(color: Colors.white, padding: const EdgeInsets.all(16), child: Row(children: [
          Expanded(child: TextField(controller: _searchCtrl, decoration: InputDecoration(hintText: 'بحث...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)), onSubmitted: (v) { ref.read(auditSearchProvider.notifier).state = v.trim(); ref.read(auditPageProvider.notifier).state = 1; })),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(auditLogsProvider)),
        ])),
        Expanded(child: dataAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: ElevatedButton(onPressed: () => ref.invalidate(auditLogsProvider), child: Text('إعادة'))),
          data: (data) {
            final items = extractListItems(data);
            if (items.isEmpty) return const Center(child: Text('لا توجد سجلات'));
            return Card(margin: const EdgeInsets.all(16), child: SingleChildScrollView(child: DataTable(
              columns: const [DataColumn(label: Text('التاريخ')), DataColumn(label: Text('المسؤول')), DataColumn(label: Text('الإجراء')), DataColumn(label: Text('الكيان'))],
              rows: items.map<DataRow>((log) {
                final user = log['user'];
                final admin = user != null ? '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}' : 'System';
                return DataRow(cells: [
                  DataCell(Text('${log['createdAt'] ?? ''}'.substring(0, 19))),
                  DataCell(Text(admin)),
                  DataCell(Text(log['action'] ?? '')),
                  DataCell(Text(log['resource'] ?? '')),
                ]);
              }).toList(),
            )));
          },
        )),
      ]),
    );
  }
}
