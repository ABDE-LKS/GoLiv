import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import 'package:wassali/repositories/advertisement_repository.dart';
import 'package:wassali/features/customer/home/home_provider.dart';

class CreateAdScreen extends ConsumerStatefulWidget {
  const CreateAdScreen({super.key});

  @override
  ConsumerState<CreateAdScreen> createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends ConsumerState<CreateAdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String? _selectedCategory;
  String _selectedCondition = 'used_good';
  bool _isNegotiable = false;
  List<File> _images = [];
  bool _isLoading = false;

  final Map<String, String> _conditions = {
    'new_condition': 'جديد',
    'used_like_new': 'مستعمل كأنه جديد',
    'used_good': 'مستعمل بحالة جيدة',
    'used_fair': 'مستعمل بحالة متوسطة',
  };

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((e) => File(e.path)));
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار قسم')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // In a real app, you'd upload images first and get URLs
      // For now, let's mock the image strings or use placeholders
      // Since the backend expects array of objects/strings
      
      final repository = ref.read(advertisementRepositoryProvider);
      await repository.createAdvertisement({
        'title': _titleController.text,
        'description': _descController.text,
        'price': double.parse(_priceController.text),
        'categoryId': _selectedCategory,
        'isNegotiable': _isNegotiable,
        'condition': _selectedCondition,
        'location': 'القرارة',
        'images': [
          {'url': 'https://placehold.co/600x400?text=Ad+Image+1'},
          {'url': 'https://placehold.co/600x400?text=Ad+Image+2'},
        ],
      });

      if (mounted) {
        ref.invalidate(homeProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم نشر إعلانك بنجاح!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeData = ref.watch(homeProvider);
    final categories = homeData.asData?.value['categories'] as List? ?? [];

    return Scaffold(
      backgroundColor: ColorTokens.background,
      appBar: AppBar(
        title: const Text('أضف إعلان جديد', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Image Picker
                    const Text('صور الإعلان', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[400]!, style: BorderStyle.solid),
                              ),
                              child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
                            ),
                          ),
                          ..._images.map((file) => Container(
                            width: 100,
                            margin: const EdgeInsets.only(left: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
                            ),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                onPressed: () => setState(() => _images.remove(file)),
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. Title & Category
                    _buildTextField(_titleController, 'عنوان الإعلان', 'مثال: ايفون 15 برو جديد'),
                    const SizedBox(height: 16),
                    
                    const Text('القسم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      hint: const Text('اختر القسم المناسب'),
                      items: categories.map((cat) => DropdownMenuItem(
                        value: cat['id'] as String,
                        child: Text(cat['name']),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                    ),
                    const SizedBox(height: 24),

                    // 3. Price & Negotiable
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_priceController, 'السعر', '0', keyboardType: TextInputType.number)),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('قابل للتفاوض', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Switch(
                              value: _isNegotiable,
                              onChanged: (val) => setState(() => _isNegotiable = val),
                              activeColor: ColorTokens.primary,
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 4. Condition
                    const Text('حالة المنتج', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _conditions.entries.map((e) => ChoiceChip(
                        label: Text(e.value),
                        selected: _selectedCondition == e.key,
                        onSelected: (val) => setState(() => _selectedCondition = e.key),
                        selectedColor: ColorTokens.primary.withOpacity(0.2),
                        labelStyle: TextStyle(color: _selectedCondition == e.key ? ColorTokens.primary : Colors.black87),
                      )).toList(),
                    ),
                    const SizedBox(height: 24),

                    // 5. Description
                    _buildTextField(_descController, 'الوصف بالتفصيل', 'تحدث عن حالة المنتج، الملحقات، إلخ...', maxLines: 5),
                    const SizedBox(height: 24),

                    // 6. Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorTokens.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('نشر الإعلان الآن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          validator: (val) => val == null || val.isEmpty ? 'هذا الحقل مطلوب' : null,
        ),
      ],
    );
  }
}
