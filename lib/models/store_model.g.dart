// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoreModelImpl _$$StoreModelImplFromJson(Map<String, dynamic> json) =>
    _$StoreModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      deliveryTime: json['deliveryTime'] as String,
      deliveryFee: (json['deliveryFee'] as num).toInt(),
      minimumOrder: (json['minimumOrder'] as num).toInt(),
      distance: json['distance'] as String,
      isOpen: json['isOpen'] as bool,
      isFeatured: json['isFeatured'] as bool,
      hasPromotion: json['hasPromotion'] as bool,
      promotionLabel: json['promotionLabel'] as String?,
      coverImage: json['coverImage'] as String,
      address: json['address'] as String,
    );

Map<String, dynamic> _$$StoreModelImplToJson(_$StoreModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'deliveryTime': instance.deliveryTime,
      'deliveryFee': instance.deliveryFee,
      'minimumOrder': instance.minimumOrder,
      'distance': instance.distance,
      'isOpen': instance.isOpen,
      'isFeatured': instance.isFeatured,
      'hasPromotion': instance.hasPromotion,
      'promotionLabel': instance.promotionLabel,
      'coverImage': instance.coverImage,
      'address': instance.address,
    };
