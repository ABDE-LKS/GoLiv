import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_model.freezed.dart';
part 'store_model.g.dart';

@freezed
class StoreModel with _$StoreModel {
  const factory StoreModel({
    required String id,
    required String name,
    required String category,
    required double rating,
    required int reviewCount,
    required String deliveryTime,
    required int deliveryFee,
    required int minimumOrder,
    required String distance,
    required bool isOpen,
    required bool isFeatured,
    required bool hasPromotion,
    String? promotionLabel,
    required String coverImage,
    required String address,
  }) = _StoreModel;

  factory StoreModel.fromJson(Map<String, dynamic> json) => _$StoreModelFromJson(json);
}
