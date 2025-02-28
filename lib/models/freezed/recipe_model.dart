import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_model.freezed.dart';
part 'recipe_model.g.dart';

@freezed
class Recipe with _$Recipe {
  factory Recipe({
    required String id,
    required String link,
    required String title,
    required String sub_title,
    required String thumbnail,
    required String recipe_type,
    required String difficulty,
    required int ingredients_cnt,
    required List<Ingredient> ingredients,
    required List<String> recipe_method,
    required List<String> recipe_tags,
    @Default("20240204000000") String createdAt, // 기본값 설정
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
}

@freezed
class Ingredient with _$Ingredient {
  factory Ingredient({
    required String food,
    required String cnt,
  }) = _Ingredient;

  factory Ingredient.fromJson(Map<String, dynamic> json) => _$IngredientFromJson(json);
}