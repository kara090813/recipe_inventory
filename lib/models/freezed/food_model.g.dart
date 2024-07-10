// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FoodImpl _$$FoodImplFromJson(Map<String, dynamic> json) => _$FoodImpl(
      name: json['name'] as String,
      type: json['type'] as String,
      img: json['img'] as String,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$FoodImplToJson(_$FoodImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'img': instance.img,
      'order': instance.order,
    };
