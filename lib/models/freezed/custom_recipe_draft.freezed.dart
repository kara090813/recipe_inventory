// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'custom_recipe_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CustomRecipeDraft _$CustomRecipeDraftFromJson(Map<String, dynamic> json) {
  return _CustomRecipeDraft.fromJson(json);
}

/// @nodoc
mixin _$CustomRecipeDraft {
  @HiveField(0)
  String get title => throw _privateConstructorUsedError;
  @HiveField(1)
  String get subTitle => throw _privateConstructorUsedError;
  @HiveField(2)
  String get foodType => throw _privateConstructorUsedError;
  @HiveField(3)
  String get difficulty => throw _privateConstructorUsedError;
  @HiveField(4)
  List<Ingredient> get ingredients => throw _privateConstructorUsedError;
  @HiveField(5)
  List<String> get cookingSteps => throw _privateConstructorUsedError;
  @HiveField(6)
  String get thumbnailPath => throw _privateConstructorUsedError;
  @HiveField(7)
  List<String> get tags => throw _privateConstructorUsedError;
  @HiveField(8)
  String get youtubeUrl => throw _privateConstructorUsedError;
  @HiveField(9)
  String get lastSavedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CustomRecipeDraftCopyWith<CustomRecipeDraft> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomRecipeDraftCopyWith<$Res> {
  factory $CustomRecipeDraftCopyWith(
          CustomRecipeDraft value, $Res Function(CustomRecipeDraft) then) =
      _$CustomRecipeDraftCopyWithImpl<$Res, CustomRecipeDraft>;
  @useResult
  $Res call(
      {@HiveField(0) String title,
      @HiveField(1) String subTitle,
      @HiveField(2) String foodType,
      @HiveField(3) String difficulty,
      @HiveField(4) List<Ingredient> ingredients,
      @HiveField(5) List<String> cookingSteps,
      @HiveField(6) String thumbnailPath,
      @HiveField(7) List<String> tags,
      @HiveField(8) String youtubeUrl,
      @HiveField(9) String lastSavedAt});
}

/// @nodoc
class _$CustomRecipeDraftCopyWithImpl<$Res, $Val extends CustomRecipeDraft>
    implements $CustomRecipeDraftCopyWith<$Res> {
  _$CustomRecipeDraftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? subTitle = null,
    Object? foodType = null,
    Object? difficulty = null,
    Object? ingredients = null,
    Object? cookingSteps = null,
    Object? thumbnailPath = null,
    Object? tags = null,
    Object? youtubeUrl = null,
    Object? lastSavedAt = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subTitle: null == subTitle
          ? _value.subTitle
          : subTitle // ignore: cast_nullable_to_non_nullable
              as String,
      foodType: null == foodType
          ? _value.foodType
          : foodType // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      ingredients: null == ingredients
          ? _value.ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as List<Ingredient>,
      cookingSteps: null == cookingSteps
          ? _value.cookingSteps
          : cookingSteps // ignore: cast_nullable_to_non_nullable
              as List<String>,
      thumbnailPath: null == thumbnailPath
          ? _value.thumbnailPath
          : thumbnailPath // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      youtubeUrl: null == youtubeUrl
          ? _value.youtubeUrl
          : youtubeUrl // ignore: cast_nullable_to_non_nullable
              as String,
      lastSavedAt: null == lastSavedAt
          ? _value.lastSavedAt
          : lastSavedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CustomRecipeDraftImplCopyWith<$Res>
    implements $CustomRecipeDraftCopyWith<$Res> {
  factory _$$CustomRecipeDraftImplCopyWith(_$CustomRecipeDraftImpl value,
          $Res Function(_$CustomRecipeDraftImpl) then) =
      __$$CustomRecipeDraftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String title,
      @HiveField(1) String subTitle,
      @HiveField(2) String foodType,
      @HiveField(3) String difficulty,
      @HiveField(4) List<Ingredient> ingredients,
      @HiveField(5) List<String> cookingSteps,
      @HiveField(6) String thumbnailPath,
      @HiveField(7) List<String> tags,
      @HiveField(8) String youtubeUrl,
      @HiveField(9) String lastSavedAt});
}

/// @nodoc
class __$$CustomRecipeDraftImplCopyWithImpl<$Res>
    extends _$CustomRecipeDraftCopyWithImpl<$Res, _$CustomRecipeDraftImpl>
    implements _$$CustomRecipeDraftImplCopyWith<$Res> {
  __$$CustomRecipeDraftImplCopyWithImpl(_$CustomRecipeDraftImpl _value,
      $Res Function(_$CustomRecipeDraftImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? subTitle = null,
    Object? foodType = null,
    Object? difficulty = null,
    Object? ingredients = null,
    Object? cookingSteps = null,
    Object? thumbnailPath = null,
    Object? tags = null,
    Object? youtubeUrl = null,
    Object? lastSavedAt = null,
  }) {
    return _then(_$CustomRecipeDraftImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subTitle: null == subTitle
          ? _value.subTitle
          : subTitle // ignore: cast_nullable_to_non_nullable
              as String,
      foodType: null == foodType
          ? _value.foodType
          : foodType // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      ingredients: null == ingredients
          ? _value._ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as List<Ingredient>,
      cookingSteps: null == cookingSteps
          ? _value._cookingSteps
          : cookingSteps // ignore: cast_nullable_to_non_nullable
              as List<String>,
      thumbnailPath: null == thumbnailPath
          ? _value.thumbnailPath
          : thumbnailPath // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      youtubeUrl: null == youtubeUrl
          ? _value.youtubeUrl
          : youtubeUrl // ignore: cast_nullable_to_non_nullable
              as String,
      lastSavedAt: null == lastSavedAt
          ? _value.lastSavedAt
          : lastSavedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomRecipeDraftImpl implements _CustomRecipeDraft {
  _$CustomRecipeDraftImpl(
      {@HiveField(0) this.title = "",
      @HiveField(1) this.subTitle = "",
      @HiveField(2) this.foodType = "한식",
      @HiveField(3) this.difficulty = "매우 쉬움",
      @HiveField(4) final List<Ingredient> ingredients = const [],
      @HiveField(5) final List<String> cookingSteps = const [],
      @HiveField(6) this.thumbnailPath = "",
      @HiveField(7) final List<String> tags = const [],
      @HiveField(8) this.youtubeUrl = "",
      @HiveField(9) this.lastSavedAt = ""})
      : _ingredients = ingredients,
        _cookingSteps = cookingSteps,
        _tags = tags;

  factory _$CustomRecipeDraftImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomRecipeDraftImplFromJson(json);

  @override
  @JsonKey()
  @HiveField(0)
  final String title;
  @override
  @JsonKey()
  @HiveField(1)
  final String subTitle;
  @override
  @JsonKey()
  @HiveField(2)
  final String foodType;
  @override
  @JsonKey()
  @HiveField(3)
  final String difficulty;
  final List<Ingredient> _ingredients;
  @override
  @JsonKey()
  @HiveField(4)
  List<Ingredient> get ingredients {
    if (_ingredients is EqualUnmodifiableListView) return _ingredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ingredients);
  }

  final List<String> _cookingSteps;
  @override
  @JsonKey()
  @HiveField(5)
  List<String> get cookingSteps {
    if (_cookingSteps is EqualUnmodifiableListView) return _cookingSteps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cookingSteps);
  }

  @override
  @JsonKey()
  @HiveField(6)
  final String thumbnailPath;
  final List<String> _tags;
  @override
  @JsonKey()
  @HiveField(7)
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  @HiveField(8)
  final String youtubeUrl;
  @override
  @JsonKey()
  @HiveField(9)
  final String lastSavedAt;

  @override
  String toString() {
    return 'CustomRecipeDraft(title: $title, subTitle: $subTitle, foodType: $foodType, difficulty: $difficulty, ingredients: $ingredients, cookingSteps: $cookingSteps, thumbnailPath: $thumbnailPath, tags: $tags, youtubeUrl: $youtubeUrl, lastSavedAt: $lastSavedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomRecipeDraftImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subTitle, subTitle) ||
                other.subTitle == subTitle) &&
            (identical(other.foodType, foodType) ||
                other.foodType == foodType) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            const DeepCollectionEquality()
                .equals(other._ingredients, _ingredients) &&
            const DeepCollectionEquality()
                .equals(other._cookingSteps, _cookingSteps) &&
            (identical(other.thumbnailPath, thumbnailPath) ||
                other.thumbnailPath == thumbnailPath) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.youtubeUrl, youtubeUrl) ||
                other.youtubeUrl == youtubeUrl) &&
            (identical(other.lastSavedAt, lastSavedAt) ||
                other.lastSavedAt == lastSavedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      title,
      subTitle,
      foodType,
      difficulty,
      const DeepCollectionEquality().hash(_ingredients),
      const DeepCollectionEquality().hash(_cookingSteps),
      thumbnailPath,
      const DeepCollectionEquality().hash(_tags),
      youtubeUrl,
      lastSavedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomRecipeDraftImplCopyWith<_$CustomRecipeDraftImpl> get copyWith =>
      __$$CustomRecipeDraftImplCopyWithImpl<_$CustomRecipeDraftImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomRecipeDraftImplToJson(
      this,
    );
  }
}

abstract class _CustomRecipeDraft implements CustomRecipeDraft {
  factory _CustomRecipeDraft(
      {@HiveField(0) final String title,
      @HiveField(1) final String subTitle,
      @HiveField(2) final String foodType,
      @HiveField(3) final String difficulty,
      @HiveField(4) final List<Ingredient> ingredients,
      @HiveField(5) final List<String> cookingSteps,
      @HiveField(6) final String thumbnailPath,
      @HiveField(7) final List<String> tags,
      @HiveField(8) final String youtubeUrl,
      @HiveField(9) final String lastSavedAt}) = _$CustomRecipeDraftImpl;

  factory _CustomRecipeDraft.fromJson(Map<String, dynamic> json) =
      _$CustomRecipeDraftImpl.fromJson;

  @override
  @HiveField(0)
  String get title;
  @override
  @HiveField(1)
  String get subTitle;
  @override
  @HiveField(2)
  String get foodType;
  @override
  @HiveField(3)
  String get difficulty;
  @override
  @HiveField(4)
  List<Ingredient> get ingredients;
  @override
  @HiveField(5)
  List<String> get cookingSteps;
  @override
  @HiveField(6)
  String get thumbnailPath;
  @override
  @HiveField(7)
  List<String> get tags;
  @override
  @HiveField(8)
  String get youtubeUrl;
  @override
  @HiveField(9)
  String get lastSavedAt;
  @override
  @JsonKey(ignore: true)
  _$$CustomRecipeDraftImplCopyWith<_$CustomRecipeDraftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
