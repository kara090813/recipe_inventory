import 'package:freezed_annotation/freezed_annotation.dart';

part 'food_model.freezed.dart';
part 'food_model.g.dart';

@freezed
class Food with _$Food {
  const factory Food({
    required String name,
    required String type,
    required String img,
    @Default(0) int order,
    @Default([]) List<String> similarNames,
    @Default(false) bool isCustom, // 커스텀 식재료 여부
  }) = _Food;

  factory Food.fromJson(Map<String, dynamic> json) => _$FoodFromJson(json);
}