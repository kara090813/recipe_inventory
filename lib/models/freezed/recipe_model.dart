import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'recipe_model.freezed.dart';
part 'recipe_model.g.dart';

@freezed
@HiveType(typeId: 0)
class Recipe with _$Recipe {
  factory Recipe({
    @HiveField(0) required String id,
    @HiveField(1) required String link,
    @HiveField(2) required String title,
    @HiveField(3) required String sub_title,
    @HiveField(4) required String thumbnail,
    @HiveField(5) required String recipe_type,
    @HiveField(6) required String difficulty,
    @HiveField(7) required int ingredients_cnt,
    @HiveField(8) required List<Ingredient> ingredients,
    @HiveField(9) required List<String> recipe_method,
    @HiveField(10) required List<String> recipe_tags,
    @HiveField(11) @Default("20240204000000") String createdAt,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
}

@freezed
@HiveType(typeId: 1)
class Ingredient with _$Ingredient {
  factory Ingredient({
    @HiveField(0) required String food,
    @HiveField(1) required String cnt,
  }) = _Ingredient;

  factory Ingredient.fromJson(Map<String, dynamic> json) => _$IngredientFromJson(json);
}