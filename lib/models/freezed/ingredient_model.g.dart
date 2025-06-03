// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DisplayIngredientImpl _$$DisplayIngredientImplFromJson(
        Map<String, dynamic> json) =>
    _$DisplayIngredientImpl(
      food: json['food'] as String,
      cnt: json['cnt'] as String,
      img: json['img'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$$DisplayIngredientImplToJson(
        _$DisplayIngredientImpl instance) =>
    <String, dynamic>{
      'food': instance.food,
      'cnt': instance.cnt,
      'img': instance.img,
      'type': instance.type,
    };
