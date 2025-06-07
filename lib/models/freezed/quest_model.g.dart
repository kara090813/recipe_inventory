// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestAdapter extends TypeAdapter<Quest> {
  @override
  final int typeId = 7;

  @override
  Quest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Quest(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as QuestType,
      condition: fields[4] as QuestCondition,
      targetCount: fields[5] as int,
      rewardPoints: fields[6] as int,
      rewardExperience: fields[7] as int,
      monthKey: fields[8] as String,
      currentProgress: fields[9] as int,
      isCompleted: fields[10] as bool,
      isRewardReceived: fields[11] as bool,
      startDate: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Quest obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.condition)
      ..writeByte(5)
      ..write(obj.targetCount)
      ..writeByte(6)
      ..write(obj.rewardPoints)
      ..writeByte(7)
      ..write(obj.rewardExperience)
      ..writeByte(8)
      ..write(obj.monthKey)
      ..writeByte(9)
      ..write(obj.currentProgress)
      ..writeByte(10)
      ..write(obj.isCompleted)
      ..writeByte(11)
      ..write(obj.isRewardReceived)
      ..writeByte(12)
      ..write(obj.startDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuestConditionAdapter extends TypeAdapter<QuestCondition> {
  @override
  final int typeId = 8;

  @override
  QuestCondition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestCondition(
      recipeType: fields[0] as String?,
      difficulty: fields[1] as String?,
      ingredientName: fields[2] as String?,
      ingredientTypes: (fields[3] as List).cast<String>(),
      minIngredientCount: fields[4] as int?,
      consecutiveDays: fields[5] as int?,
      recipeTags: (fields[6] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, QuestCondition obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.recipeType)
      ..writeByte(1)
      ..write(obj.difficulty)
      ..writeByte(2)
      ..write(obj.ingredientName)
      ..writeByte(3)
      ..write(obj.ingredientTypes)
      ..writeByte(4)
      ..write(obj.minIngredientCount)
      ..writeByte(5)
      ..write(obj.consecutiveDays)
      ..writeByte(6)
      ..write(obj.recipeTags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestConditionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuestTypeAdapter extends TypeAdapter<QuestType> {
  @override
  final int typeId = 9;

  @override
  QuestType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuestType.recipeTypeCount;
      case 1:
        return QuestType.difficultyComplete;
      case 2:
        return QuestType.ingredientUsage;
      case 3:
        return QuestType.ingredientTypeUsage;
      case 4:
        return QuestType.newIngredientAdd;
      case 5:
        return QuestType.consecutiveCooking;
      case 6:
        return QuestType.favoriteRecipeAdd;
      case 7:
        return QuestType.complexRecipe;
      case 8:
        return QuestType.taggedRecipe;
      case 9:
        return QuestType.totalCookingCount;
      default:
        return QuestType.recipeTypeCount;
    }
  }

  @override
  void write(BinaryWriter writer, QuestType obj) {
    switch (obj) {
      case QuestType.recipeTypeCount:
        writer.writeByte(0);
        break;
      case QuestType.difficultyComplete:
        writer.writeByte(1);
        break;
      case QuestType.ingredientUsage:
        writer.writeByte(2);
        break;
      case QuestType.ingredientTypeUsage:
        writer.writeByte(3);
        break;
      case QuestType.newIngredientAdd:
        writer.writeByte(4);
        break;
      case QuestType.consecutiveCooking:
        writer.writeByte(5);
        break;
      case QuestType.favoriteRecipeAdd:
        writer.writeByte(6);
        break;
      case QuestType.complexRecipe:
        writer.writeByte(7);
        break;
      case QuestType.taggedRecipe:
        writer.writeByte(8);
        break;
      case QuestType.totalCookingCount:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuestImpl _$$QuestImplFromJson(Map<String, dynamic> json) => _$QuestImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$QuestTypeEnumMap, json['type']),
      condition:
          QuestCondition.fromJson(json['condition'] as Map<String, dynamic>),
      targetCount: (json['targetCount'] as num).toInt(),
      rewardPoints: (json['rewardPoints'] as num).toInt(),
      rewardExperience: (json['rewardExperience'] as num).toInt(),
      monthKey: json['monthKey'] as String,
      currentProgress: (json['currentProgress'] as num?)?.toInt() ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isRewardReceived: json['isRewardReceived'] as bool? ?? false,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
    );

Map<String, dynamic> _$$QuestImplToJson(_$QuestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$QuestTypeEnumMap[instance.type]!,
      'condition': instance.condition,
      'targetCount': instance.targetCount,
      'rewardPoints': instance.rewardPoints,
      'rewardExperience': instance.rewardExperience,
      'monthKey': instance.monthKey,
      'currentProgress': instance.currentProgress,
      'isCompleted': instance.isCompleted,
      'isRewardReceived': instance.isRewardReceived,
      'startDate': instance.startDate?.toIso8601String(),
    };

const _$QuestTypeEnumMap = {
  QuestType.recipeTypeCount: 'recipeTypeCount',
  QuestType.difficultyComplete: 'difficultyComplete',
  QuestType.ingredientUsage: 'ingredientUsage',
  QuestType.ingredientTypeUsage: 'ingredientTypeUsage',
  QuestType.newIngredientAdd: 'newIngredientAdd',
  QuestType.consecutiveCooking: 'consecutiveCooking',
  QuestType.favoriteRecipeAdd: 'favoriteRecipeAdd',
  QuestType.complexRecipe: 'complexRecipe',
  QuestType.taggedRecipe: 'taggedRecipe',
  QuestType.totalCookingCount: 'totalCookingCount',
};

_$QuestConditionImpl _$$QuestConditionImplFromJson(Map<String, dynamic> json) =>
    _$QuestConditionImpl(
      recipeType: json['recipeType'] as String?,
      difficulty: json['difficulty'] as String?,
      ingredientName: json['ingredientName'] as String?,
      ingredientTypes: (json['ingredientTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      minIngredientCount: (json['minIngredientCount'] as num?)?.toInt(),
      consecutiveDays: (json['consecutiveDays'] as num?)?.toInt(),
      recipeTags: (json['recipeTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$QuestConditionImplToJson(
        _$QuestConditionImpl instance) =>
    <String, dynamic>{
      'recipeType': instance.recipeType,
      'difficulty': instance.difficulty,
      'ingredientName': instance.ingredientName,
      'ingredientTypes': instance.ingredientTypes,
      'minIngredientCount': instance.minIngredientCount,
      'consecutiveDays': instance.consecutiveDays,
      'recipeTags': instance.recipeTags,
    };
