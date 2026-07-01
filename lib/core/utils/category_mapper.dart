import 'package:wassali/models/category_model.dart';

CategoryModel mapCategoryFromBackend(Map<String, dynamic> json) {
  return CategoryModel(
    id: json['id'] as String,
    name: json['name'] as String,
    icon: json['icon']?.toString() ?? 'category',
    color: json['color']?.toString() ?? '#4CAF50',
  );
}
