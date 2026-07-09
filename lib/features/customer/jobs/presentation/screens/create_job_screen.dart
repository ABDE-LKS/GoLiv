import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:wassali/repositories/job_repository.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _reqsController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _contactController = TextEditingController();
  
  String? _selectedEmploymentType = 'FULL_TIME';
  String? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    _reqsController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء تعبئة جميع الحقول المطلوبة')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 1)); // Mock uploading Job
      
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نشر الوظيفة بنجاح!'), backgroundColor: Colors.green));
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
        title: const Text('نشر عرض عمل', style: TextStyle(fontWeight: FontWeight.bold, color: ColorTokens.textPrimary)),
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
              _buildTextField(_titleController, 'المسمى الوظيفي (مثال: مطور برمجيات)', Icons.work_outline_rounded),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(flex: 2, child: _buildTextField(_companyController, 'اسم الشركة/جهة العمل', Icons.business_rounded)),
                  const SizedBox(width: 16),
                  Expanded(flex: 1, child: _buildDropdownCat()),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(_locationController, 'مكان العمل (المدينة/الولائية)', Icons.location_on_outlined),
              const SizedBox(height: 32),
              
              _buildSectionTitle('تفاصيل الوظيفة'),
              _buildTextField(_descriptionController, 'وصف دور الوظيفة...', Icons.description_outlined, maxLines: 4),
              const SizedBox(height: 16),
              _buildTextField(_reqsController, 'الشروط والمتطلبات الأساسية...', Icons.checklist_rtl_rounded, maxLines: 3),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(child: _buildEmploymentTypeDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_salaryController, 'الراتب (اختياري)', Icons.payments_outlined)),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(_contactController, 'طريقة التواصل (بريد، هاتف)', Icons.contact_mail_outlined),
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981), // Emerald for Jobs
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('نشر الوظيفة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
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

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: maxLines == 1 ? Icon(icon, color: ColorTokens.textMuted) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildDropdownCat() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: 'التصنيف',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      items: const [
        DropdownMenuItem(value: '1', child: Text('تقنية')),
        DropdownMenuItem(value: '2', child: Text('بناء')),
      ],
      onChanged: (val) => setState(() => _selectedCategoryId = val),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildEmploymentTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedEmploymentType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      items: const [
        DropdownMenuItem(value: 'FULL_TIME', child: Text('دوام كامل')),
        DropdownMenuItem(value: 'PART_TIME', child: Text('دوام جزئي')),
        DropdownMenuItem(value: 'FREELANCE', child: Text('عمل حر')),
        DropdownMenuItem(value: 'INTERNSHIP', child: Text('تدريب')),
      ],
      onChanged: (val) => setState(() => _selectedEmploymentType = val),
    ).animate().fadeIn().slideX(begin: 0.1);
  }
}
