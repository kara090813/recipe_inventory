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
  String get id => throw _privateConstructorUsedError;
  String get link => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get sub_title => throw _privateConstructorUsedError;
  String get thumbnail => throw _privateConstructorUsedError;
  String get recipe_type => throw _privateConstructorUsedError;
  String get difficulty => throw _privateConstructorUsedError;
  int get ingredients_cnt => throw _privateConstructorUsedError;
  List<Ingredient> get ingredients => throw _privateConstructorUsedError;
  List<String> get recipe_method => throw _privateConstructorUsedError;
  List<String> get recipe_tags => throw _privateConstructorUsedError;

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
      {String id,
      String link,
      String title,
      String sub_title,
      String thumbnail,
      String recipe_type,
      String difficulty,
      int ingredients_cnt,
      List<Ingredient> ingredients,
      List<String> recipe_method,
      List<String> recipe_tags});
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
      {String id,
      String link,
      String title,
      String sub_title,
      String thumbnail,
      String recipe_type,
      String difficulty,
      int ingredients_cnt,
      List<Ingredient> ingredients,
      List<String> recipe_method,
      List<String> recipe_tags});
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecipeImpl implements _Recipe {
  _$RecipeImpl(
      {required this.id,
      required this.link,
      required this.title,
      required this.sub_title,
      required this.thumbnail,
      required this.recipe_type,
      required this.difficulty,
      required this.ingredients_cnt,
      required final List<Ingredient> ingredients,
      required final List<String> recipe_method,
      required final List<String> recipe_tags})
      : _ingredients = ingredients,
        _recipe_method = recipe_method,
        _recipe_tags = recipe_tags;

  factory _$RecipeImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecipeImplFromJson(json);

  @override
  final String id;
  @override
  final String link;
  @override
  final String title;
  @override
  final String sub_title;
  @override
  final String thumbnail;
  @override
  final String recipe_type;
  @override
  final String difficulty;
  @override
  final int ingredients_cnt;
  final List<Ingredient> _ingredients;
  @override
  List<Ingredient> get ingredients {
    if (_ingredients is EqualUnmodifiableListView) return _ingredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ingredients);
  }

  final List<String> _recipe_method;
  @override
  List<String> get recipe_method {
    if (_recipe_method is EqualUnmodifiableListView) return _recipe_method;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recipe_method);
  }

  final List<String> _recipe_tags;
  @override
  List<String> get recipe_tags {
    if (_recipe_tags is EqualUnmodifiableListView) return _recipe_tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recipe_tags);
  }

  @override
  String toString() {
    return 'Recipe(id: $id, link: $link, title: $title, sub_title: $sub_title, thumbnail: $thumbnail, recipe_type: $recipe_type, difficulty: $difficulty, ingredients_cnt: $ingredients_cnt, ingredients: $ingredients, recipe_method: $recipe_method, recipe_tags: $recipe_tags)';
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
                .equals(other._recipe_tags, _recipe_tags));
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
      const DeepCollectionEquality().hash(_recipe_tags));

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
      {required final String id,
      required final String link,
      required final String title,
      required final String sub_title,
      required final String thumbnail,
      required final String recipe_type,
      required final String difficulty,
      required final int ingredients_cnt,
      required final List<Ingredient> ingredients,
      required final List<String> recipe_method,
      required final List<String> recipe_tags}) = _$RecipeImpl;

  factory _Recipe.fromJson(Map<String, dynamic> json) = _$RecipeImpl.fromJson;

  @override
  String get id;
  @override
  String get link;
  @override
  String get title;
  @override
  String get sub_title;
  @override
  String get thumbnail;
  @override
  String get recipe_type;
  @override
  String get difficulty;
  @override
  int get ingredients_cnt;
  @override
  List<Ingredient> get ingredients;
  @override
  List<String> get recipe_method;
  @override
  List<String> get recipe_tags;
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
  String get food => throw _privateConstructorUsedError;
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
  $Res call({String food, String cnt});
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
  $Res call({String food, String cnt});
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
  _$IngredientImpl({required this.food, required this.cnt});

  factory _$IngredientImpl.fromJson(Map<String, dynamic> json) =>
      _$$IngredientImplFromJson(json);

  @override
  final String food;
  @override
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
  factory _Ingredient({required final String food, required final String cnt}) =
      _$IngredientImpl;

  factory _Ingredient.fromJson(Map<String, dynamic> json) =
      _$IngredientImpl.fromJson;

  @override
  String get food;
  @override
  String get cnt;
  @override
  @JsonKey(ignore: true)
  _$$IngredientImplCopyWith<_$IngredientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
