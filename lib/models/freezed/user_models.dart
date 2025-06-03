import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'recipe_model.dart';
import 'auth_model.dart';

part 'user_models.freezed.dart';
part 'user_models.g.dart';

@freezed
@HiveType(typeId: 3)
class CookingHistory with _$CookingHistory {
  factory CookingHistory({
    @HiveField(0) required Recipe recipe,
    @HiveField(1) required DateTime dateTime,
  }) = _CookingHistory;

  factory CookingHistory.fromJson(Map<String, dynamic> json) => _$CookingHistoryFromJson(json);
}

@freezed
@HiveType(typeId: 4)
class OngoingCooking with _$OngoingCooking {
  factory OngoingCooking({
    @HiveField(0) required Recipe recipe,
    @HiveField(1) required DateTime startTime,
  }) = _OngoingCooking;

  factory OngoingCooking.fromJson(Map<String, dynamic> json) => _$OngoingCookingFromJson(json);
}