// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ingredient_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DisplayIngredient _$DisplayIngredientFromJson(Map<String, dynamic> json) {
  return _DisplayIngredient.fromJson(json);
}

/// @nodoc
mixin _$DisplayIngredient {
  String get food => throw _privateConstructorUsedError;
  String get cnt => throw _privateConstructorUsedError;
  String get img => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DisplayIngredientCopyWith<DisplayIngredient> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DisplayIngredientCopyWith<$Res> {
  factory $DisplayIngredientCopyWith(
          DisplayIngredient value, $Res Function(DisplayIngredient) then) =
      _$DisplayIngredientCopyWithImpl<$Res, DisplayIngredient>;
  @useResult
  $Res call({String food, String cnt, String img, String type});
}

/// @nodoc
class _$DisplayIngredientCopyWithImpl<$Res, $Val extends DisplayIngredient>
    implements $DisplayIngredientCopyWith<$Res> {
  _$DisplayIngredientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? food = null,
    Object? cnt = null,
    Object? img = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      food: null == food
          ? _value.food
          : food // ignore: cast_nullable_to_non_nullable
              as String,
      cnt: null == cnt
          ? _value.cnt
          : cnt // ignore: cast_nullable_to_non_nullable
              as String,
      img: null == img
          ? _value.img
          : img // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DisplayIngredientImplCopyWith<$Res>
    implements $DisplayIngredientCopyWith<$Res> {
  factory _$$DisplayIngredientImplCopyWith(_$DisplayIngredientImpl value,
          $Res Function(_$DisplayIngredientImpl) then) =
      __$$DisplayIngredientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String food, String cnt, String img, String type});
}

/// @nodoc
class __$$DisplayIngredientImplCopyWithImpl<$Res>
    extends _$DisplayIngredientCopyWithImpl<$Res, _$DisplayIngredientImpl>
    implements _$$DisplayIngredientImplCopyWith<$Res> {
  __$$DisplayIngredientImplCopyWithImpl(_$DisplayIngredientImpl _value,
      $Res Function(_$DisplayIngredientImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? food = null,
    Object? cnt = null,
    Object? img = null,
    Object? type = null,
  }) {
    return _then(_$DisplayIngredientImpl(
      food: null == food
          ? _value.food
          : food // ignore: cast_nullable_to_non_nullable
              as String,
      cnt: null == cnt
          ? _value.cnt
          : cnt // ignore: cast_nullable_to_non_nullable
              as String,
      img: null == img
          ? _value.img
          : img // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DisplayIngredientImpl implements _DisplayIngredient {
  _$DisplayIngredientImpl(
      {required this.food,
      required this.cnt,
      required this.img,
      required this.type});

  factory _$DisplayIngredientImpl.fromJson(Map<String, dynamic> json) =>
      _$$DisplayIngredientImplFromJson(json);

  @override
  final String food;
  @override
  final String cnt;
  @override
  final String img;
  @override
  final String type;

  @override
  String toString() {
    return 'DisplayIngredient(food: $food, cnt: $cnt, img: $img, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DisplayIngredientImpl &&
            (identical(other.food, food) || other.food == food) &&
            (identical(other.cnt, cnt) || other.cnt == cnt) &&
            (identical(other.img, img) || other.img == img) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, food, cnt, img, type);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DisplayIngredientImplCopyWith<_$DisplayIngredientImpl> get copyWith =>
      __$$DisplayIngredientImplCopyWithImpl<_$DisplayIngredientImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DisplayIngredientImplToJson(
      this,
    );
  }
}

abstract class _DisplayIngredient implements DisplayIngredient {
  factory _DisplayIngredient(
      {required final String food,
      required final String cnt,
      required final String img,
      required final String type}) = _$DisplayIngredientImpl;

  factory _DisplayIngredient.fromJson(Map<String, dynamic> json) =
      _$DisplayIngredientImpl.fromJson;

  @override
  String get food;
  @override
  String get cnt;
  @override
  String get img;
  @override
  String get type;
  @override
  @JsonKey(ignore: true)
  _$$DisplayIngredientImplCopyWith<_$DisplayIngredientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
