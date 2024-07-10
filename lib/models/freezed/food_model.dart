import 'package:freezed_annotation/freezed_annotation.dart';

part 'food_model.freezed.dart';
part 'food_model.g.dart'; // JSON 직렬화를 위해 필요

@freezed
class Food with _$Food {
  const factory Food({
    required String name,
    required String type,
    required String img,
    @Default(0) int order
  }) = _Food;

  factory Food.fromJson(Map<String, dynamic> json) => _$FoodFromJson(json);

}