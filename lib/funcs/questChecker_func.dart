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
      // 월별 퀘스트인 경우 해당 월 범위 계산
      final monthStart = _getMonthStart(quest.monthKey);
      final monthEnd = _getMonthEnd(quest.monthKey);

      // 해당 월 범위의 요리 히스토리만 필터링
      final filteredHistory = userStatus.cookingHistory.where((history) {
        return _isInDateRange(history.dateTime, monthStart, monthEnd);
      }).toList();

      print('Quest: ${quest.title}');
      print('Month Range: $monthStart ~ $monthEnd');
      print('Filtered History Count: ${filteredHistory.length}');

      int progress = 0;

      switch (quest.type) {
        case QuestType.recipeTypeCount:
          progress = _checkRecipeTypeCount(quest, filteredHistory);
          break;
        case QuestType.difficultyComplete:
          progress = _checkDifficultyComplete(quest, filteredHistory);
          break;
        case QuestType.totalCookingCount:
          progress = _checkTotalCookingCount(quest, filteredHistory);
          break;
        case QuestType.complexRecipe:
          progress = _checkComplexRecipe(quest, filteredHistory);
          break;
        case QuestType.consecutiveCooking:
          progress = _checkConsecutiveCooking(quest, userStatus);
          break;
        case QuestType.ingredientUsage:
          progress = _checkIngredientUsage(quest, filteredHistory);
          break;
        case QuestType.ingredientTypeUsage:
          progress = _checkIngredientTypeUsage(quest, filteredHistory);
          break;
        case QuestType.taggedRecipe:
          progress = _checkTaggedRecipe(quest, filteredHistory);
          break;
        case QuestType.favoriteRecipeAdd:
          progress = _checkFavoriteRecipeAdd(quest, recipeStatus);
          break;
        case QuestType.newIngredientAdd:
        // 새로운 식재료 추가는 현재 데이터 구조로는 추적이 어려우므로 0 반환
          progress = 0;
          print('newIngredientAdd: 현재 데이터 구조로는 추적 불가');
          break;
      }

      print('Progress: $progress / ${quest.targetCount}');
      print('---');

      return progress.clamp(0, quest.targetCount);
    } catch (e) {
      print('Quest progress calculation error: $e');
      return 0;
    }
  }

  /// 특정 레시피 타입 요리 횟수 체크
  static int _checkRecipeTypeCount(Quest quest, List<CookingHistory> history) {
    final targetType = quest.condition.recipeType;
    if (targetType == null) return 0;

    final count = history.where((h) => h.recipe.recipe_type == targetType).length;
    print('RecipeType ($targetType) Count: $count');
    return count;
  }

  /// 특정 난이도 요리 완료 횟수 체크
  static int _checkDifficultyComplete(Quest quest, List<CookingHistory> history) {
    final targetDifficulty = quest.condition.difficulty;
    if (targetDifficulty == null) return 0;

    final count = history.where((h) => h.recipe.difficulty == targetDifficulty).length;
    print('Difficulty ($targetDifficulty) Count: $count');
    return count;
  }

  /// 전체 요리 횟수 체크
  static int _checkTotalCookingCount(Quest quest, List<CookingHistory> history) {
    final count = history.length;
    print('Total Cooking Count: $count');
    return count;
  }

  /// 복잡한 레시피 (재료 개수 기준) 요리 횟수 체크
  static int _checkComplexRecipe(Quest quest, List<CookingHistory> history) {
    final minIngredientCount = quest.condition.minIngredientCount;
    if (minIngredientCount == null) return 0;

    final count = history.where((h) {
      return h.recipe.ingredients.length >= minIngredientCount;
    }).length;
    print('Complex Recipe (>= $minIngredientCount ingredients) Count: $count');
    return count;
  }

  /// 연속 요리 일수 체크
  static int _checkConsecutiveCooking(Quest quest, UserStatus userStatus) {
    final consecutiveDays = userStatus.getConsecutiveCookingDays();
    print('Consecutive Cooking Days: $consecutiveDays');
    return consecutiveDays;
  }

  /// 특정 재료 사용 레시피 횟수 체크
  static int _checkIngredientUsage(Quest quest, List<CookingHistory> history) {
    final targetIngredient = quest.condition.ingredientName;
    if (targetIngredient == null) return 0;

    final count = history.where((h) {
      return h.recipe.ingredients.any((ingredient) {
        return ingredient.food.toLowerCase().contains(targetIngredient.toLowerCase());
      });
    }).length;
    print('Ingredient Usage ($targetIngredient) Count: $count');
    return count;
  }

  /// 특정 타입 재료 사용 레시피 횟수 체크
  static int _checkIngredientTypeUsage(Quest quest, List<CookingHistory> history) {
    final targetTypes = quest.condition.ingredientTypes;
    if (targetTypes.isEmpty) return 0;

    final count = history.where((h) {
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
    }).length;
    print('Ingredient Type Usage (${targetTypes.join(", ")}) Count: $count');
    return count;
  }

  /// 특정 태그 포함 레시피 요리 횟수 체크
  static int _checkTaggedRecipe(Quest quest, List<CookingHistory> history) {
    final targetTags = quest.condition.recipeTags;
    if (targetTags.isEmpty) return 0;

    final count = history.where((h) {
      return h.recipe.recipe_tags.any((tag) => targetTags.contains(tag));
    }).length;
    print('Tagged Recipe (${targetTags.join(", ")}) Count: $count');
    return count;
  }

  /// 좋아요 레시피 추가 횟수 체크
  static int _checkFavoriteRecipeAdd(Quest quest, RecipeStatus recipeStatus) {
    final count = recipeStatus.favoriteRecipes.length;
    print('Favorite Recipe Count: $count');
    return count;
  }

  /// 월 시작 날짜 계산 (예: "2025-01" -> 2025-01-01 00:00:00)
  static DateTime _getMonthStart(String monthKey) {
    try {
      final parts = monthKey.split('-');
      if (parts.length != 2) {
        print('Invalid monthKey format: $monthKey');
        return DateTime.now().copyWith(day: 1, hour: 0, minute: 0, second: 0);
      }

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      return DateTime(year, month, 1, 0, 0, 0);
    } catch (e) {
      print('Error parsing monthKey: $e');
      return DateTime.now().copyWith(day: 1, hour: 0, minute: 0, second: 0);
    }
  }

  /// 월 끝 날짜 계산 (예: "2025-01" -> 2025-01-31 23:59:59)
  static DateTime _getMonthEnd(String monthKey) {
    try {
      final monthStart = _getMonthStart(monthKey);
      // 다음 달 1일에서 1초를 빼면 이번 달 마지막 시간
      final nextMonth = DateTime(monthStart.year, monthStart.month + 1, 1);
      return nextMonth.subtract(Duration(seconds: 1));
    } catch (e) {
      print('Error calculating month end: $e');
      final now = DateTime.now();
      return DateTime(now.year, now.month + 1, 1).subtract(Duration(seconds: 1));
    }
  }

  /// 날짜가 범위 내에 있는지 확인
  static bool _isInDateRange(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start.subtract(Duration(seconds: 1))) &&
        date.isBefore(end.add(Duration(seconds: 1)));
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