import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'quest_model.freezed.dart';
part 'quest_model.g.dart';

@freezed
@HiveType(typeId: 7)
class Quest with _$Quest {
  factory Quest({
    @HiveField(0) required String id,
    @HiveField(1) required String title,
    @HiveField(2) required String description,
    @HiveField(3) required QuestType type,
    @HiveField(4) required QuestCondition condition,
    @HiveField(5) required int targetCount,
    @HiveField(6) required int rewardPoints,
    @HiveField(7) required int rewardExperience,
    @HiveField(8) required String monthKey,
    @HiveField(9) @Default(0) int currentProgress,
    @HiveField(10) @Default(false) bool isCompleted,
    @HiveField(11) @Default(false) bool isRewardReceived,
    // 🆕 퀘스트 시작 날짜 추가 (퀘스트를 받아온 날짜)
    @HiveField(12) DateTime? startDate,
  }) = _Quest;

  factory Quest.fromJson(Map<String, dynamic> json) => _$QuestFromJson(json);
}

@freezed
@HiveType(typeId: 8)
class QuestCondition with _$QuestCondition {
  factory QuestCondition({
    @HiveField(0) String? recipeType,
    @HiveField(1) String? difficulty,
    @HiveField(2) String? ingredientName,
    @HiveField(3) @Default([]) List<String> ingredientTypes,
    @HiveField(4) int? minIngredientCount,
    @HiveField(5) int? consecutiveDays,
    @HiveField(6) @Default([]) List<String> recipeTags,
  }) = _QuestCondition;

  factory QuestCondition.fromJson(Map<String, dynamic> json) => _$QuestConditionFromJson(json);
}

@HiveType(typeId: 9)
enum QuestType {
  @HiveField(0)
  recipeTypeCount,

  @HiveField(1)
  difficultyComplete,

  @HiveField(2)
  ingredientUsage,

  @HiveField(3)
  ingredientTypeUsage,

  @HiveField(4)
  newIngredientAdd,

  @HiveField(5)
  consecutiveCooking,

  @HiveField(6)
  favoriteRecipeAdd,

  @HiveField(7)
  complexRecipe,

  @HiveField(8)
  taggedRecipe,

  @HiveField(9)
  totalCookingCount,
}