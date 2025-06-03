import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'food_model.freezed.dart';
part 'food_model.g.dart';

@freezed
@HiveType(typeId: 2)
class Food with _$Food {
  const factory Food({
    @HiveField(0) required String name,
    @HiveField(1) required String type,
    @HiveField(2) required String img,
    @HiveField(3) @Default(0) int order,
    @HiveField(4) @Default([]) List<String> similarNames,
    @HiveField(5) @Default(false) bool isCustom,
  }) = _Food;

  factory Food.fromJson(Map<String, dynamic> json) => _$FoodFromJson(json);
}