// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BadgeAdapter extends TypeAdapter<Badge> {
  @override
  final int typeId = 10;

  @override
  Badge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Badge(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      imagePath: fields[3] as String,
      category: fields[4] as BadgeCategory,
      difficulty: fields[5] as BadgeDifficulty,
      condition: fields[6] as BadgeCondition,
      isDesignComplete: fields[7] as bool,
      sortOrder: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Badge obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.difficulty)
      ..writeByte(6)
      ..write(obj.condition)
      ..writeByte(7)
      ..write(obj.isDesignComplete)
      ..writeByte(8)
      ..write(obj.sortOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BadgeConditionAdapter extends TypeAdapter<BadgeCondition> {
  @override
  final int typeId = 11;

  @override
  BadgeCondition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BadgeCondition(
      type: fields[0] as BadgeType,
      targetCookingCount: fields[1] as int?,
      consecutiveDays: fields[2] as int?,
      difficulty: fields[3] as String?,
      difficultyCount: fields[4] as int?,
      recipeType: fields[5] as String?,
      recipeTypeCount: fields[6] as int?,
      timeRangeStart: fields[7] as int?,
      timeRangeEnd: fields[8] as int?,
      timeBasedCount: fields[9] as int?,
      wishlistCount: fields[10] as int?,
      sameRecipeRetryCount: fields[11] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, BadgeCondition obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.targetCookingCount)
      ..writeByte(2)
      ..write(obj.consecutiveDays)
      ..writeByte(3)
      ..write(obj.difficulty)
      ..writeByte(4)
      ..write(obj.difficultyCount)
      ..writeByte(5)
      ..write(obj.recipeType)
      ..writeByte(6)
      ..write(obj.recipeTypeCount)
      ..writeByte(7)
      ..write(obj.timeRangeStart)
      ..writeByte(8)
      ..write(obj.timeRangeEnd)
      ..writeByte(9)
      ..write(obj.timeBasedCount)
      ..writeByte(10)
      ..write(obj.wishlistCount)
      ..writeByte(11)
      ..write(obj.sameRecipeRetryCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeConditionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BadgeCategoryAdapter extends TypeAdapter<BadgeCategory> {
  @override
  final int typeId = 12;

  @override
  BadgeCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BadgeCategory.count;
      case 1:
        return BadgeCategory.continuous;
      case 2:
        return BadgeCategory.difficulty;
      case 3:
        return BadgeCategory.type;
      case 4:
        return BadgeCategory.time;
      case 5:
        return BadgeCategory.special;
      default:
        return BadgeCategory.count;
    }
  }

  @override
  void write(BinaryWriter writer, BadgeCategory obj) {
    switch (obj) {
      case BadgeCategory.count:
        writer.writeByte(0);
        break;
      case BadgeCategory.continuous:
        writer.writeByte(1);
        break;
      case BadgeCategory.difficulty:
        writer.writeByte(2);
        break;
      case BadgeCategory.type:
        writer.writeByte(3);
        break;
      case BadgeCategory.time:
        writer.writeByte(4);
        break;
      case BadgeCategory.special:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BadgeDifficultyAdapter extends TypeAdapter<BadgeDifficulty> {
  @override
  final int typeId = 13;

  @override
  BadgeDifficulty read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BadgeDifficulty.weak;
      case 1:
        return BadgeDifficulty.medium;
      case 2:
        return BadgeDifficulty.strong;
      case 3:
        return BadgeDifficulty.hell;
      default:
        return BadgeDifficulty.weak;
    }
  }

  @override
  void write(BinaryWriter writer, BadgeDifficulty obj) {
    switch (obj) {
      case BadgeDifficulty.weak:
        writer.writeByte(0);
        break;
      case BadgeDifficulty.medium:
        writer.writeByte(1);
        break;
      case BadgeDifficulty.strong:
        writer.writeByte(2);
        break;
      case BadgeDifficulty.hell:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeDifficultyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BadgeTypeAdapter extends TypeAdapter<BadgeType> {
  @override
  final int typeId = 14;

  @override
  BadgeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BadgeType.totalCookingCount;
      case 1:
        return BadgeType.consecutiveCooking;
      case 2:
        return BadgeType.difficultyBasedCooking;
      case 3:
        return BadgeType.recipeTypeCooking;
      case 4:
        return BadgeType.timeBasedCooking;
      case 5:
        return BadgeType.wishlistCollection;
      case 6:
        return BadgeType.recipeRetry;
      default:
        return BadgeType.totalCookingCount;
    }
  }

  @override
  void write(BinaryWriter writer, BadgeType obj) {
    switch (obj) {
      case BadgeType.totalCookingCount:
        writer.writeByte(0);
        break;
      case BadgeType.consecutiveCooking:
        writer.writeByte(1);
        break;
      case BadgeType.difficultyBasedCooking:
        writer.writeByte(2);
        break;
      case BadgeType.recipeTypeCooking:
        writer.writeByte(3);
        break;
      case BadgeType.timeBasedCooking:
        writer.writeByte(4);
        break;
      case BadgeType.wishlistCollection:
        writer.writeByte(5);
        break;
      case BadgeType.recipeRetry:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BadgeImpl _$$BadgeImplFromJson(Map<String, dynamic> json) => _$BadgeImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imagePath: json['imagePath'] as String,
      category: $enumDecode(_$BadgeCategoryEnumMap, json['category']),
      difficulty: $enumDecode(_$BadgeDifficultyEnumMap, json['difficulty']),
      condition:
          BadgeCondition.fromJson(json['condition'] as Map<String, dynamic>),
      isDesignComplete: json['isDesignComplete'] as bool? ?? true,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$BadgeImplToJson(_$BadgeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'imagePath': instance.imagePath,
      'category': _$BadgeCategoryEnumMap[instance.category]!,
      'difficulty': _$BadgeDifficultyEnumMap[instance.difficulty]!,
      'condition': instance.condition,
      'isDesignComplete': instance.isDesignComplete,
      'sortOrder': instance.sortOrder,
    };

const _$BadgeCategoryEnumMap = {
  BadgeCategory.count: 'count',
  BadgeCategory.continuous: 'continuous',
  BadgeCategory.difficulty: 'difficulty',
  BadgeCategory.type: 'type',
  BadgeCategory.time: 'time',
  BadgeCategory.special: 'special',
};

const _$BadgeDifficultyEnumMap = {
  BadgeDifficulty.weak: 'weak',
  BadgeDifficulty.medium: 'medium',
  BadgeDifficulty.strong: 'strong',
  BadgeDifficulty.hell: 'hell',
};

_$BadgeConditionImpl _$$BadgeConditionImplFromJson(Map<String, dynamic> json) =>
    _$BadgeConditionImpl(
      type: $enumDecode(_$BadgeTypeEnumMap, json['type']),
      targetCookingCount: (json['targetCookingCount'] as num?)?.toInt(),
      consecutiveDays: (json['consecutiveDays'] as num?)?.toInt(),
      difficulty: json['difficulty'] as String?,
      difficultyCount: (json['difficultyCount'] as num?)?.toInt(),
      recipeType: json['recipeType'] as String?,
      recipeTypeCount: (json['recipeTypeCount'] as num?)?.toInt(),
      timeRangeStart: (json['timeRangeStart'] as num?)?.toInt(),
      timeRangeEnd: (json['timeRangeEnd'] as num?)?.toInt(),
      timeBasedCount: (json['timeBasedCount'] as num?)?.toInt(),
      wishlistCount: (json['wishlistCount'] as num?)?.toInt(),
      sameRecipeRetryCount: (json['sameRecipeRetryCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$BadgeConditionImplToJson(
        _$BadgeConditionImpl instance) =>
    <String, dynamic>{
      'type': _$BadgeTypeEnumMap[instance.type]!,
      'targetCookingCount': instance.targetCookingCount,
      'consecutiveDays': instance.consecutiveDays,
      'difficulty': instance.difficulty,
      'difficultyCount': instance.difficultyCount,
      'recipeType': instance.recipeType,
      'recipeTypeCount': instance.recipeTypeCount,
      'timeRangeStart': instance.timeRangeStart,
      'timeRangeEnd': instance.timeRangeEnd,
      'timeBasedCount': instance.timeBasedCount,
      'wishlistCount': instance.wishlistCount,
      'sameRecipeRetryCount': instance.sameRecipeRetryCount,
    };

const _$BadgeTypeEnumMap = {
  BadgeType.totalCookingCount: 'totalCookingCount',
  BadgeType.consecutiveCooking: 'consecutiveCooking',
  BadgeType.difficultyBasedCooking: 'difficultyBasedCooking',
  BadgeType.recipeTypeCooking: 'recipeTypeCooking',
  BadgeType.timeBasedCooking: 'timeBasedCooking',
  BadgeType.wishlistCollection: 'wishlistCollection',
  BadgeType.recipeRetry: 'recipeRetry',
};
