// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_recipe_draft.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomRecipeDraftAdapter extends TypeAdapter<CustomRecipeDraft> {
  @override
  final int typeId = 17;

  @override
  CustomRecipeDraft read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomRecipeDraft(
      title: fields[0] as String,
      subTitle: fields[1] as String,
      foodType: fields[2] as String,
      difficulty: fields[3] as String,
      ingredients: (fields[4] as List).cast<Ingredient>(),
      cookingSteps: (fields[5] as List).cast<String>(),
      thumbnailPath: fields[6] as String,
      tags: (fields[7] as List).cast<String>(),
      youtubeUrl: fields[8] as String,
      lastSavedAt: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomRecipeDraft obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.subTitle)
      ..writeByte(2)
      ..write(obj.foodType)
      ..writeByte(3)
      ..write(obj.difficulty)
      ..writeByte(4)
      ..write(obj.ingredients)
      ..writeByte(5)
      ..write(obj.cookingSteps)
      ..writeByte(6)
      ..write(obj.thumbnailPath)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.youtubeUrl)
      ..writeByte(9)
      ..write(obj.lastSavedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomRecipeDraftAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomRecipeDraftImpl _$$CustomRecipeDraftImplFromJson(
        Map<String, dynamic> json) =>
    _$CustomRecipeDraftImpl(
      title: json['title'] as String? ?? "",
      subTitle: json['subTitle'] as String? ?? "",
      foodType: json['foodType'] as String? ?? "한식",
      difficulty: json['difficulty'] as String? ?? "매우 쉬움",
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      cookingSteps: (json['cookingSteps'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      thumbnailPath: json['thumbnailPath'] as String? ?? "",
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      youtubeUrl: json['youtubeUrl'] as String? ?? "",
      lastSavedAt: json['lastSavedAt'] as String? ?? "",
    );

Map<String, dynamic> _$$CustomRecipeDraftImplToJson(
        _$CustomRecipeDraftImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'subTitle': instance.subTitle,
      'foodType': instance.foodType,
      'difficulty': instance.difficulty,
      'ingredients': instance.ingredients,
      'cookingSteps': instance.cookingSteps,
      'thumbnailPath': instance.thumbnailPath,
      'tags': instance.tags,
      'youtubeUrl': instance.youtubeUrl,
      'lastSavedAt': instance.lastSavedAt,
    };
