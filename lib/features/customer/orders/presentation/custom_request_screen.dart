import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import '../custom_request_provider.dart';

class CustomRequestScreen extends ConsumerStatefulWidget {
  const CustomRequestScreen({super.key});

  @override
  ConsumerState<CustomRequestScreen> createState() => _CustomRequestScreenState();
}

class _CustomRequestScreenState extends ConsumerState<CustomRequestScreen> {
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _notesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(customRequestNotifierProvider.notifier).submitCustomRequest(
        _notesController.text,
        _locationController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customRequestNotifierProvider);

    ref.listen<CustomRequestState>(customRequestNotifierProvider, (previous, next) {
      if (next.isSuccess) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('تم استلام طلبك!'),
            content: const Text('جاري البحث عن سائق لتنفيذ طلبك. يمكنك متابعة حالة الطلب في قسم الطلبات.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ref.read(customRequestNotifierProvider.notifier).reset();
                  context.go('/orders');
                },
                style: ElevatedButton.styleFrom(backgroundColor: ColorTokens.primary, foregroundColor: Colors.white),
                child: const Text('متابعة'),
              )
            ],
          ),
        );
      }
      if (next.error != null && (previous?.error != next.error)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      backgroundColor: ColorTokens.background,
      appBar: AppBar(
        title: const Text('طلب خاص', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Illustration or Header Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: ColorTokens.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.two_wheeler_rounded, size: 64, color: ColorTokens.primary),
                  ),
                ),
                const SizedBox(height: 32),
                
                Text(
                  'ماذا تحتاج؟',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColorTokens.textPrimary),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'اكتب كل ما تريد شِرائه أو جلبه هنا بكل تفصيل...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'الرجاء كتابة طلبك أولاً' : null,
                ),
                const SizedBox(height: 16),
                
                TextButton.icon(
                  onPressed: () {
                    // Future Image Picker Plugin Placeholder
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('إرفاق الصور سيتم تفعيله لاحقاً')),
                    );
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('إرفاق صورة للمنتج (اختياري)'),
                  style: TextButton.styleFrom(foregroundColor: ColorTokens.primary),
                ),
                const SizedBox(height: 24),
                
                Text(
                  'موقع التوصيل',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColorTokens.textPrimary),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: 'مثال: حي وسط المدينة، بجوار المسجد الكبير',
                    prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'الرجاء تحديد موقع التوصيل' : null,
                ),
                const SizedBox(height: 48),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTokens.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    child: state.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('إرسال الطلب الآن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'سيتم تعيين أقرب سائق متاح فوراً.',
                    style: TextStyle(color: ColorTokens.textSecondary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
