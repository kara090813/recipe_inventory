// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CookingHistory _$CookingHistoryFromJson(Map<String, dynamic> json) {
  return _CookingHistory.fromJson(json);
}

/// @nodoc
mixin _$CookingHistory {
  @HiveField(0)
  Recipe get recipe => throw _privateConstructorUsedError;
  @HiveField(1)
  DateTime get dateTime => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CookingHistoryCopyWith<CookingHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CookingHistoryCopyWith<$Res> {
  factory $CookingHistoryCopyWith(
          CookingHistory value, $Res Function(CookingHistory) then) =
      _$CookingHistoryCopyWithImpl<$Res, CookingHistory>;
  @useResult
  $Res call({@HiveField(0) Recipe recipe, @HiveField(1) DateTime dateTime});

  $RecipeCopyWith<$Res> get recipe;
}

/// @nodoc
class _$CookingHistoryCopyWithImpl<$Res, $Val extends CookingHistory>
    implements $CookingHistoryCopyWith<$Res> {
  _$CookingHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipe = null,
    Object? dateTime = null,
  }) {
    return _then(_value.copyWith(
      recipe: null == recipe
          ? _value.recipe
          : recipe // ignore: cast_nullable_to_non_nullable
              as Recipe,
      dateTime: null == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RecipeCopyWith<$Res> get recipe {
    return $RecipeCopyWith<$Res>(_value.recipe, (value) {
      return _then(_value.copyWith(recipe: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CookingHistoryImplCopyWith<$Res>
    implements $CookingHistoryCopyWith<$Res> {
  factory _$$CookingHistoryImplCopyWith(_$CookingHistoryImpl value,
          $Res Function(_$CookingHistoryImpl) then) =
      __$$CookingHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@HiveField(0) Recipe recipe, @HiveField(1) DateTime dateTime});

  @override
  $RecipeCopyWith<$Res> get recipe;
}

/// @nodoc
class __$$CookingHistoryImplCopyWithImpl<$Res>
    extends _$CookingHistoryCopyWithImpl<$Res, _$CookingHistoryImpl>
    implements _$$CookingHistoryImplCopyWith<$Res> {
  __$$CookingHistoryImplCopyWithImpl(
      _$CookingHistoryImpl _value, $Res Function(_$CookingHistoryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipe = null,
    Object? dateTime = null,
  }) {
    return _then(_$CookingHistoryImpl(
      recipe: null == recipe
          ? _value.recipe
          : recipe // ignore: cast_nullable_to_non_nullable
              as Recipe,
      dateTime: null == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CookingHistoryImpl implements _CookingHistory {
  _$CookingHistoryImpl(
      {@HiveField(0) required this.recipe,
      @HiveField(1) required this.dateTime});

  factory _$CookingHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$CookingHistoryImplFromJson(json);

  @override
  @HiveField(0)
  final Recipe recipe;
  @override
  @HiveField(1)
  final DateTime dateTime;

  @override
  String toString() {
    return 'CookingHistory(recipe: $recipe, dateTime: $dateTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CookingHistoryImpl &&
            (identical(other.recipe, recipe) || other.recipe == recipe) &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, recipe, dateTime);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CookingHistoryImplCopyWith<_$CookingHistoryImpl> get copyWith =>
      __$$CookingHistoryImplCopyWithImpl<_$CookingHistoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CookingHistoryImplToJson(
      this,
    );
  }
}

abstract class _CookingHistory implements CookingHistory {
  factory _CookingHistory(
      {@HiveField(0) required final Recipe recipe,
      @HiveField(1) required final DateTime dateTime}) = _$CookingHistoryImpl;

  factory _CookingHistory.fromJson(Map<String, dynamic> json) =
      _$CookingHistoryImpl.fromJson;

  @override
  @HiveField(0)
  Recipe get recipe;
  @override
  @HiveField(1)
  DateTime get dateTime;
  @override
  @JsonKey(ignore: true)
  _$$CookingHistoryImplCopyWith<_$CookingHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OngoingCooking _$OngoingCookingFromJson(Map<String, dynamic> json) {
  return _OngoingCooking.fromJson(json);
}

/// @nodoc
mixin _$OngoingCooking {
  @HiveField(0)
  Recipe get recipe => throw _privateConstructorUsedError;
  @HiveField(1)
  DateTime get startTime => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OngoingCookingCopyWith<OngoingCooking> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OngoingCookingCopyWith<$Res> {
  factory $OngoingCookingCopyWith(
          OngoingCooking value, $Res Function(OngoingCooking) then) =
      _$OngoingCookingCopyWithImpl<$Res, OngoingCooking>;
  @useResult
  $Res call({@HiveField(0) Recipe recipe, @HiveField(1) DateTime startTime});

  $RecipeCopyWith<$Res> get recipe;
}

/// @nodoc
class _$OngoingCookingCopyWithImpl<$Res, $Val extends OngoingCooking>
    implements $OngoingCookingCopyWith<$Res> {
  _$OngoingCookingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipe = null,
    Object? startTime = null,
  }) {
    return _then(_value.copyWith(
      recipe: null == recipe
          ? _value.recipe
          : recipe // ignore: cast_nullable_to_non_nullable
              as Recipe,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RecipeCopyWith<$Res> get recipe {
    return $RecipeCopyWith<$Res>(_value.recipe, (value) {
      return _then(_value.copyWith(recipe: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OngoingCookingImplCopyWith<$Res>
    implements $OngoingCookingCopyWith<$Res> {
  factory _$$OngoingCookingImplCopyWith(_$OngoingCookingImpl value,
          $Res Function(_$OngoingCookingImpl) then) =
      __$$OngoingCookingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@HiveField(0) Recipe recipe, @HiveField(1) DateTime startTime});

  @override
  $RecipeCopyWith<$Res> get recipe;
}

/// @nodoc
class __$$OngoingCookingImplCopyWithImpl<$Res>
    extends _$OngoingCookingCopyWithImpl<$Res, _$OngoingCookingImpl>
    implements _$$OngoingCookingImplCopyWith<$Res> {
  __$$OngoingCookingImplCopyWithImpl(
      _$OngoingCookingImpl _value, $Res Function(_$OngoingCookingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipe = null,
    Object? startTime = null,
  }) {
    return _then(_$OngoingCookingImpl(
      recipe: null == recipe
          ? _value.recipe
          : recipe // ignore: cast_nullable_to_non_nullable
              as Recipe,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OngoingCookingImpl implements _OngoingCooking {
  _$OngoingCookingImpl(
      {@HiveField(0) required this.recipe,
      @HiveField(1) required this.startTime});

  factory _$OngoingCookingImpl.fromJson(Map<String, dynamic> json) =>
      _$$OngoingCookingImplFromJson(json);

  @override
  @HiveField(0)
  final Recipe recipe;
  @override
  @HiveField(1)
  final DateTime startTime;

  @override
  String toString() {
    return 'OngoingCooking(recipe: $recipe, startTime: $startTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OngoingCookingImpl &&
            (identical(other.recipe, recipe) || other.recipe == recipe) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, recipe, startTime);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OngoingCookingImplCopyWith<_$OngoingCookingImpl> get copyWith =>
      __$$OngoingCookingImplCopyWithImpl<_$OngoingCookingImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OngoingCookingImplToJson(
      this,
    );
  }
}

abstract class _OngoingCooking implements OngoingCooking {
  factory _OngoingCooking(
      {@HiveField(0) required final Recipe recipe,
      @HiveField(1) required final DateTime startTime}) = _$OngoingCookingImpl;

  factory _OngoingCooking.fromJson(Map<String, dynamic> json) =
      _$OngoingCookingImpl.fromJson;

  @override
  @HiveField(0)
  Recipe get recipe;
  @override
  @HiveField(1)
  DateTime get startTime;
  @override
  @JsonKey(ignore: true)
  _$$OngoingCookingImplCopyWith<_$OngoingCookingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
