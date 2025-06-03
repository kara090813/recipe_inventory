// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CookingHistoryAdapter extends TypeAdapter<CookingHistory> {
  @override
  final int typeId = 3;

  @override
  CookingHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CookingHistory(
      recipe: fields[0] as Recipe,
      dateTime: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CookingHistory obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.recipe)
      ..writeByte(1)
      ..write(obj.dateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CookingHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OngoingCookingAdapter extends TypeAdapter<OngoingCooking> {
  @override
  final int typeId = 4;

  @override
  OngoingCooking read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OngoingCooking(
      recipe: fields[0] as Recipe,
      startTime: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, OngoingCooking obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.recipe)
      ..writeByte(1)
      ..write(obj.startTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OngoingCookingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CookingHistoryImpl _$$CookingHistoryImplFromJson(Map<String, dynamic> json) =>
    _$CookingHistoryImpl(
      recipe: Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
      dateTime: DateTime.parse(json['dateTime'] as String),
    );

Map<String, dynamic> _$$CookingHistoryImplToJson(
        _$CookingHistoryImpl instance) =>
    <String, dynamic>{
      'recipe': instance.recipe,
      'dateTime': instance.dateTime.toIso8601String(),
    };

_$OngoingCookingImpl _$$OngoingCookingImplFromJson(Map<String, dynamic> json) =>
    _$OngoingCookingImpl(
      recipe: Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
      startTime: DateTime.parse(json['startTime'] as String),
    );

Map<String, dynamic> _$$OngoingCookingImplToJson(
        _$OngoingCookingImpl instance) =>
    <String, dynamic>{
      'recipe': instance.recipe,
      'startTime': instance.startTime.toIso8601String(),
    };
