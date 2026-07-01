import 'package:wassali/models/product_model.dart';

ProductModel mapProductFromBackend(Map<String, dynamic> json) {
  final store = json['store'];
  String category = '';
  if (store is Map && store['category'] is Map) {
    category = store['category']['name']?.toString() ?? '';
  }

  return ProductModel(
    id: json['id'] as String,
    storeId: json['storeId'] as String,
    name: json['name'] as String,
    description: json['description']?.toString() ?? '',
    price: (json['price'] as num?)?.toInt() ?? 0,
    image: json['image']?.toString() ?? '',
    category: category,
  );
}
