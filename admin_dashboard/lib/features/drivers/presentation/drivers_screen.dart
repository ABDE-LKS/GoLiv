import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../drivers_provider.dart';
import '../../categories/categories_provider.dart';

class DriversScreen extends ConsumerStatefulWidget {
  const DriversScreen({super.key});
  @override
  ConsumerState<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends ConsumerState<DriversScreen> {
  final _searchCtrl = TextEditingController();
  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  void _showCreate() {
    final fn = TextEditingController(), ln = TextEditingController(), ph = TextEditingController(), pw = TextEditingController(), vt = TextEditingController(), lic = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('سائق جديد'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: fn, decoration: const InputDecoration(labelText: 'الاسم')),
        TextField(controller: ln, decoration: const InputDecoration(labelText: 'اللقب')),
        TextField(controller: ph, decoration: const InputDecoration(labelText: 'الهاتف')),
        TextField(controller: pw, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور')),
        TextField(controller: vt, decoration: const InputDecoration(labelText: 'نوع المركبة')),
        TextField(controller: lic, decoration: const InputDecoration(labelText: 'رقم الرخصة')),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
        FilledButton(onPressed: () async {
          try {
            await ref.read(driverActionProvider.notifier).create({
              'firstName': fn.text.trim(), 'lastName': ln.text.trim(), 'phone': ph.text.trim(),
              'password': pw.text, 'vehicleType': vt.text.trim(), 'licenseNumber': lic.text.trim(),
            });
            if (ctx.mounted) { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الإنشاء'), backgroundColor: Colors.green)); }
          } catch (e) {
            if (ctx.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
          }
        }, child: const Text('حفظ')),
      ],
    ));
  }

  Future<void> _confirmDelete(String id, String name) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('حذف السائق'), content: Text('حذف $name؟'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')), FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف'))],
    ));
    if (ok == true) {
      try { await ref.read(driverActionProvider.notifier).delete(id); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحذف'), backgroundColor: Colors.green)); }
      catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red)); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(driversProvider);
    final isActing = ref.watch(driverActionProvider);
    final status = ref.watch(driverStatusFilterProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('السائقون', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, surfaceTintColor: Colors.white,
        actions: [ElevatedButton.icon(icon: const Icon(Icons.add, size: 18), label: const Text('سائق جديد'), onPressed: _showCreate, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C3E50), foregroundColor: Colors.white)), const SizedBox(width: 24)],
      ),
      body: Stack(children: [
        Column(children: [
          Container(color: Colors.white, padding: const EdgeInsets.all(16), child: Row(children: [
            Expanded(child: TextField(controller: _searchCtrl, decoration: InputDecoration(hintText: 'بحث...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)), onSubmitted: (v) => ref.read(driverSearchProvider.notifier).state = v.trim())),
            const SizedBox(width: 12),
            DropdownButton<String>(value: status, items: const [DropdownMenuItem(value: 'all', child: Text('الكل')), DropdownMenuItem(value: 'online', child: Text('متصل')), DropdownMenuItem(value: 'offline', child: Text('غير متصل'))], onChanged: (v) { if (v != null) ref.read(driverStatusFilterProvider.notifier).state = v; }),
            IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(driversProvider)),
          ])),
          Expanded(child: dataAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('خطأ: $e'), ElevatedButton(onPressed: () => ref.invalidate(driversProvider), child: const Text('إعادة'))])),
            data: (data) {
              final items = extractListItems(data);
              if (items.isEmpty) return const Center(child: Text('لا يوجد سائقون'));
              return Card(margin: const EdgeInsets.all(16), child: SingleChildScrollView(child: DataTable(
                columns: const [DataColumn(label: Text('الاسم')), DataColumn(label: Text('الهاتف')), DataColumn(label: Text('المركبة')), DataColumn(label: Text('الحالة')), DataColumn(label: Text('الطلبات')), DataColumn(label: Text('إجراءات'))],
                rows: items.map<DataRow>((d) {
                  final user = d['user'] ?? {};
                  final name = '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}';
                  final online = d['isOnline'] == true;
                  return DataRow(cells: [
                    DataCell(Text(name)), DataCell(Text(user['phone'] ?? '')), DataCell(Text(d['vehicleType'] ?? '-')),
                    DataCell(Chip(label: Text(online ? 'متصل' : 'غير متصل'), backgroundColor: online ? Colors.green.shade50 : Colors.grey.shade200)),
                    DataCell(Text('${d['_count']?['orders'] ?? 0}')),
                    DataCell(Row(children: [
                      IconButton(icon: Icon(online ? Icons.block : Icons.check_circle, size: 20), onPressed: () => online ? ref.read(driverActionProvider.notifier).suspend(d['id']) : ref.read(driverActionProvider.notifier).activate(d['id'])),
                      IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => _confirmDelete(d['id'], name)),
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
