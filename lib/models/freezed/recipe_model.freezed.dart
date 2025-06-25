// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Recipe _$RecipeFromJson(Map<String, dynamic> json) {
  return _Recipe.fromJson(json);
}

/// @nodoc
mixin _$Recipe {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get link => throw _privateConstructorUsedError;
  @HiveField(2)
  String get title => throw _privateConstructorUsedError;
  @HiveField(3)
  String get sub_title => throw _privateConstructorUsedError;
  @HiveField(4)
  String get thumbnail => throw _privateConstructorUsedError;
  @HiveField(5)
  String get recipe_type => throw _privateConstructorUsedError;
  @HiveField(6)
  String get difficulty => throw _privateConstructorUsedError;
  @HiveField(7)
  int get ingredients_cnt => throw _privateConstructorUsedError;
  @HiveField(8)
  List<Ingredient> get ingredients => throw _privateConstructorUsedError;
  @HiveField(9)
  List<String> get recipe_method => throw _privateConstructorUsedError;
  @HiveField(10)
  List<String> get recipe_tags => throw _privateConstructorUsedError;
  @HiveField(11)
  String get createdAt => throw _privateConstructorUsedError;
  @HiveField(12)
  bool get isCustom => throw _privateConstructorUsedError;
  @HiveField(13)
  String get youtubeUrl => throw _privateConstructorUsedError;
  @HiveField(14)
  String get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RecipeCopyWith<Recipe> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeCopyWith<$Res> {
  factory $RecipeCopyWith(Recipe value, $Res Function(Recipe) then) =
      _$RecipeCopyWithImpl<$Res, Recipe>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String link,
      @HiveField(2) String title,
      @HiveField(3) String sub_title,
      @HiveField(4) String thumbnail,
      @HiveField(5) String recipe_type,
      @HiveField(6) String difficulty,
      @HiveField(7) int ingredients_cnt,
      @HiveField(8) List<Ingredient> ingredients,
      @HiveField(9) List<String> recipe_method,
      @HiveField(10) List<String> recipe_tags,
      @HiveField(11) String createdAt,
      @HiveField(12) bool isCustom,
      @HiveField(13) String youtubeUrl,
      @HiveField(14) String updatedAt});
}

/// @nodoc
class _$RecipeCopyWithImpl<$Res, $Val extends Recipe>
    implements $RecipeCopyWith<$Res> {
  _$RecipeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? link = null,
    Object? title = null,
    Object? sub_title = null,
    Object? thumbnail = null,
    Object? recipe_type = null,
    Object? difficulty = null,
    Object? ingredients_cnt = null,
    Object? ingredients = null,
    Object? recipe_method = null,
    Object? recipe_tags = null,
    Object? createdAt = null,
    Object? isCustom = null,
    Object? youtubeUrl = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      sub_title: null == sub_title
          ? _value.sub_title
          : sub_title // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnail: null == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String,
      recipe_type: null == recipe_type
          ? _value.recipe_type
          : recipe_type // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      ingredients_cnt: null == ingredients_cnt
          ? _value.ingredients_cnt
          : ingredients_cnt // ignore: cast_nullable_to_non_nullable
              as int,
      ingredients: null == ingredients
          ? _value.ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as List<Ingredient>,
      recipe_method: null == recipe_method
          ? _value.recipe_method
          : recipe_method // ignore: cast_nullable_to_non_nullable
              as List<String>,
      recipe_tags: null == recipe_tags
          ? _value.recipe_tags
          : recipe_tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      isCustom: null == isCustom
          ? _value.isCustom
          : isCustom // ignore: cast_nullable_to_non_nullable
              as bool,
      youtubeUrl: null == youtubeUrl
          ? _value.youtubeUrl
          : youtubeUrl // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecipeImplCopyWith<$Res> implements $RecipeCopyWith<$Res> {
  factory _$$RecipeImplCopyWith(
          _$RecipeImpl value, $Res Function(_$RecipeImpl) then) =
      __$$RecipeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String link,
      @HiveField(2) String title,
      @HiveField(3) String sub_title,
      @HiveField(4) String thumbnail,
      @HiveField(5) String recipe_type,
      @HiveField(6) String difficulty,
      @HiveField(7) int ingredients_cnt,
      @HiveField(8) List<Ingredient> ingredients,
      @HiveField(9) List<String> recipe_method,
      @HiveField(10) List<String> recipe_tags,
      @HiveField(11) String createdAt,
      @HiveField(12) bool isCustom,
      @HiveField(13) String youtubeUrl,
      @HiveField(14) String updatedAt});
}

/// @nodoc
class __$$RecipeImplCopyWithImpl<$Res>
    extends _$RecipeCopyWithImpl<$Res, _$RecipeImpl>
    implements _$$RecipeImplCopyWith<$Res> {
  __$$RecipeImplCopyWithImpl(
      _$RecipeImpl _value, $Res Function(_$RecipeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? link = null,
    Object? title = null,
    Object? sub_title = null,
    Object? thumbnail = null,
    Object? recipe_type = null,
    Object? difficulty = null,
    Object? ingredients_cnt = null,
    Object? ingredients = null,
    Object? recipe_method = null,
    Object? recipe_tags = null,
    Object? createdAt = null,
    Object? isCustom = null,
    Object? youtubeUrl = null,
    Object? updatedAt = null,
  }) {
    return _then(_$RecipeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      sub_title: null == sub_title
          ? _value.sub_title
          : sub_title // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnail: null == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String,
      recipe_type: null == recipe_type
          ? _value.recipe_type
          : recipe_type // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      ingredients_cnt: null == ingredients_cnt
          ? _value.ingredients_cnt
          : ingredients_cnt // ignore: cast_nullable_to_non_nullable
              as int,
      ingredients: null == ingredients
          ? _value._ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as List<Ingredient>,
      recipe_method: null == recipe_method
          ? _value._recipe_method
          : recipe_method // ignore: cast_nullable_to_non_nullable
              as List<String>,
      recipe_tags: null == recipe_tags
          ? _value._recipe_tags
          : recipe_tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      isCustom: null == isCustom
          ? _value.isCustom
          : isCustom // ignore: cast_nullable_to_non_nullable
              as bool,
      youtubeUrl: null == youtubeUrl
          ? _value.youtubeUrl
          : youtubeUrl // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecipeImpl implements _Recipe {
  _$RecipeImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.link,
      @HiveField(2) required this.title,
      @HiveField(3) required this.sub_title,
      @HiveField(4) required this.thumbnail,
      @HiveField(5) required this.recipe_type,
      @HiveField(6) required this.difficulty,
      @HiveField(7) required this.ingredients_cnt,
      @HiveField(8) required final List<Ingredient> ingredients,
      @HiveField(9) required final List<String> recipe_method,
      @HiveField(10) required final List<String> recipe_tags,
      @HiveField(11) this.createdAt = "20240204000000",
      @HiveField(12) this.isCustom = false,
      @HiveField(13) this.youtubeUrl = "",
      @HiveField(14) this.updatedAt = ""})
      : _ingredients = ingredients,
        _recipe_method = recipe_method,
        _recipe_tags = recipe_tags;

  factory _$RecipeImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecipeImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String link;
  @override
  @HiveField(2)
  final String title;
  @override
  @HiveField(3)
  final String sub_title;
  @override
  @HiveField(4)
  final String thumbnail;
  @override
  @HiveField(5)
  final String recipe_type;
  @override
  @HiveField(6)
  final String difficulty;
  @override
  @HiveField(7)
  final int ingredients_cnt;
  final List<Ingredient> _ingredients;
  @override
  @HiveField(8)
  List<Ingredient> get ingredients {
    if (_ingredients is EqualUnmodifiableListView) return _ingredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ingredients);
  }

  final List<String> _recipe_method;
  @override
  @HiveField(9)
  List<String> get recipe_method {
    if (_recipe_method is EqualUnmodifiableListView) return _recipe_method;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recipe_method);
  }

  final List<String> _recipe_tags;
  @override
  @HiveField(10)
  List<String> get recipe_tags {
    if (_recipe_tags is EqualUnmodifiableListView) return _recipe_tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recipe_tags);
  }

  @override
  @JsonKey()
  @HiveField(11)
  final String createdAt;
  @override
  @JsonKey()
  @HiveField(12)
  final bool isCustom;
  @override
  @JsonKey()
  @HiveField(13)
  final String youtubeUrl;
  @override
  @JsonKey()
  @HiveField(14)
  final String updatedAt;

  @override
  String toString() {
    return 'Recipe(id: $id, link: $link, title: $title, sub_title: $sub_title, thumbnail: $thumbnail, recipe_type: $recipe_type, difficulty: $difficulty, ingredients_cnt: $ingredients_cnt, ingredients: $ingredients, recipe_method: $recipe_method, recipe_tags: $recipe_tags, createdAt: $createdAt, isCustom: $isCustom, youtubeUrl: $youtubeUrl, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.link, link) || other.link == link) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.sub_title, sub_title) ||
                other.sub_title == sub_title) &&
            (identical(other.thumbnail, thumbnail) ||
                other.thumbnail == thumbnail) &&
            (identical(other.recipe_type, recipe_type) ||
                other.recipe_type == recipe_type) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.ingredients_cnt, ingredients_cnt) ||
                other.ingredients_cnt == ingredients_cnt) &&
            const DeepCollectionEquality()
                .equals(other._ingredients, _ingredients) &&
            const DeepCollectionEquality()
                .equals(other._recipe_method, _recipe_method) &&
            const DeepCollectionEquality()
                .equals(other._recipe_tags, _recipe_tags) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isCustom, isCustom) ||
                other.isCustom == isCustom) &&
            (identical(other.youtubeUrl, youtubeUrl) ||
                other.youtubeUrl == youtubeUrl) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      link,
      title,
      sub_title,
      thumbnail,
      recipe_type,
      difficulty,
      ingredients_cnt,
      const DeepCollectionEquality().hash(_ingredients),
      const DeepCollectionEquality().hash(_recipe_method),
      const DeepCollectionEquality().hash(_recipe_tags),
      createdAt,
      isCustom,
      youtubeUrl,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeImplCopyWith<_$RecipeImpl> get copyWith =>
      __$$RecipeImplCopyWithImpl<_$RecipeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecipeImplToJson(
      this,
    );
  }
}

abstract class _Recipe implements Recipe {
  factory _Recipe(
      {@HiveField(0) required final String id,
      @HiveField(1) required final String link,
      @HiveField(2) required final String title,
      @HiveField(3) required final String sub_title,
      @HiveField(4) required final String thumbnail,
      @HiveField(5) required final String recipe_type,
      @HiveField(6) required final String difficulty,
      @HiveField(7) required final int ingredients_cnt,
      @HiveField(8) required final List<Ingredient> ingredients,
      @HiveField(9) required final List<String> recipe_method,
      @HiveField(10) required final List<String> recipe_tags,
      @HiveField(11) final String createdAt,
      @HiveField(12) final bool isCustom,
      @HiveField(13) final String youtubeUrl,
      @HiveField(14) final String updatedAt}) = _$RecipeImpl;

  factory _Recipe.fromJson(Map<String, dynamic> json) = _$RecipeImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get link;
  @override
  @HiveField(2)
  String get title;
  @override
  @HiveField(3)
  String get sub_title;
  @override
  @HiveField(4)
  String get thumbnail;
  @override
  @HiveField(5)
  String get recipe_type;
  @override
  @HiveField(6)
  String get difficulty;
  @override
  @HiveField(7)
  int get ingredients_cnt;
  @override
  @HiveField(8)
  List<Ingredient> get ingredients;
  @override
  @HiveField(9)
  List<String> get recipe_method;
  @override
  @HiveField(10)
  List<String> get recipe_tags;
  @override
  @HiveField(11)
  String get createdAt;
  @override
  @HiveField(12)
  bool get isCustom;
  @override
  @HiveField(13)
  String get youtubeUrl;
  @override
  @HiveField(14)
  String get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$RecipeImplCopyWith<_$RecipeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Ingredient _$IngredientFromJson(Map<String, dynamic> json) {
  return _Ingredient.fromJson(json);
}

/// @nodoc
mixin _$Ingredient {
  @HiveField(0)
  String get food => throw _privateConstructorUsedError;
  @HiveField(1)
  String get cnt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IngredientCopyWith<Ingredient> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IngredientCopyWith<$Res> {
  factory $IngredientCopyWith(
          Ingredient value, $Res Function(Ingredient) then) =
      _$IngredientCopyWithImpl<$Res, Ingredient>;
  @useResult
  $Res call({@HiveField(0) String food, @HiveField(1) String cnt});
}

/// @nodoc
class _$IngredientCopyWithImpl<$Res, $Val extends Ingredient>
    implements $IngredientCopyWith<$Res> {
  _$IngredientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? food = null,
    Object? cnt = null,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IngredientImplCopyWith<$Res>
    implements $IngredientCopyWith<$Res> {
  factory _$$IngredientImplCopyWith(
          _$IngredientImpl value, $Res Function(_$IngredientImpl) then) =
      __$$IngredientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@HiveField(0) String food, @HiveField(1) String cnt});
}

/// @nodoc
class __$$IngredientImplCopyWithImpl<$Res>
    extends _$IngredientCopyWithImpl<$Res, _$IngredientImpl>
    implements _$$IngredientImplCopyWith<$Res> {
  __$$IngredientImplCopyWithImpl(
      _$IngredientImpl _value, $Res Function(_$IngredientImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? food = null,
    Object? cnt = null,
  }) {
    return _then(_$IngredientImpl(
      food: null == food
          ? _value.food
          : food // ignore: cast_nullable_to_non_nullable
              as String,
      cnt: null == cnt
          ? _value.cnt
          : cnt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IngredientImpl implements _Ingredient {
  _$IngredientImpl(
      {@HiveField(0) required this.food, @HiveField(1) required this.cnt});

  factory _$IngredientImpl.fromJson(Map<String, dynamic> json) =>
      _$$IngredientImplFromJson(json);

  @override
  @HiveField(0)
  final String food;
  @override
  @HiveField(1)
  final String cnt;

  @override
  String toString() {
    return 'Ingredient(food: $food, cnt: $cnt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IngredientImpl &&
            (identical(other.food, food) || other.food == food) &&
            (identical(other.cnt, cnt) || other.cnt == cnt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, food, cnt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IngredientImplCopyWith<_$IngredientImpl> get copyWith =>
      __$$IngredientImplCopyWithImpl<_$IngredientImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IngredientImplToJson(
      this,
    );
  }
}

abstract class _Ingredient implements Ingredient {
  factory _Ingredient(
      {@HiveField(0) required final String food,
      @HiveField(1) required final String cnt}) = _$IngredientImpl;

  factory _Ingredient.fromJson(Map<String, dynamic> json) =
      _$IngredientImpl.fromJson;

  @override
  @HiveField(0)
  String get food;
  @override
  @HiveField(1)
  String get cnt;
  @override
  @JsonKey(ignore: true)
  _$$IngredientImplCopyWith<_$IngredientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
