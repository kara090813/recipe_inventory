import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'quest_model.freezed.dart';
part 'quest_model.g.dart';

@freezed
@HiveType(typeId: 7)
class Quest with _$Quest {
  factory Quest({
    @HiveField(0) required String id, // Firebase 문서 ID
    @HiveField(1) required String title,
    @HiveField(2) required String description,
    @HiveField(3) required QuestType type,
    @HiveField(4) required QuestCondition condition,
    @HiveField(5) required int targetCount,
    @HiveField(6) required int rewardPoints,
    @HiveField(7) required int rewardExperience,
    @HiveField(8) @Default(0) int currentProgress,
    @HiveField(9) @Default(false) bool isCompleted,
    @HiveField(10) @Default(false) bool isRewardReceived,
    // 🆕 퀘스트 싱크 받은 날짜 (진행도 체크 기준)
    @HiveField(11) DateTime? syncedAt,
    // Firebase updatedAt 필드 저장 (최신 퀘스트 비교용)
    @HiveField(12) DateTime? updatedAt,
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