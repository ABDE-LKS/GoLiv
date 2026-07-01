import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_template_model.freezed.dart';
part 'favorite_template_model.g.dart';

@freezed
class FavoriteTemplateModel with _$FavoriteTemplateModel {
  const factory FavoriteTemplateModel({
    required String id,
    required String name,
    required String category,
    required String categoryId,
    required String requestText,
  }) = _FavoriteTemplateModel;

  factory FavoriteTemplateModel.fromJson(Map<String, dynamic> json) => _$FavoriteTemplateModelFromJson(json);
}
