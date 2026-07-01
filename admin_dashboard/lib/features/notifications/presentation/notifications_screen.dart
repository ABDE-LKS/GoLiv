import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifications_provider.dart';
import '../../categories/categories_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});
  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _target = 'ALL';

  @override
  void dispose() { _titleCtrl.dispose(); _bodyCtrl.dispose(); super.dispose(); }

  Future<void> _broadcast() async {
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) return;
    try {
      final result = await ref.read(notificationActionProvider.notifier).broadcast({
        'title': _titleCtrl.text.trim(), 'body': _bodyCtrl.text.trim(), 'target': _target,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم الإرسال إلى ${result['sent']} مستخدم'), backgroundColor: Colors.green));
        _titleCtrl.clear(); _bodyCtrl.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(notificationsProvider);
    final isSending = ref.watch(notificationActionProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('الإشعارات', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.white, surfaceTintColor: Colors.white),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('إرسال إشعار', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'العنوان', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _bodyCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'المحتوى', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _target,
            decoration: const InputDecoration(labelText: 'الهدف', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'ALL', child: Text('الجميع')),
              DropdownMenuItem(value: 'CUSTOMERS', child: Text('العملاء')),
              DropdownMenuItem(value: 'DRIVERS', child: Text('السائقون')),
              DropdownMenuItem(value: 'STORES', child: Text('المتاجر')),
            ],
            onChanged: (v) { if (v != null) setState(() => _target = v); },
          ),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: isSending ? null : _broadcast,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C3E50), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
            child: isSending ? const CircularProgressIndicator(color: Colors.white) : const Text('إرسال'),
          )),
        ]))),
        const SizedBox(height: 24),
        const Text('السجل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('خطأ: $e'),
          data: (data) {
            final items = extractListItems(data);
            if (items.isEmpty) return const Text('لا توجد إشعارات');
            return Card(child: ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: items.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (_, i) {
              final n = items[i];
              final user = n['user'] ?? {};
              return ListTile(title: Text(n['title'] ?? ''), subtitle: Text('${n['body']}\n${user['firstName'] ?? ''} - ${n['createdAt'] ?? ''}'), isThreeLine: true);
            }));
          },
        ),
      ])),
    );
  }
}
