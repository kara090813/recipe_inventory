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

/*
firebase 퀘스트 컬렌션 구조
quests/
{documentId}: {
  id: string,                    // 퀘스트 고유 ID
  title: string,                 // 퀘스트 제목
  description: string,           // 퀘스트 설명
  type: string,                  // QuestType enum 값 (문자열)
  condition: {                   // 퀘스트 조건
    recipeType?: string,         // 레시피 타입 (한식, 양식, 중식, 일식, 아시안, 기타)
    difficulty?: string,         // 난이도 (매우 쉬움, 쉬움, 보통, 어려움, 매우 어려움)
    ingredientName?: string,     // 특정 식재료 이름
    ingredientTypes?: string[],  // 식재료 타입 배열
    minIngredientCount?: number, // 최소 식재료 개수
    consecutiveDays?: number,    // 연속 일수
    recipeTags?: string[]        // 레시피 태그 배열
  },
  targetCount: number,           // 목표 달성 횟수
  rewardPoints: number,          // 포인트 보상
  rewardExperience: number,      // 경험치 보상
  monthKey: string,             // 월 키 ("2025-01" 형식)
  isActive: boolean,            // 활성화 여부
  createdAt: timestamp,         // 생성 시간
  updatedAt: timestamp          // 수정 시간
}


 */