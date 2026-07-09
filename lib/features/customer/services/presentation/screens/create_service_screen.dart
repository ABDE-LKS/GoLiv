import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:wassali/repositories/service_repository.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CreateServiceScreen extends ConsumerStatefulWidget {
  const CreateServiceScreen({super.key});

  @override
  ConsumerState<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends ConsumerState<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _priceController = TextEditingController();
  final _experienceController = TextEditingController();
  final _availabilityController = TextEditingController();
  
  String? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _priceController.dispose();
    _experienceController.dispose();
    _availabilityController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء تعبئة جميع الحقول المطلوبة')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // API call to create service (assume added to repository later)
      // await ref.read(serviceRepositoryProvider).createService({...});
      await Future.delayed(const Duration(seconds: 1)); // Mocking upload
      
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء الخدمة بنجاح!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.background,
      appBar: AppBar(
        title: const Text('إضافة خدمة جديدة', style: TextStyle(fontWeight: FontWeight.bold, color: ColorTokens.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: ColorTokens.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('المعلومات الأساسية'),
              _buildTextField(_titleController, 'عنوان الخدمة (مثال: كهربائي منازل)', Icons.title),
              const SizedBox(height: 16),
              _buildTextField(_descriptionController, 'وصف تفصيلي للخدمة...', Icons.description_outlined, maxLines: 5),
              const SizedBox(height: 16),
              _buildDropdown(),
              const SizedBox(height: 32),
              
              _buildSectionTitle('تفاصيل إضافية'),
              Row(
                children: [
                  Expanded(child: _buildTextField(_cityController, 'المدينة', Icons.location_on_outlined)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_priceController, 'السعر المتوقع (اختياري)', Icons.payments_outlined, isNumber: true)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(child: _buildTextField(_experienceController, 'الخبرة (مثال: 5 سنوات)', Icons.military_tech_outlined)),
                   const SizedBox(width: 16),
                   Expanded(child: _buildTextField(_availabilityController, 'التواجد (مثال: متفرغ)', Icons.event_available_outlined)),
                ],
              ),
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTokens.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('نشر الخدمة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: ColorTokens.textPrimary)),
    ).animate().fadeIn();
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (val) => val == null || val.isEmpty && !isNumber ? 'مطلوب' : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: maxLines == 1 ? Icon(icon, color: ColorTokens.textMuted) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: ColorTokens.primary, width: 2)),
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: 'التصنيف',
        prefixIcon: const Icon(Icons.category_outlined, color: ColorTokens.textMuted),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      items: const [
        DropdownMenuItem(value: '1', child: Text('تصليح وصيانة')),
        DropdownMenuItem(value: '2', child: Text('بناء ومقاولات')),
        DropdownMenuItem(value: '3', child: Text('تعليم وتدريس')),
      ],
      onChanged: (val) => setState(() => _selectedCategoryId = val),
    ).animate().fadeIn().slideX(begin: 0.1);
  }
}
