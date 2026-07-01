// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OfferModelImpl _$$OfferModelImplFromJson(Map<String, dynamic> json) =>
    _$OfferModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      storeId: json['storeId'] as String,
      storeName: json['storeName'] as String,
      imageUrl: json['imageUrl'] as String?,
      storeLogoUrl: json['storeLogoUrl'] as String?,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      currency: json['currency'] as String? ?? 'دج',
    );

Map<String, dynamic> _$$OfferModelImplToJson(_$OfferModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'storeId': instance.storeId,
      'storeName': instance.storeName,
      'imageUrl': instance.imageUrl,
      'storeLogoUrl': instance.storeLogoUrl,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'currency': instance.currency,
    };
