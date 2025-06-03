// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodAdapter extends TypeAdapter<Food> {
  @override
  final int typeId = 2;

  @override
  Food read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Food(
      name: fields[0] as String,
      type: fields[1] as String,
      img: fields[2] as String,
      order: fields[3] as int,
      similarNames: (fields[4] as List).cast<String>(),
      isCustom: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Food obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.img)
      ..writeByte(3)
      ..write(obj.order)
      ..writeByte(4)
      ..write(obj.similarNames)
      ..writeByte(5)
      ..write(obj.isCustom);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FoodImpl _$$FoodImplFromJson(Map<String, dynamic> json) => _$FoodImpl(
      name: json['name'] as String,
      type: json['type'] as String,
      img: json['img'] as String,
      order: (json['order'] as num?)?.toInt() ?? 0,
      similarNames: (json['similarNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isCustom: json['isCustom'] as bool? ?? false,
    );

Map<String, dynamic> _$$FoodImplToJson(_$FoodImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'img': instance.img,
      'order': instance.order,
      'similarNames': instance.similarNames,
      'isCustom': instance.isCustom,
    };
