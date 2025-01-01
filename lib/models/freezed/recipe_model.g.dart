// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecipeImpl _$$RecipeImplFromJson(Map<String, dynamic> json) => _$RecipeImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      sub_title: json['sub_title'] as String,
      thumbnail: json['thumbnail'] as String,
      recipe_type: json['recipe_type'] as String,
      difficulty: json['difficulty'] as String,
      ingredients_cnt: (json['ingredients_cnt'] as num).toInt(),
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      recipe_method: (json['recipe_method'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recipe_tags: (json['recipe_tags'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$RecipeImplToJson(_$RecipeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'sub_title': instance.sub_title,
      'thumbnail': instance.thumbnail,
      'recipe_type': instance.recipe_type,
      'difficulty': instance.difficulty,
      'ingredients_cnt': instance.ingredients_cnt,
      'ingredients': instance.ingredients,
      'recipe_method': instance.recipe_method,
      'recipe_tags': instance.recipe_tags,
    };

_$IngredientImpl _$$IngredientImplFromJson(Map<String, dynamic> json) =>
    _$IngredientImpl(
      food: json['food'] as String,
      cnt: json['cnt'] as String,
    );

Map<String, dynamic> _$$IngredientImplToJson(_$IngredientImpl instance) =>
    <String, dynamic>{
      'food': instance.food,
      'cnt': instance.cnt,
    };
