// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'badge_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Badge _$BadgeFromJson(Map<String, dynamic> json) {
  return _Badge.fromJson(json);
}

/// @nodoc
mixin _$Badge {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get name => throw _privateConstructorUsedError;
  @HiveField(2)
  String get description => throw _privateConstructorUsedError;
  @HiveField(3)
  String get imagePath => throw _privateConstructorUsedError;
  @HiveField(4)
  BadgeCategory get category => throw _privateConstructorUsedError;
  @HiveField(5)
  BadgeDifficulty get difficulty => throw _privateConstructorUsedError;
  @HiveField(6)
  BadgeCondition get condition => throw _privateConstructorUsedError;
  @HiveField(7)
  bool get isDesignComplete => throw _privateConstructorUsedError; // 디자인 완료 여부
  @HiveField(8)
  int get sortOrder => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BadgeCopyWith<Badge> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BadgeCopyWith<$Res> {
  factory $BadgeCopyWith(Badge value, $Res Function(Badge) then) =
      _$BadgeCopyWithImpl<$Res, Badge>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String name,
      @HiveField(2) String description,
      @HiveField(3) String imagePath,
      @HiveField(4) BadgeCategory category,
      @HiveField(5) BadgeDifficulty difficulty,
      @HiveField(6) BadgeCondition condition,
      @HiveField(7) bool isDesignComplete,
      @HiveField(8) int sortOrder});

  $BadgeConditionCopyWith<$Res> get condition;
}

/// @nodoc
class _$BadgeCopyWithImpl<$Res, $Val extends Badge>
    implements $BadgeCopyWith<$Res> {
  _$BadgeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? imagePath = null,
    Object? category = null,
    Object? difficulty = null,
    Object? condition = null,
    Object? isDesignComplete = null,
    Object? sortOrder = null,
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
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      imagePath: null == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as BadgeCategory,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as BadgeDifficulty,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as BadgeCondition,
      isDesignComplete: null == isDesignComplete
          ? _value.isDesignComplete
          : isDesignComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BadgeConditionCopyWith<$Res> get condition {
    return $BadgeConditionCopyWith<$Res>(_value.condition, (value) {
      return _then(_value.copyWith(condition: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BadgeImplCopyWith<$Res> implements $BadgeCopyWith<$Res> {
  factory _$$BadgeImplCopyWith(
          _$BadgeImpl value, $Res Function(_$BadgeImpl) then) =
      __$$BadgeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String name,
      @HiveField(2) String description,
      @HiveField(3) String imagePath,
      @HiveField(4) BadgeCategory category,
      @HiveField(5) BadgeDifficulty difficulty,
      @HiveField(6) BadgeCondition condition,
      @HiveField(7) bool isDesignComplete,
      @HiveField(8) int sortOrder});

  @override
  $BadgeConditionCopyWith<$Res> get condition;
}

/// @nodoc
class __$$BadgeImplCopyWithImpl<$Res>
    extends _$BadgeCopyWithImpl<$Res, _$BadgeImpl>
    implements _$$BadgeImplCopyWith<$Res> {
  __$$BadgeImplCopyWithImpl(
      _$BadgeImpl _value, $Res Function(_$BadgeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? imagePath = null,
    Object? category = null,
    Object? difficulty = null,
    Object? condition = null,
    Object? isDesignComplete = null,
    Object? sortOrder = null,
  }) {
    return _then(_$BadgeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      imagePath: null == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as BadgeCategory,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as BadgeDifficulty,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as BadgeCondition,
      isDesignComplete: null == isDesignComplete
          ? _value.isDesignComplete
          : isDesignComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BadgeImpl implements _Badge {
  _$BadgeImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.name,
      @HiveField(2) required this.description,
      @HiveField(3) required this.imagePath,
      @HiveField(4) required this.category,
      @HiveField(5) required this.difficulty,
      @HiveField(6) required this.condition,
      @HiveField(7) this.isDesignComplete = true,
      @HiveField(8) this.sortOrder = 0});

  factory _$BadgeImpl.fromJson(Map<String, dynamic> json) =>
      _$$BadgeImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String name;
  @override
  @HiveField(2)
  final String description;
  @override
  @HiveField(3)
  final String imagePath;
  @override
  @HiveField(4)
  final BadgeCategory category;
  @override
  @HiveField(5)
  final BadgeDifficulty difficulty;
  @override
  @HiveField(6)
  final BadgeCondition condition;
  @override
  @JsonKey()
  @HiveField(7)
  final bool isDesignComplete;
// 디자인 완료 여부
  @override
  @JsonKey()
  @HiveField(8)
  final int sortOrder;

  @override
  String toString() {
    return 'Badge(id: $id, name: $name, description: $description, imagePath: $imagePath, category: $category, difficulty: $difficulty, condition: $condition, isDesignComplete: $isDesignComplete, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BadgeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.isDesignComplete, isDesignComplete) ||
                other.isDesignComplete == isDesignComplete) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, description, imagePath,
      category, difficulty, condition, isDesignComplete, sortOrder);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BadgeImplCopyWith<_$BadgeImpl> get copyWith =>
      __$$BadgeImplCopyWithImpl<_$BadgeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BadgeImplToJson(
      this,
    );
  }
}

abstract class _Badge implements Badge {
  factory _Badge(
      {@HiveField(0) required final String id,
      @HiveField(1) required final String name,
      @HiveField(2) required final String description,
      @HiveField(3) required final String imagePath,
      @HiveField(4) required final BadgeCategory category,
      @HiveField(5) required final BadgeDifficulty difficulty,
      @HiveField(6) required final BadgeCondition condition,
      @HiveField(7) final bool isDesignComplete,
      @HiveField(8) final int sortOrder}) = _$BadgeImpl;

  factory _Badge.fromJson(Map<String, dynamic> json) = _$BadgeImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get name;
  @override
  @HiveField(2)
  String get description;
  @override
  @HiveField(3)
  String get imagePath;
  @override
  @HiveField(4)
  BadgeCategory get category;
  @override
  @HiveField(5)
  BadgeDifficulty get difficulty;
  @override
  @HiveField(6)
  BadgeCondition get condition;
  @override
  @HiveField(7)
  bool get isDesignComplete;
  @override // 디자인 완료 여부
  @HiveField(8)
  int get sortOrder;
  @override
  @JsonKey(ignore: true)
  _$$BadgeImplCopyWith<_$BadgeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BadgeCondition _$BadgeConditionFromJson(Map<String, dynamic> json) {
  return _BadgeCondition.fromJson(json);
}

/// @nodoc
mixin _$BadgeCondition {
  @HiveField(0)
  BadgeType get type => throw _privateConstructorUsedError; // 요리 횟수 관련
  @HiveField(1)
  int? get targetCookingCount => throw _privateConstructorUsedError; // 연속 요리 관련
  @HiveField(2)
  int? get consecutiveDays => throw _privateConstructorUsedError; // 난이도 관련
  @HiveField(3)
  String? get difficulty => throw _privateConstructorUsedError;
  @HiveField(4)
  int? get difficultyCount => throw _privateConstructorUsedError; // 음식 종류 관련
  @HiveField(5)
  String? get recipeType => throw _privateConstructorUsedError;
  @HiveField(6)
  int? get recipeTypeCount => throw _privateConstructorUsedError; // 시간대 관련
  @HiveField(7)
  int? get timeRangeStart =>
      throw _privateConstructorUsedError; // 시작 시간 (24시간 기준)
  @HiveField(8)
  int? get timeRangeEnd =>
      throw _privateConstructorUsedError; // 종료 시간 (24시간 기준)
  @HiveField(9)
  int? get timeBasedCount => throw _privateConstructorUsedError; // 특별 조건
  @HiveField(10)
  int? get wishlistCount => throw _privateConstructorUsedError; // 위시리스트 개수
  @HiveField(11)
  int? get sameRecipeRetryCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BadgeConditionCopyWith<BadgeCondition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BadgeConditionCopyWith<$Res> {
  factory $BadgeConditionCopyWith(
          BadgeCondition value, $Res Function(BadgeCondition) then) =
      _$BadgeConditionCopyWithImpl<$Res, BadgeCondition>;
  @useResult
  $Res call(
      {@HiveField(0) BadgeType type,
      @HiveField(1) int? targetCookingCount,
      @HiveField(2) int? consecutiveDays,
      @HiveField(3) String? difficulty,
      @HiveField(4) int? difficultyCount,
      @HiveField(5) String? recipeType,
      @HiveField(6) int? recipeTypeCount,
      @HiveField(7) int? timeRangeStart,
      @HiveField(8) int? timeRangeEnd,
      @HiveField(9) int? timeBasedCount,
      @HiveField(10) int? wishlistCount,
      @HiveField(11) int? sameRecipeRetryCount});
}

/// @nodoc
class _$BadgeConditionCopyWithImpl<$Res, $Val extends BadgeCondition>
    implements $BadgeConditionCopyWith<$Res> {
  _$BadgeConditionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? targetCookingCount = freezed,
    Object? consecutiveDays = freezed,
    Object? difficulty = freezed,
    Object? difficultyCount = freezed,
    Object? recipeType = freezed,
    Object? recipeTypeCount = freezed,
    Object? timeRangeStart = freezed,
    Object? timeRangeEnd = freezed,
    Object? timeBasedCount = freezed,
    Object? wishlistCount = freezed,
    Object? sameRecipeRetryCount = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as BadgeType,
      targetCookingCount: freezed == targetCookingCount
          ? _value.targetCookingCount
          : targetCookingCount // ignore: cast_nullable_to_non_nullable
              as int?,
      consecutiveDays: freezed == consecutiveDays
          ? _value.consecutiveDays
          : consecutiveDays // ignore: cast_nullable_to_non_nullable
              as int?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String?,
      difficultyCount: freezed == difficultyCount
          ? _value.difficultyCount
          : difficultyCount // ignore: cast_nullable_to_non_nullable
              as int?,
      recipeType: freezed == recipeType
          ? _value.recipeType
          : recipeType // ignore: cast_nullable_to_non_nullable
              as String?,
      recipeTypeCount: freezed == recipeTypeCount
          ? _value.recipeTypeCount
          : recipeTypeCount // ignore: cast_nullable_to_non_nullable
              as int?,
      timeRangeStart: freezed == timeRangeStart
          ? _value.timeRangeStart
          : timeRangeStart // ignore: cast_nullable_to_non_nullable
              as int?,
      timeRangeEnd: freezed == timeRangeEnd
          ? _value.timeRangeEnd
          : timeRangeEnd // ignore: cast_nullable_to_non_nullable
              as int?,
      timeBasedCount: freezed == timeBasedCount
          ? _value.timeBasedCount
          : timeBasedCount // ignore: cast_nullable_to_non_nullable
              as int?,
      wishlistCount: freezed == wishlistCount
          ? _value.wishlistCount
          : wishlistCount // ignore: cast_nullable_to_non_nullable
              as int?,
      sameRecipeRetryCount: freezed == sameRecipeRetryCount
          ? _value.sameRecipeRetryCount
          : sameRecipeRetryCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BadgeConditionImplCopyWith<$Res>
    implements $BadgeConditionCopyWith<$Res> {
  factory _$$BadgeConditionImplCopyWith(_$BadgeConditionImpl value,
          $Res Function(_$BadgeConditionImpl) then) =
      __$$BadgeConditionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) BadgeType type,
      @HiveField(1) int? targetCookingCount,
      @HiveField(2) int? consecutiveDays,
      @HiveField(3) String? difficulty,
      @HiveField(4) int? difficultyCount,
      @HiveField(5) String? recipeType,
      @HiveField(6) int? recipeTypeCount,
      @HiveField(7) int? timeRangeStart,
      @HiveField(8) int? timeRangeEnd,
      @HiveField(9) int? timeBasedCount,
      @HiveField(10) int? wishlistCount,
      @HiveField(11) int? sameRecipeRetryCount});
}

/// @nodoc
class __$$BadgeConditionImplCopyWithImpl<$Res>
    extends _$BadgeConditionCopyWithImpl<$Res, _$BadgeConditionImpl>
    implements _$$BadgeConditionImplCopyWith<$Res> {
  __$$BadgeConditionImplCopyWithImpl(
      _$BadgeConditionImpl _value, $Res Function(_$BadgeConditionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? targetCookingCount = freezed,
    Object? consecutiveDays = freezed,
    Object? difficulty = freezed,
    Object? difficultyCount = freezed,
    Object? recipeType = freezed,
    Object? recipeTypeCount = freezed,
    Object? timeRangeStart = freezed,
    Object? timeRangeEnd = freezed,
    Object? timeBasedCount = freezed,
    Object? wishlistCount = freezed,
    Object? sameRecipeRetryCount = freezed,
  }) {
    return _then(_$BadgeConditionImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as BadgeType,
      targetCookingCount: freezed == targetCookingCount
          ? _value.targetCookingCount
          : targetCookingCount // ignore: cast_nullable_to_non_nullable
              as int?,
      consecutiveDays: freezed == consecutiveDays
          ? _value.consecutiveDays
          : consecutiveDays // ignore: cast_nullable_to_non_nullable
              as int?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String?,
      difficultyCount: freezed == difficultyCount
          ? _value.difficultyCount
          : difficultyCount // ignore: cast_nullable_to_non_nullable
              as int?,
      recipeType: freezed == recipeType
          ? _value.recipeType
          : recipeType // ignore: cast_nullable_to_non_nullable
              as String?,
      recipeTypeCount: freezed == recipeTypeCount
          ? _value.recipeTypeCount
          : recipeTypeCount // ignore: cast_nullable_to_non_nullable
              as int?,
      timeRangeStart: freezed == timeRangeStart
          ? _value.timeRangeStart
          : timeRangeStart // ignore: cast_nullable_to_non_nullable
              as int?,
      timeRangeEnd: freezed == timeRangeEnd
          ? _value.timeRangeEnd
          : timeRangeEnd // ignore: cast_nullable_to_non_nullable
              as int?,
      timeBasedCount: freezed == timeBasedCount
          ? _value.timeBasedCount
          : timeBasedCount // ignore: cast_nullable_to_non_nullable
              as int?,
      wishlistCount: freezed == wishlistCount
          ? _value.wishlistCount
          : wishlistCount // ignore: cast_nullable_to_non_nullable
              as int?,
      sameRecipeRetryCount: freezed == sameRecipeRetryCount
          ? _value.sameRecipeRetryCount
          : sameRecipeRetryCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BadgeConditionImpl implements _BadgeCondition {
  _$BadgeConditionImpl(
      {@HiveField(0) required this.type,
      @HiveField(1) this.targetCookingCount,
      @HiveField(2) this.consecutiveDays,
      @HiveField(3) this.difficulty,
      @HiveField(4) this.difficultyCount,
      @HiveField(5) this.recipeType,
      @HiveField(6) this.recipeTypeCount,
      @HiveField(7) this.timeRangeStart,
      @HiveField(8) this.timeRangeEnd,
      @HiveField(9) this.timeBasedCount,
      @HiveField(10) this.wishlistCount,
      @HiveField(11) this.sameRecipeRetryCount});

  factory _$BadgeConditionImpl.fromJson(Map<String, dynamic> json) =>
      _$$BadgeConditionImplFromJson(json);

  @override
  @HiveField(0)
  final BadgeType type;
// 요리 횟수 관련
  @override
  @HiveField(1)
  final int? targetCookingCount;
// 연속 요리 관련
  @override
  @HiveField(2)
  final int? consecutiveDays;
// 난이도 관련
  @override
  @HiveField(3)
  final String? difficulty;
  @override
  @HiveField(4)
  final int? difficultyCount;
// 음식 종류 관련
  @override
  @HiveField(5)
  final String? recipeType;
  @override
  @HiveField(6)
  final int? recipeTypeCount;
// 시간대 관련
  @override
  @HiveField(7)
  final int? timeRangeStart;
// 시작 시간 (24시간 기준)
  @override
  @HiveField(8)
  final int? timeRangeEnd;
// 종료 시간 (24시간 기준)
  @override
  @HiveField(9)
  final int? timeBasedCount;
// 특별 조건
  @override
  @HiveField(10)
  final int? wishlistCount;
// 위시리스트 개수
  @override
  @HiveField(11)
  final int? sameRecipeRetryCount;

  @override
  String toString() {
    return 'BadgeCondition(type: $type, targetCookingCount: $targetCookingCount, consecutiveDays: $consecutiveDays, difficulty: $difficulty, difficultyCount: $difficultyCount, recipeType: $recipeType, recipeTypeCount: $recipeTypeCount, timeRangeStart: $timeRangeStart, timeRangeEnd: $timeRangeEnd, timeBasedCount: $timeBasedCount, wishlistCount: $wishlistCount, sameRecipeRetryCount: $sameRecipeRetryCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BadgeConditionImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.targetCookingCount, targetCookingCount) ||
                other.targetCookingCount == targetCookingCount) &&
            (identical(other.consecutiveDays, consecutiveDays) ||
                other.consecutiveDays == consecutiveDays) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.difficultyCount, difficultyCount) ||
                other.difficultyCount == difficultyCount) &&
            (identical(other.recipeType, recipeType) ||
                other.recipeType == recipeType) &&
            (identical(other.recipeTypeCount, recipeTypeCount) ||
                other.recipeTypeCount == recipeTypeCount) &&
            (identical(other.timeRangeStart, timeRangeStart) ||
                other.timeRangeStart == timeRangeStart) &&
            (identical(other.timeRangeEnd, timeRangeEnd) ||
                other.timeRangeEnd == timeRangeEnd) &&
            (identical(other.timeBasedCount, timeBasedCount) ||
                other.timeBasedCount == timeBasedCount) &&
            (identical(other.wishlistCount, wishlistCount) ||
                other.wishlistCount == wishlistCount) &&
            (identical(other.sameRecipeRetryCount, sameRecipeRetryCount) ||
                other.sameRecipeRetryCount == sameRecipeRetryCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      type,
      targetCookingCount,
      consecutiveDays,
      difficulty,
      difficultyCount,
      recipeType,
      recipeTypeCount,
      timeRangeStart,
      timeRangeEnd,
      timeBasedCount,
      wishlistCount,
      sameRecipeRetryCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BadgeConditionImplCopyWith<_$BadgeConditionImpl> get copyWith =>
      __$$BadgeConditionImplCopyWithImpl<_$BadgeConditionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BadgeConditionImplToJson(
      this,
    );
  }
}

abstract class _BadgeCondition implements BadgeCondition {
  factory _BadgeCondition(
      {@HiveField(0) required final BadgeType type,
      @HiveField(1) final int? targetCookingCount,
      @HiveField(2) final int? consecutiveDays,
      @HiveField(3) final String? difficulty,
      @HiveField(4) final int? difficultyCount,
      @HiveField(5) final String? recipeType,
      @HiveField(6) final int? recipeTypeCount,
      @HiveField(7) final int? timeRangeStart,
      @HiveField(8) final int? timeRangeEnd,
      @HiveField(9) final int? timeBasedCount,
      @HiveField(10) final int? wishlistCount,
      @HiveField(11) final int? sameRecipeRetryCount}) = _$BadgeConditionImpl;

  factory _BadgeCondition.fromJson(Map<String, dynamic> json) =
      _$BadgeConditionImpl.fromJson;

  @override
  @HiveField(0)
  BadgeType get type;
  @override // 요리 횟수 관련
  @HiveField(1)
  int? get targetCookingCount;
  @override // 연속 요리 관련
  @HiveField(2)
  int? get consecutiveDays;
  @override // 난이도 관련
  @HiveField(3)
  String? get difficulty;
  @override
  @HiveField(4)
  int? get difficultyCount;
  @override // 음식 종류 관련
  @HiveField(5)
  String? get recipeType;
  @override
  @HiveField(6)
  int? get recipeTypeCount;
  @override // 시간대 관련
  @HiveField(7)
  int? get timeRangeStart;
  @override // 시작 시간 (24시간 기준)
  @HiveField(8)
  int? get timeRangeEnd;
  @override // 종료 시간 (24시간 기준)
  @HiveField(9)
  int? get timeBasedCount;
  @override // 특별 조건
  @HiveField(10)
  int? get wishlistCount;
  @override // 위시리스트 개수
  @HiveField(11)
  int? get sameRecipeRetryCount;
  @override
  @JsonKey(ignore: true)
  _$$BadgeConditionImplCopyWith<_$BadgeConditionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
