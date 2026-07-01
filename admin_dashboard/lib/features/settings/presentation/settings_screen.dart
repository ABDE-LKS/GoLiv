import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _deliveryFeeCtrl = TextEditingController();
  final _commissionCtrl = TextEditingController();
  final _appNameCtrl = TextEditingController();
  bool _maintenance = false;
  bool _loaded = false;

  @override
  void dispose() { _deliveryFeeCtrl.dispose(); _commissionCtrl.dispose(); _appNameCtrl.dispose(); super.dispose(); }

  void _loadSettings(Map<String, dynamic> s) {
    if (_loaded) return;
    _deliveryFeeCtrl.text = s['deliveryFee'] ?? '200';
    _commissionCtrl.text = s['commissionPercentage'] ?? '10';
    _appNameCtrl.text = s['appName'] ?? 'Guliv';
    _maintenance = s['maintenanceMode'] == 'true';
    _loaded = true;
  }

  Future<void> _save() async {
    try {
      await ref.read(settingsActionProvider.notifier).save({
        'deliveryFee': _deliveryFeeCtrl.text.trim(),
        'commissionPercentage': _commissionCtrl.text.trim(),
        'appName': _appNameCtrl.text.trim(),
        'maintenanceMode': _maintenance.toString(),
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final isSaving = ref.watch(settingsActionProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('الإعدادات', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.white, surfaceTintColor: Colors.white),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: ElevatedButton(onPressed: () => ref.invalidate(settingsProvider), child: Text('إعادة - $e'))),
        data: (settings) {
          _loadSettings(settings);
          return Stack(children: [
            SingleChildScrollView(padding: const EdgeInsets.all(24), child: Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('إعدادات التطبيق', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(controller: _appNameCtrl, decoration: const InputDecoration(labelText: 'اسم التطبيق', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _deliveryFeeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سعر التوصيل الافتراضي (دج)', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _commissionCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'نسبة العمولة %', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('وضع الصيانة'),
                subtitle: const Text('تعطيل التطبيق مؤقتاً'),
                value: _maintenance,
                onChanged: (v) => setState(() => _maintenance = v),
              ),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: isSaving ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C3E50), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
                child: isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('حفظ الإعدادات'),
              )),
            ])))),
            if (isSaving) Positioned.fill(child: Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator()))),
          ]);
        },
      ),
    );
  }
}
