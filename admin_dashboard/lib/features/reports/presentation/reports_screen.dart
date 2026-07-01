import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../reports_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(reportsSummaryProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('التقارير', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, surfaceTintColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.download), tooltip: 'تصدير CSV', onPressed: () async {
            try {
              final csv = await ref.read(reportsExportProvider.future);
              await Clipboard.setData(ClipboardData(text: csv));
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ CSV'), backgroundColor: Colors.green));
            } catch (e) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
            }
          }),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(reportsSummaryProvider)),
        ],
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('خطأ: $e'), ElevatedButton(onPressed: () => ref.invalidate(reportsSummaryProvider), child: const Text('إعادة'))])),
        data: (data) {
          final orders = data['orders'] ?? {};
          final revenue = data['revenue'] ?? {};
          final users = data['users'] ?? {};
          return SingleChildScrollView(padding: const EdgeInsets.all(24), child: GridView.extent(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), maxCrossAxisExtent: 280, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 2,
            children: [
              _card('إجمالي الطلبات', '${orders['total'] ?? 0}', Icons.receipt),
              _card('طلبات مكتملة', '${orders['delivered'] ?? 0}', Icons.check_circle),
              _card('الإيرادات', '${revenue['total'] ?? 0} دج', Icons.attach_money),
              _card('العمولة', '${revenue['commission'] ?? 0} دج', Icons.percent),
              _card('العملاء', '${users['customers'] ?? 0}', Icons.people),
              _card('السائقون', '${users['drivers'] ?? 0}', Icons.two_wheeler),
              _card('المتاجر', '${data['stores'] ?? 0}', Icons.store),
              _card('شكاوى مفتوحة', '${data['complaints'] ?? 0}', Icons.feedback),
            ],
          ));
        },
      ),
    );
  }

  Widget _card(String title, String value, IconData icon) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
    Icon(icon, color: const Color(0xFF2C3E50)), const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    ])),
  ])));
}
