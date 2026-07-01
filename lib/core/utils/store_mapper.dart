import 'package:wassali/models/store_model.dart';

StoreModel mapStoreFromBackend(Map<String, dynamic> json) {
  final category = json['category'];
  final categoryName = category is Map ? (category['name']?.toString() ?? '') : (json['category']?.toString() ?? '');
  final minTime = (json['minDeliveryTime'] as num?)?.toInt() ?? 20;
  final maxTime = (json['maxDeliveryTime'] as num?)?.toInt() ?? 45;

  return StoreModel(
    id: json['id'] as String,
    name: json['name'] as String,
    category: categoryName,
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
    reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
    deliveryTime: '$minTime-$maxTime دقيقة',
    deliveryFee: (json['deliveryFee'] as num?)?.toInt() ?? 0,
    minimumOrder: (json['minOrderAmount'] as num?)?.toInt() ?? 0,
    distance: '—',
    isOpen: json['isActive'] as bool? ?? true,
    isFeatured: json['isFeatured'] as bool? ?? false,
    hasPromotion: false,
    promotionLabel: null,
    coverImage: json['banner']?.toString() ?? json['logo']?.toString() ?? '',
    address: json['address']?.toString() ?? '',
  );
}
