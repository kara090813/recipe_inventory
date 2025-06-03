// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Food _$FoodFromJson(Map<String, dynamic> json) {
  return _Food.fromJson(json);
}

/// @nodoc
mixin _$Food {
  @HiveField(0)
  String get name => throw _privateConstructorUsedError;
  @HiveField(1)
  String get type => throw _privateConstructorUsedError;
  @HiveField(2)
  String get img => throw _privateConstructorUsedError;
  @HiveField(3)
  int get order => throw _privateConstructorUsedError;
  @HiveField(4)
  List<String> get similarNames => throw _privateConstructorUsedError;
  @HiveField(5)
  bool get isCustom => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FoodCopyWith<Food> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FoodCopyWith<$Res> {
  factory $FoodCopyWith(Food value, $Res Function(Food) then) =
      _$FoodCopyWithImpl<$Res, Food>;
  @useResult
  $Res call(
      {@HiveField(0) String name,
      @HiveField(1) String type,
      @HiveField(2) String img,
      @HiveField(3) int order,
      @HiveField(4) List<String> similarNames,
      @HiveField(5) bool isCustom});
}

/// @nodoc
class _$FoodCopyWithImpl<$Res, $Val extends Food>
    implements $FoodCopyWith<$Res> {
  _$FoodCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? img = null,
    Object? order = null,
    Object? similarNames = null,
    Object? isCustom = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      img: null == img
          ? _value.img
          : img // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      similarNames: null == similarNames
          ? _value.similarNames
          : similarNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isCustom: null == isCustom
          ? _value.isCustom
          : isCustom // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FoodImplCopyWith<$Res> implements $FoodCopyWith<$Res> {
  factory _$$FoodImplCopyWith(
          _$FoodImpl value, $Res Function(_$FoodImpl) then) =
      __$$FoodImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String name,
      @HiveField(1) String type,
      @HiveField(2) String img,
      @HiveField(3) int order,
      @HiveField(4) List<String> similarNames,
      @HiveField(5) bool isCustom});
}

/// @nodoc
class __$$FoodImplCopyWithImpl<$Res>
    extends _$FoodCopyWithImpl<$Res, _$FoodImpl>
    implements _$$FoodImplCopyWith<$Res> {
  __$$FoodImplCopyWithImpl(_$FoodImpl _value, $Res Function(_$FoodImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? img = null,
    Object? order = null,
    Object? similarNames = null,
    Object? isCustom = null,
  }) {
    return _then(_$FoodImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      img: null == img
          ? _value.img
          : img // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      similarNames: null == similarNames
          ? _value._similarNames
          : similarNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isCustom: null == isCustom
          ? _value.isCustom
          : isCustom // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FoodImpl implements _Food {
  const _$FoodImpl(
      {@HiveField(0) required this.name,
      @HiveField(1) required this.type,
      @HiveField(2) required this.img,
      @HiveField(3) this.order = 0,
      @HiveField(4) final List<String> similarNames = const [],
      @HiveField(5) this.isCustom = false})
      : _similarNames = similarNames;

  factory _$FoodImpl.fromJson(Map<String, dynamic> json) =>
      _$$FoodImplFromJson(json);

  @override
  @HiveField(0)
  final String name;
  @override
  @HiveField(1)
  final String type;
  @override
  @HiveField(2)
  final String img;
  @override
  @JsonKey()
  @HiveField(3)
  final int order;
  final List<String> _similarNames;
  @override
  @JsonKey()
  @HiveField(4)
  List<String> get similarNames {
    if (_similarNames is EqualUnmodifiableListView) return _similarNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_similarNames);
  }

  @override
  @JsonKey()
  @HiveField(5)
  final bool isCustom;

  @override
  String toString() {
    return 'Food(name: $name, type: $type, img: $img, order: $order, similarNames: $similarNames, isCustom: $isCustom)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FoodImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.img, img) || other.img == img) &&
            (identical(other.order, order) || other.order == order) &&
            const DeepCollectionEquality()
                .equals(other._similarNames, _similarNames) &&
            (identical(other.isCustom, isCustom) ||
                other.isCustom == isCustom));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, type, img, order,
      const DeepCollectionEquality().hash(_similarNames), isCustom);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FoodImplCopyWith<_$FoodImpl> get copyWith =>
      __$$FoodImplCopyWithImpl<_$FoodImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FoodImplToJson(
      this,
    );
  }
}

abstract class _Food implements Food {
  const factory _Food(
      {@HiveField(0) required final String name,
      @HiveField(1) required final String type,
      @HiveField(2) required final String img,
      @HiveField(3) final int order,
      @HiveField(4) final List<String> similarNames,
      @HiveField(5) final bool isCustom}) = _$FoodImpl;

  factory _Food.fromJson(Map<String, dynamic> json) = _$FoodImpl.fromJson;

  @override
  @HiveField(0)
  String get name;
  @override
  @HiveField(1)
  String get type;
  @override
  @HiveField(2)
  String get img;
  @override
  @HiveField(3)
  int get order;
  @override
  @HiveField(4)
  List<String> get similarNames;
  @override
  @HiveField(5)
  bool get isCustom;
  @override
  @JsonKey(ignore: true)
  _$$FoodImplCopyWith<_$FoodImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
