import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../admins_provider.dart';
import '../../categories/categories_provider.dart';

class AdminsScreen extends ConsumerStatefulWidget {
  const AdminsScreen({super.key});
  @override
  ConsumerState<AdminsScreen> createState() => _AdminsScreenState();
}

class _AdminsScreenState extends ConsumerState<AdminsScreen> {
  void _showCreate() {
    final fn = TextEditingController(), ln = TextEditingController(), ph = TextEditingController(), pw = TextEditingController(), em = TextEditingController();
    String role = 'ADMIN';
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      title: const Text('مسؤول جديد'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: fn, decoration: const InputDecoration(labelText: 'الاسم')),
        TextField(controller: ln, decoration: const InputDecoration(labelText: 'اللقب')),
        TextField(controller: ph, decoration: const InputDecoration(labelText: 'الهاتف')),
        TextField(controller: em, decoration: const InputDecoration(labelText: 'البريد')),
        TextField(controller: pw, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور')),
        DropdownButtonFormField<String>(value: role, decoration: const InputDecoration(labelText: 'الدور'), items: const [DropdownMenuItem(value: 'ADMIN', child: Text('Admin')), DropdownMenuItem(value: 'SUPER_ADMIN', child: Text('Super Admin'))], onChanged: (v) => setS(() => role = v ?? 'ADMIN')),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
        FilledButton(onPressed: () async {
          try {
            await ref.read(adminActionProvider.notifier).create({'firstName': fn.text.trim(), 'lastName': ln.text.trim(), 'phone': ph.text.trim(), 'email': em.text.trim().isEmpty ? null : em.text.trim(), 'password': pw.text, 'role': role});
            if (ctx.mounted) { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم'), backgroundColor: Colors.green)); }
          } catch (e) { if (ctx.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red)); }
        }, child: const Text('حفظ')),
      ],
    )));
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(adminsProvider);
    final isActing = ref.watch(adminActionProvider);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('المسؤولون', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.white, surfaceTintColor: Colors.white,
        actions: [ElevatedButton.icon(icon: const Icon(Icons.add, size: 18), label: const Text('مسؤول جديد'), onPressed: _showCreate, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C3E50), foregroundColor: Colors.white)), const SizedBox(width: 24)]),
      body: Stack(children: [
        dataAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: ElevatedButton(onPressed: () => ref.invalidate(adminsProvider), child: Text('إعادة - $e'))),
          data: (data) {
            final items = extractListItems(data);
            if (items.isEmpty) return const Center(child: Text('لا يوجد مسؤولون'));
            return Card(margin: const EdgeInsets.all(16), child: SingleChildScrollView(child: DataTable(
              columns: const [DataColumn(label: Text('الاسم')), DataColumn(label: Text('الهاتف')), DataColumn(label: Text('الدور')), DataColumn(label: Text('إجراءات'))],
              rows: items.map<DataRow>((a) {
                final name = '${a['firstName'] ?? ''} ${a['lastName'] ?? ''}';
                return DataRow(cells: [
                  DataCell(Text(name)), DataCell(Text(a['phone'] ?? '')), DataCell(Text(a['role'] ?? '')),
                  DataCell(IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () async {
                    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('حذف'), content: Text('حذف $name؟'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('لا')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('نعم'))]));
                    if (ok == true) { try { await ref.read(adminActionProvider.notifier).delete(a['id']); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم'), backgroundColor: Colors.green)); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red)); } }
                  })),
                ]);
              }).toList(),
            )));
          },
        ),
        if (isActing) Positioned.fill(child: Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator()))),
      ]),
    );
  }
}
