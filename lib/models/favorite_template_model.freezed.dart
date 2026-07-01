// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorite_template_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FavoriteTemplateModel _$FavoriteTemplateModelFromJson(
    Map<String, dynamic> json) {
  return _FavoriteTemplateModel.fromJson(json);
}

/// @nodoc
mixin _$FavoriteTemplateModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get categoryId => throw _privateConstructorUsedError;
  String get requestText => throw _privateConstructorUsedError;

  /// Serializes this FavoriteTemplateModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FavoriteTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FavoriteTemplateModelCopyWith<FavoriteTemplateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FavoriteTemplateModelCopyWith<$Res> {
  factory $FavoriteTemplateModelCopyWith(FavoriteTemplateModel value,
          $Res Function(FavoriteTemplateModel) then) =
      _$FavoriteTemplateModelCopyWithImpl<$Res, FavoriteTemplateModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String category,
      String categoryId,
      String requestText});
}

/// @nodoc
class _$FavoriteTemplateModelCopyWithImpl<$Res,
        $Val extends FavoriteTemplateModel>
    implements $FavoriteTemplateModelCopyWith<$Res> {
  _$FavoriteTemplateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FavoriteTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? categoryId = null,
    Object? requestText = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      requestText: null == requestText
          ? _value.requestText
          : requestText // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FavoriteTemplateModelImplCopyWith<$Res>
    implements $FavoriteTemplateModelCopyWith<$Res> {
  factory _$$FavoriteTemplateModelImplCopyWith(
          _$FavoriteTemplateModelImpl value,
          $Res Function(_$FavoriteTemplateModelImpl) then) =
      __$$FavoriteTemplateModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String category,
      String categoryId,
      String requestText});
}

/// @nodoc
class __$$FavoriteTemplateModelImplCopyWithImpl<$Res>
    extends _$FavoriteTemplateModelCopyWithImpl<$Res,
        _$FavoriteTemplateModelImpl>
    implements _$$FavoriteTemplateModelImplCopyWith<$Res> {
  __$$FavoriteTemplateModelImplCopyWithImpl(_$FavoriteTemplateModelImpl _value,
      $Res Function(_$FavoriteTemplateModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of FavoriteTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? categoryId = null,
    Object? requestText = null,
  }) {
    return _then(_$FavoriteTemplateModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      requestText: null == requestText
          ? _value.requestText
          : requestText // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FavoriteTemplateModelImpl implements _FavoriteTemplateModel {
  const _$FavoriteTemplateModelImpl(
      {required this.id,
      required this.name,
      required this.category,
      required this.categoryId,
      required this.requestText});

  factory _$FavoriteTemplateModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FavoriteTemplateModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String category;
  @override
  final String categoryId;
  @override
  final String requestText;

  @override
  String toString() {
    return 'FavoriteTemplateModel(id: $id, name: $name, category: $category, categoryId: $categoryId, requestText: $requestText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FavoriteTemplateModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.requestText, requestText) ||
                other.requestText == requestText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, category, categoryId, requestText);

  /// Create a copy of FavoriteTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FavoriteTemplateModelImplCopyWith<_$FavoriteTemplateModelImpl>
      get copyWith => __$$FavoriteTemplateModelImplCopyWithImpl<
          _$FavoriteTemplateModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FavoriteTemplateModelImplToJson(
      this,
    );
  }
}

abstract class _FavoriteTemplateModel implements FavoriteTemplateModel {
  const factory _FavoriteTemplateModel(
      {required final String id,
      required final String name,
      required final String category,
      required final String categoryId,
      required final String requestText}) = _$FavoriteTemplateModelImpl;

  factory _FavoriteTemplateModel.fromJson(Map<String, dynamic> json) =
      _$FavoriteTemplateModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get category;
  @override
  String get categoryId;
  @override
  String get requestText;

  /// Create a copy of FavoriteTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FavoriteTemplateModelImplCopyWith<_$FavoriteTemplateModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
