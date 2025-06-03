// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final int typeId = 0;

  @override
  Recipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recipe(
      id: fields[0] as String,
      link: fields[1] as String,
      title: fields[2] as String,
      sub_title: fields[3] as String,
      thumbnail: fields[4] as String,
      recipe_type: fields[5] as String,
      difficulty: fields[6] as String,
      ingredients_cnt: fields[7] as int,
      ingredients: (fields[8] as List).cast<Ingredient>(),
      recipe_method: (fields[9] as List).cast<String>(),
      recipe_tags: (fields[10] as List).cast<String>(),
      createdAt: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.link)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.sub_title)
      ..writeByte(4)
      ..write(obj.thumbnail)
      ..writeByte(5)
      ..write(obj.recipe_type)
      ..writeByte(6)
      ..write(obj.difficulty)
      ..writeByte(7)
      ..write(obj.ingredients_cnt)
      ..writeByte(8)
      ..write(obj.ingredients)
      ..writeByte(9)
      ..write(obj.recipe_method)
      ..writeByte(10)
      ..write(obj.recipe_tags)
      ..writeByte(11)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IngredientAdapter extends TypeAdapter<Ingredient> {
  @override
  final int typeId = 1;

  @override
  Ingredient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ingredient(
      food: fields[0] as String,
      cnt: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Ingredient obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.food)
      ..writeByte(1)
      ..write(obj.cnt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngredientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecipeImpl _$$RecipeImplFromJson(Map<String, dynamic> json) => _$RecipeImpl(
      id: json['id'] as String,
      link: json['link'] as String,
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
      createdAt: json['createdAt'] as String? ?? "20240204000000",
    );

Map<String, dynamic> _$$RecipeImplToJson(_$RecipeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'link': instance.link,
      'title': instance.title,
      'sub_title': instance.sub_title,
      'thumbnail': instance.thumbnail,
      'recipe_type': instance.recipe_type,
      'difficulty': instance.difficulty,
      'ingredients_cnt': instance.ingredients_cnt,
      'ingredients': instance.ingredients,
      'recipe_method': instance.recipe_method,
      'recipe_tags': instance.recipe_tags,
      'createdAt': instance.createdAt,
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
