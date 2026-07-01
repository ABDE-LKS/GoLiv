// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_template_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FavoriteTemplateModelImpl _$$FavoriteTemplateModelImplFromJson(
        Map<String, dynamic> json) =>
    _$FavoriteTemplateModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      categoryId: json['categoryId'] as String,
      requestText: json['requestText'] as String,
    );

Map<String, dynamic> _$$FavoriteTemplateModelImplToJson(
        _$FavoriteTemplateModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'categoryId': instance.categoryId,
      'requestText': instance.requestText,
    };
