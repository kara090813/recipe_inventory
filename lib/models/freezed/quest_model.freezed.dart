// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quest_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Quest _$QuestFromJson(Map<String, dynamic> json) {
  return _Quest.fromJson(json);
}

/// @nodoc
mixin _$Quest {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get title => throw _privateConstructorUsedError;
  @HiveField(2)
  String get description => throw _privateConstructorUsedError;
  @HiveField(3)
  QuestType get type => throw _privateConstructorUsedError;
  @HiveField(4)
  QuestCondition get condition => throw _privateConstructorUsedError;
  @HiveField(5)
  int get targetCount => throw _privateConstructorUsedError;
  @HiveField(6)
  int get rewardPoints => throw _privateConstructorUsedError;
  @HiveField(7)
  int get rewardExperience => throw _privateConstructorUsedError;
  @HiveField(8)
  String get monthKey => throw _privateConstructorUsedError;
  @HiveField(9)
  int get currentProgress => throw _privateConstructorUsedError;
  @HiveField(10)
  bool get isCompleted => throw _privateConstructorUsedError;
  @HiveField(11)
  bool get isRewardReceived => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuestCopyWith<Quest> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestCopyWith<$Res> {
  factory $QuestCopyWith(Quest value, $Res Function(Quest) then) =
      _$QuestCopyWithImpl<$Res, Quest>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String title,
      @HiveField(2) String description,
      @HiveField(3) QuestType type,
      @HiveField(4) QuestCondition condition,
      @HiveField(5) int targetCount,
      @HiveField(6) int rewardPoints,
      @HiveField(7) int rewardExperience,
      @HiveField(8) String monthKey,
      @HiveField(9) int currentProgress,
      @HiveField(10) bool isCompleted,
      @HiveField(11) bool isRewardReceived});

  $QuestConditionCopyWith<$Res> get condition;
}

/// @nodoc
class _$QuestCopyWithImpl<$Res, $Val extends Quest>
    implements $QuestCopyWith<$Res> {
  _$QuestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? condition = null,
    Object? targetCount = null,
    Object? rewardPoints = null,
    Object? rewardExperience = null,
    Object? monthKey = null,
    Object? currentProgress = null,
    Object? isCompleted = null,
    Object? isRewardReceived = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as QuestType,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as QuestCondition,
      targetCount: null == targetCount
          ? _value.targetCount
          : targetCount // ignore: cast_nullable_to_non_nullable
              as int,
      rewardPoints: null == rewardPoints
          ? _value.rewardPoints
          : rewardPoints // ignore: cast_nullable_to_non_nullable
              as int,
      rewardExperience: null == rewardExperience
          ? _value.rewardExperience
          : rewardExperience // ignore: cast_nullable_to_non_nullable
              as int,
      monthKey: null == monthKey
          ? _value.monthKey
          : monthKey // ignore: cast_nullable_to_non_nullable
              as String,
      currentProgress: null == currentProgress
          ? _value.currentProgress
          : currentProgress // ignore: cast_nullable_to_non_nullable
              as int,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      isRewardReceived: null == isRewardReceived
          ? _value.isRewardReceived
          : isRewardReceived // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $QuestConditionCopyWith<$Res> get condition {
    return $QuestConditionCopyWith<$Res>(_value.condition, (value) {
      return _then(_value.copyWith(condition: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$QuestImplCopyWith<$Res> implements $QuestCopyWith<$Res> {
  factory _$$QuestImplCopyWith(
          _$QuestImpl value, $Res Function(_$QuestImpl) then) =
      __$$QuestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String title,
      @HiveField(2) String description,
      @HiveField(3) QuestType type,
      @HiveField(4) QuestCondition condition,
      @HiveField(5) int targetCount,
      @HiveField(6) int rewardPoints,
      @HiveField(7) int rewardExperience,
      @HiveField(8) String monthKey,
      @HiveField(9) int currentProgress,
      @HiveField(10) bool isCompleted,
      @HiveField(11) bool isRewardReceived});

  @override
  $QuestConditionCopyWith<$Res> get condition;
}

/// @nodoc
class __$$QuestImplCopyWithImpl<$Res>
    extends _$QuestCopyWithImpl<$Res, _$QuestImpl>
    implements _$$QuestImplCopyWith<$Res> {
  __$$QuestImplCopyWithImpl(
      _$QuestImpl _value, $Res Function(_$QuestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? condition = null,
    Object? targetCount = null,
    Object? rewardPoints = null,
    Object? rewardExperience = null,
    Object? monthKey = null,
    Object? currentProgress = null,
    Object? isCompleted = null,
    Object? isRewardReceived = null,
  }) {
    return _then(_$QuestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as QuestType,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as QuestCondition,
      targetCount: null == targetCount
          ? _value.targetCount
          : targetCount // ignore: cast_nullable_to_non_nullable
              as int,
      rewardPoints: null == rewardPoints
          ? _value.rewardPoints
          : rewardPoints // ignore: cast_nullable_to_non_nullable
              as int,
      rewardExperience: null == rewardExperience
          ? _value.rewardExperience
          : rewardExperience // ignore: cast_nullable_to_non_nullable
              as int,
      monthKey: null == monthKey
          ? _value.monthKey
          : monthKey // ignore: cast_nullable_to_non_nullable
              as String,
      currentProgress: null == currentProgress
          ? _value.currentProgress
          : currentProgress // ignore: cast_nullable_to_non_nullable
              as int,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      isRewardReceived: null == isRewardReceived
          ? _value.isRewardReceived
          : isRewardReceived // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuestImpl implements _Quest {
  _$QuestImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.title,
      @HiveField(2) required this.description,
      @HiveField(3) required this.type,
      @HiveField(4) required this.condition,
      @HiveField(5) required this.targetCount,
      @HiveField(6) required this.rewardPoints,
      @HiveField(7) required this.rewardExperience,
      @HiveField(8) required this.monthKey,
      @HiveField(9) this.currentProgress = 0,
      @HiveField(10) this.isCompleted = false,
      @HiveField(11) this.isRewardReceived = false});

  factory _$QuestImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuestImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String title;
  @override
  @HiveField(2)
  final String description;
  @override
  @HiveField(3)
  final QuestType type;
  @override
  @HiveField(4)
  final QuestCondition condition;
  @override
  @HiveField(5)
  final int targetCount;
  @override
  @HiveField(6)
  final int rewardPoints;
  @override
  @HiveField(7)
  final int rewardExperience;
  @override
  @HiveField(8)
  final String monthKey;
  @override
  @JsonKey()
  @HiveField(9)
  final int currentProgress;
  @override
  @JsonKey()
  @HiveField(10)
  final bool isCompleted;
  @override
  @JsonKey()
  @HiveField(11)
  final bool isRewardReceived;

  @override
  String toString() {
    return 'Quest(id: $id, title: $title, description: $description, type: $type, condition: $condition, targetCount: $targetCount, rewardPoints: $rewardPoints, rewardExperience: $rewardExperience, monthKey: $monthKey, currentProgress: $currentProgress, isCompleted: $isCompleted, isRewardReceived: $isRewardReceived)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.targetCount, targetCount) ||
                other.targetCount == targetCount) &&
            (identical(other.rewardPoints, rewardPoints) ||
                other.rewardPoints == rewardPoints) &&
            (identical(other.rewardExperience, rewardExperience) ||
                other.rewardExperience == rewardExperience) &&
            (identical(other.monthKey, monthKey) ||
                other.monthKey == monthKey) &&
            (identical(other.currentProgress, currentProgress) ||
                other.currentProgress == currentProgress) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.isRewardReceived, isRewardReceived) ||
                other.isRewardReceived == isRewardReceived));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      type,
      condition,
      targetCount,
      rewardPoints,
      rewardExperience,
      monthKey,
      currentProgress,
      isCompleted,
      isRewardReceived);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestImplCopyWith<_$QuestImpl> get copyWith =>
      __$$QuestImplCopyWithImpl<_$QuestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestImplToJson(
      this,
    );
  }
}

abstract class _Quest implements Quest {
  factory _Quest(
      {@HiveField(0) required final String id,
      @HiveField(1) required final String title,
      @HiveField(2) required final String description,
      @HiveField(3) required final QuestType type,
      @HiveField(4) required final QuestCondition condition,
      @HiveField(5) required final int targetCount,
      @HiveField(6) required final int rewardPoints,
      @HiveField(7) required final int rewardExperience,
      @HiveField(8) required final String monthKey,
      @HiveField(9) final int currentProgress,
      @HiveField(10) final bool isCompleted,
      @HiveField(11) final bool isRewardReceived}) = _$QuestImpl;

  factory _Quest.fromJson(Map<String, dynamic> json) = _$QuestImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get title;
  @override
  @HiveField(2)
  String get description;
  @override
  @HiveField(3)
  QuestType get type;
  @override
  @HiveField(4)
  QuestCondition get condition;
  @override
  @HiveField(5)
  int get targetCount;
  @override
  @HiveField(6)
  int get rewardPoints;
  @override
  @HiveField(7)
  int get rewardExperience;
  @override
  @HiveField(8)
  String get monthKey;
  @override
  @HiveField(9)
  int get currentProgress;
  @override
  @HiveField(10)
  bool get isCompleted;
  @override
  @HiveField(11)
  bool get isRewardReceived;
  @override
  @JsonKey(ignore: true)
  _$$QuestImplCopyWith<_$QuestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuestCondition _$QuestConditionFromJson(Map<String, dynamic> json) {
  return _QuestCondition.fromJson(json);
}

/// @nodoc
mixin _$QuestCondition {
  @HiveField(0)
  String? get recipeType => throw _privateConstructorUsedError;
  @HiveField(1)
  String? get difficulty => throw _privateConstructorUsedError;
  @HiveField(2)
  String? get ingredientName => throw _privateConstructorUsedError;
  @HiveField(3)
  List<String> get ingredientTypes => throw _privateConstructorUsedError;
  @HiveField(4)
  int? get minIngredientCount => throw _privateConstructorUsedError;
  @HiveField(5)
  int? get consecutiveDays => throw _privateConstructorUsedError;
  @HiveField(6)
  List<String> get recipeTags => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuestConditionCopyWith<QuestCondition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestConditionCopyWith<$Res> {
  factory $QuestConditionCopyWith(
          QuestCondition value, $Res Function(QuestCondition) then) =
      _$QuestConditionCopyWithImpl<$Res, QuestCondition>;
  @useResult
  $Res call(
      {@HiveField(0) String? recipeType,
      @HiveField(1) String? difficulty,
      @HiveField(2) String? ingredientName,
      @HiveField(3) List<String> ingredientTypes,
      @HiveField(4) int? minIngredientCount,
      @HiveField(5) int? consecutiveDays,
      @HiveField(6) List<String> recipeTags});
}

/// @nodoc
class _$QuestConditionCopyWithImpl<$Res, $Val extends QuestCondition>
    implements $QuestConditionCopyWith<$Res> {
  _$QuestConditionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipeType = freezed,
    Object? difficulty = freezed,
    Object? ingredientName = freezed,
    Object? ingredientTypes = null,
    Object? minIngredientCount = freezed,
    Object? consecutiveDays = freezed,
    Object? recipeTags = null,
  }) {
    return _then(_value.copyWith(
      recipeType: freezed == recipeType
          ? _value.recipeType
          : recipeType // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String?,
      ingredientName: freezed == ingredientName
          ? _value.ingredientName
          : ingredientName // ignore: cast_nullable_to_non_nullable
              as String?,
      ingredientTypes: null == ingredientTypes
          ? _value.ingredientTypes
          : ingredientTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      minIngredientCount: freezed == minIngredientCount
          ? _value.minIngredientCount
          : minIngredientCount // ignore: cast_nullable_to_non_nullable
              as int?,
      consecutiveDays: freezed == consecutiveDays
          ? _value.consecutiveDays
          : consecutiveDays // ignore: cast_nullable_to_non_nullable
              as int?,
      recipeTags: null == recipeTags
          ? _value.recipeTags
          : recipeTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuestConditionImplCopyWith<$Res>
    implements $QuestConditionCopyWith<$Res> {
  factory _$$QuestConditionImplCopyWith(_$QuestConditionImpl value,
          $Res Function(_$QuestConditionImpl) then) =
      __$$QuestConditionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String? recipeType,
      @HiveField(1) String? difficulty,
      @HiveField(2) String? ingredientName,
      @HiveField(3) List<String> ingredientTypes,
      @HiveField(4) int? minIngredientCount,
      @HiveField(5) int? consecutiveDays,
      @HiveField(6) List<String> recipeTags});
}

/// @nodoc
class __$$QuestConditionImplCopyWithImpl<$Res>
    extends _$QuestConditionCopyWithImpl<$Res, _$QuestConditionImpl>
    implements _$$QuestConditionImplCopyWith<$Res> {
  __$$QuestConditionImplCopyWithImpl(
      _$QuestConditionImpl _value, $Res Function(_$QuestConditionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipeType = freezed,
    Object? difficulty = freezed,
    Object? ingredientName = freezed,
    Object? ingredientTypes = null,
    Object? minIngredientCount = freezed,
    Object? consecutiveDays = freezed,
    Object? recipeTags = null,
  }) {
    return _then(_$QuestConditionImpl(
      recipeType: freezed == recipeType
          ? _value.recipeType
          : recipeType // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String?,
      ingredientName: freezed == ingredientName
          ? _value.ingredientName
          : ingredientName // ignore: cast_nullable_to_non_nullable
              as String?,
      ingredientTypes: null == ingredientTypes
          ? _value._ingredientTypes
          : ingredientTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      minIngredientCount: freezed == minIngredientCount
          ? _value.minIngredientCount
          : minIngredientCount // ignore: cast_nullable_to_non_nullable
              as int?,
      consecutiveDays: freezed == consecutiveDays
          ? _value.consecutiveDays
          : consecutiveDays // ignore: cast_nullable_to_non_nullable
              as int?,
      recipeTags: null == recipeTags
          ? _value._recipeTags
          : recipeTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuestConditionImpl implements _QuestCondition {
  _$QuestConditionImpl(
      {@HiveField(0) this.recipeType,
      @HiveField(1) this.difficulty,
      @HiveField(2) this.ingredientName,
      @HiveField(3) final List<String> ingredientTypes = const [],
      @HiveField(4) this.minIngredientCount,
      @HiveField(5) this.consecutiveDays,
      @HiveField(6) final List<String> recipeTags = const []})
      : _ingredientTypes = ingredientTypes,
        _recipeTags = recipeTags;

  factory _$QuestConditionImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuestConditionImplFromJson(json);

  @override
  @HiveField(0)
  final String? recipeType;
  @override
  @HiveField(1)
  final String? difficulty;
  @override
  @HiveField(2)
  final String? ingredientName;
  final List<String> _ingredientTypes;
  @override
  @JsonKey()
  @HiveField(3)
  List<String> get ingredientTypes {
    if (_ingredientTypes is EqualUnmodifiableListView) return _ingredientTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ingredientTypes);
  }

  @override
  @HiveField(4)
  final int? minIngredientCount;
  @override
  @HiveField(5)
  final int? consecutiveDays;
  final List<String> _recipeTags;
  @override
  @JsonKey()
  @HiveField(6)
  List<String> get recipeTags {
    if (_recipeTags is EqualUnmodifiableListView) return _recipeTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recipeTags);
  }

  @override
  String toString() {
    return 'QuestCondition(recipeType: $recipeType, difficulty: $difficulty, ingredientName: $ingredientName, ingredientTypes: $ingredientTypes, minIngredientCount: $minIngredientCount, consecutiveDays: $consecutiveDays, recipeTags: $recipeTags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestConditionImpl &&
            (identical(other.recipeType, recipeType) ||
                other.recipeType == recipeType) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.ingredientName, ingredientName) ||
                other.ingredientName == ingredientName) &&
            const DeepCollectionEquality()
                .equals(other._ingredientTypes, _ingredientTypes) &&
            (identical(other.minIngredientCount, minIngredientCount) ||
                other.minIngredientCount == minIngredientCount) &&
            (identical(other.consecutiveDays, consecutiveDays) ||
                other.consecutiveDays == consecutiveDays) &&
            const DeepCollectionEquality()
                .equals(other._recipeTags, _recipeTags));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      recipeType,
      difficulty,
      ingredientName,
      const DeepCollectionEquality().hash(_ingredientTypes),
      minIngredientCount,
      consecutiveDays,
      const DeepCollectionEquality().hash(_recipeTags));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestConditionImplCopyWith<_$QuestConditionImpl> get copyWith =>
      __$$QuestConditionImplCopyWithImpl<_$QuestConditionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestConditionImplToJson(
      this,
    );
  }
}

abstract class _QuestCondition implements QuestCondition {
  factory _QuestCondition(
      {@HiveField(0) final String? recipeType,
      @HiveField(1) final String? difficulty,
      @HiveField(2) final String? ingredientName,
      @HiveField(3) final List<String> ingredientTypes,
      @HiveField(4) final int? minIngredientCount,
      @HiveField(5) final int? consecutiveDays,
      @HiveField(6) final List<String> recipeTags}) = _$QuestConditionImpl;

  factory _QuestCondition.fromJson(Map<String, dynamic> json) =
      _$QuestConditionImpl.fromJson;

  @override
  @HiveField(0)
  String? get recipeType;
  @override
  @HiveField(1)
  String? get difficulty;
  @override
  @HiveField(2)
  String? get ingredientName;
  @override
  @HiveField(3)
  List<String> get ingredientTypes;
  @override
  @HiveField(4)
  int? get minIngredientCount;
  @override
  @HiveField(5)
  int? get consecutiveDays;
  @override
  @HiveField(6)
  List<String> get recipeTags;
  @override
  @JsonKey(ignore: true)
  _$$QuestConditionImplCopyWith<_$QuestConditionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
