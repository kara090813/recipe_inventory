import '../models/_models.dart';
import '../models/data.dart';
import '../status/_status.dart';

class QuestChecker {
  /// 퀘스트 진행도를 계산하는 메인 메서드
  static int calculateProgress(
      Quest quest,
      UserStatus userStatus,
      FoodStatus foodStatus,
      RecipeStatus recipeStatus,
      ) {
    try {
      print('🎯 Quest: ${quest.title}');
      print('📅 Quest Synced At: ${quest.syncedAt}');

      // 🔥 퀘스트 싱크 날짜 이후의 히스토리만 필터링
      List<CookingHistory> relevantHistory;

      if (quest.syncedAt != null) {
        relevantHistory = userStatus.cookingHistory.where((history) {
          return history.dateTime.isAfter(quest.syncedAt!) ||
              history.dateTime.isAtSameMomentAs(quest.syncedAt!);
        }).toList();
        print('📊 Filtering history after quest sync date');
      } else {
        // syncedAt이 없는 경우 (기존 퀘스트) 전체 히스토리 사용
        relevantHistory = userStatus.cookingHistory;
        print('⚠️ No sync date found, using all history');
      }

      print('📈 Relevant History Count: ${relevantHistory.length} / ${userStatus.cookingHistory.length}');

      // 디버깅: 관련 히스토리 정보 출력
      if (relevantHistory.isNotEmpty) {
        print('🔍 Recent relevant cooking history:');
        for (int i = 0; i < relevantHistory.take(3).length; i++) {
          final history = relevantHistory[i];
          print('  - ${history.recipe.title} (${history.recipe.recipe_type}, ${history.recipe.difficulty}) at ${history.dateTime}');
        }
      }

      int progress = 0;

      switch (quest.type) {
        case QuestType.recipeTypeCount:
          progress = _checkRecipeTypeCount(quest, relevantHistory);
          break;
        case QuestType.difficultyComplete:
          progress = _checkDifficultyComplete(quest, relevantHistory);
          break;
        case QuestType.totalCookingCount:
          progress = _checkTotalCookingCount(quest, relevantHistory);
          break;
        case QuestType.complexRecipe:
          progress = _checkComplexRecipe(quest, relevantHistory);
          break;
        case QuestType.consecutiveCooking:
          progress = _checkConsecutiveCooking(quest, userStatus);
          break;
        case QuestType.ingredientUsage:
          progress = _checkIngredientUsage(quest, relevantHistory);
          break;
        case QuestType.ingredientTypeUsage:
          progress = _checkIngredientTypeUsage(quest, relevantHistory);
          break;
        case QuestType.taggedRecipe:
          progress = _checkTaggedRecipe(quest, relevantHistory);
          break;
        case QuestType.favoriteRecipeAdd:
          progress = _checkFavoriteRecipeAdd(quest, recipeStatus, quest.syncedAt);
          break;
        case QuestType.newIngredientAdd:
          progress = _checkNewIngredientAdd(quest, foodStatus, quest.syncedAt);
          break;
      }

      print('✅ Progress: $progress / ${quest.targetCount}');
      print('---');

      return progress.clamp(0, quest.targetCount);
    } catch (e) {
      print('💥 Quest progress calculation error: $e');
      return 0;
    }
  }

  /// 특정 레시피 타입 요리 횟수 체크
  static int _checkRecipeTypeCount(Quest quest, List<CookingHistory> history) {
    final targetType = quest.condition.recipeType;
    if (targetType == null) return 0;

    final matchingHistory = history.where((h) => h.recipe.recipe_type == targetType).toList();
    final count = matchingHistory.length;

    print('🍳 RecipeType ($targetType) Count: $count');

    // 디버깅: 매칭된 레시피들 출력
    if (matchingHistory.isNotEmpty && count <= 5) {
      print('  📋 Matching recipes:');
      for (final h in matchingHistory) {
        print('    - ${h.recipe.title} (${h.dateTime})');
      }
    }

    return count;
  }

  /// 특정 난이도 요리 완료 횟수 체크
  static int _checkDifficultyComplete(Quest quest, List<CookingHistory> history) {
    final targetDifficulty = quest.condition.difficulty;
    if (targetDifficulty == null) return 0;

    final matchingHistory = history.where((h) => h.recipe.difficulty == targetDifficulty).toList();
    final count = matchingHistory.length;

    print('⭐ Difficulty ($targetDifficulty) Count: $count');

    return count;
  }

  /// 전체 요리 횟수 체크
  static int _checkTotalCookingCount(Quest quest, List<CookingHistory> history) {
    final count = history.length;
    print('👨‍🍳 Total Cooking Count: $count');
    return count;
  }

  /// 복잡한 레시피 (재료 개수 기준) 요리 횟수 체크
  static int _checkComplexRecipe(Quest quest, List<CookingHistory> history) {
    final minIngredientCount = quest.condition.minIngredientCount;
    if (minIngredientCount == null) return 0;

    final matchingHistory = history.where((h) {
      return h.recipe.ingredients.length >= minIngredientCount;
    }).toList();
    final count = matchingHistory.length;

    print('🧪 Complex Recipe (>= $minIngredientCount ingredients) Count: $count');

    return count;
  }

  /// 연속 요리 일수 체크 (전체 히스토리 기준으로 계산)
  static int _checkConsecutiveCooking(Quest quest, UserStatus userStatus) {
    final consecutiveDays = userStatus.getConsecutiveCookingDays();
    print('🔥 Consecutive Cooking Days: $consecutiveDays');
    return consecutiveDays;
  }

  /// 특정 재료 사용 레시피 횟수 체크
  static int _checkIngredientUsage(Quest quest, List<CookingHistory> history) {
    final targetIngredient = quest.condition.ingredientName;
    if (targetIngredient == null) return 0;

    final matchingHistory = history.where((h) {
      return h.recipe.ingredients.any((ingredient) {
        return ingredient.food.toLowerCase().contains(targetIngredient.toLowerCase());
      });
    }).toList();
    final count = matchingHistory.length;

    print('🥬 Ingredient Usage ($targetIngredient) Count: $count');

    return count;
  }

  /// 특정 타입 재료 사용 레시피 횟수 체크
  static int _checkIngredientTypeUsage(Quest quest, List<CookingHistory> history) {
    final targetTypes = quest.condition.ingredientTypes;
    if (targetTypes.isEmpty) return 0;

    final matchingHistory = history.where((h) {
      return h.recipe.ingredients.any((ingredient) {
        // FOOD_LIST에서 해당 재료의 타입 찾기
        final foodItem = FOOD_LIST.where((food) {
          return food.name.toLowerCase() == ingredient.food.toLowerCase() ||
              food.similarNames.any((similar) =>
              similar.toLowerCase() == ingredient.food.toLowerCase());
        }).firstOrNull;

        if (foodItem != null) {
          return targetTypes.contains(foodItem.type);
        }
        return false;
      });
    }).toList();
    final count = matchingHistory.length;

    print('🥘 Ingredient Type Usage (${targetTypes.join(", ")}) Count: $count');

    return count;
  }

  /// 특정 태그 포함 레시피 요리 횟수 체크
  static int _checkTaggedRecipe(Quest quest, List<CookingHistory> history) {
    final targetTags = quest.condition.recipeTags;
    if (targetTags.isEmpty) return 0;

    final matchingHistory = history.where((h) {
      return h.recipe.recipe_tags.any((tag) => targetTags.contains(tag));
    }).toList();
    final count = matchingHistory.length;

    print('🏷️ Tagged Recipe (${targetTags.join(", ")}) Count: $count');

    return count;
  }

  /// 좋아요 레시피 추가 횟수 체크 (퀘스트 싱크 이후 추가된 것만)
  static int _checkFavoriteRecipeAdd(Quest quest, RecipeStatus recipeStatus, DateTime? syncedAt) {
    // TODO: 실제로는 syncedAt 이후 추가된 좋아요만 계산해야 함
    // 현재는 전체 좋아요 개수로 임시 처리
    final count = recipeStatus.favoriteRecipes.length;
    print('❤️ Favorite Recipe Count: $count');
    print('⚠️ Note: Should count only favorites added after sync date: $syncedAt');
    return count;
  }

  /// 새로운 식재료 추가 횟수 체크 (퀘스트 싱크 이후 추가된 것만)
  static int _checkNewIngredientAdd(Quest quest, FoodStatus foodStatus, DateTime? syncedAt) {
    // TODO: 실제로는 syncedAt 이후 추가된 식재료만 계산해야 함
    // 현재는 전체 식재료 개수로 임시 처리
    final count = foodStatus.userFood.length;
    print('🆕 New Ingredient Add Count: $count (total ingredients)');
    print('⚠️ Note: Should count only ingredients added after sync date: $syncedAt');
    return count;
  }

  /// 테스트용 메서드 - 퀘스트 체커 동작 확인
  static void testQuestChecker({
    required Quest testQuest,
    required UserStatus userStatus,
    required FoodStatus foodStatus,
    required RecipeStatus recipeStatus,
  }) {
    print('=== QuestChecker Test ===');
    print('Quest Title: ${testQuest.title}');
    print('Quest Type: ${testQuest.type}');
    print('Quest Synced At: ${testQuest.syncedAt}');
    print('Target Count: ${testQuest.targetCount}');

    final progress = calculateProgress(testQuest, userStatus, foodStatus, recipeStatus);
    final percentage = testQuest.targetCount > 0
        ? (progress / testQuest.targetCount * 100).round()
        : 0;

    print('Final Progress: $progress / ${testQuest.targetCount} ($percentage%)');
    print('Is Completed: ${progress >= testQuest.targetCount}');
    print('========================\n');
  }
}