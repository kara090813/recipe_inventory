import '../models/_models.dart';
import '../data/badgeData.dart';
import '../status/_status.dart';

class BadgeChecker {
  // 성능 최적화를 위한 캐시
  static Map<String, dynamic>? _cachedHistoryData;
  static DateTime? _lastCacheTime;
  static const Duration CACHE_DURATION = Duration(minutes: 5);

  /// 뱃지 진행도를 계산하는 메인 메서드
  static int calculateBadgeProgress(
      Badge badge,
      UserStatus userStatus,
      FoodStatus foodStatus,
      RecipeStatus recipeStatus,
      List<UserBadgeProgress> userBadgeProgressList,
      ) {
    try {
      print('🎯 Badge: ${badge.name} (${badge.id})');

      // 캐시된 히스토리 데이터 사용 또는 생성
      final historyData = _getCachedHistoryData(userStatus, recipeStatus);
      final cookingHistory = historyData['cookingHistory'] as List<CookingHistory>;

      print('📊 Total Cooking History Count: ${cookingHistory.length}');

      int progress = 0;

      switch (badge.condition.type) {
        case BadgeType.totalCookingCount:
          progress = _checkTotalCookingCount(badge, cookingHistory);
          break;
        case BadgeType.consecutiveCooking:
          progress = _checkConsecutiveCooking(badge, userStatus);
          break;
        case BadgeType.difficultyBasedCooking:
          progress = _checkDifficultyBasedCooking(badge, cookingHistory);
          break;
        case BadgeType.recipeTypeCooking:
          progress = _checkRecipeTypeCooking(badge, cookingHistory);
          break;
        case BadgeType.timeBasedCooking:
          progress = _checkTimeBasedCooking(badge, cookingHistory);
          break;
        case BadgeType.wishlistCollection:
          progress = _checkWishlistCollection(badge, recipeStatus);
          break;
        case BadgeType.recipeRetry:
          progress = _checkRecipeRetry(badge, cookingHistory);
          break;
      }

      // 목표치를 초과하지 않도록 제한
      final targetCount = _getTargetCount(badge);
      final clampedProgress = progress.clamp(0, targetCount);

      print('✅ Progress: $clampedProgress / $targetCount');
      print('---');

      return clampedProgress;
    } catch (e) {
      print('💥 Badge progress calculation error: $e');
      return 0;
    }
  }

  /// 캐시된 히스토리 데이터 반환 (성능 최적화)
  static Map<String, dynamic> _getCachedHistoryData(
      UserStatus userStatus,
      RecipeStatus recipeStatus,
      ) {
    final now = DateTime.now();
    
    // 새로운 히스토리 데이터 강제 생성 (캐시 무시하고 항상 최신 데이터 사용)
    final cookingHistory = userStatus.cookingHistory;
    print('🔍 BadgeChecker: Getting fresh cooking history - count: ${cookingHistory.length}');

    // 레시피별 요리 횟수 계산 (recipeRetry용)
    final Map<String, int> recipeRetryCount = {};
    for (final history in cookingHistory) {
      final recipeId = history.recipe.id;
      recipeRetryCount[recipeId] = (recipeRetryCount[recipeId] ?? 0) + 1;
    }

    // 시간대별 요리 횟수 계산 (timeBasedCooking용)
    final Map<int, int> hourlyCount = {};
    for (final history in cookingHistory) {
      final hour = history.dateTime.hour;
      hourlyCount[hour] = (hourlyCount[hour] ?? 0) + 1;
    }

    final historyData = {
      'cookingHistory': cookingHistory,
      'recipeRetryCount': recipeRetryCount,
      'hourlyCount': hourlyCount,
      'maxRetryCount': recipeRetryCount.values.isEmpty ? 0 : recipeRetryCount.values.reduce((a, b) => a > b ? a : b),
    };

    print('📈 Fresh data generated: ${cookingHistory.length} histories processed');
    return historyData;
  }

  /// 전체 요리 횟수 체크
  static int _checkTotalCookingCount(Badge badge, List<CookingHistory> history) {
    final count = history.length;
    print('👨‍🍳 Total Cooking Count: $count');
    return count;
  }

  /// 연속 요리 일수 체크
  static int _checkConsecutiveCooking(Badge badge, UserStatus userStatus) {
    final consecutiveDays = userStatus.getConsecutiveCookingDays();
    print('🔥 Consecutive Cooking Days: $consecutiveDays');
    return consecutiveDays;
  }

  /// 난이도별 요리 완료 횟수 체크
  static int _checkDifficultyBasedCooking(Badge badge, List<CookingHistory> history) {
    final targetDifficulty = badge.condition.difficulty;
    if (targetDifficulty == null) return 0;

    // 난이도 뱃지는 해당 난이도와 더 높은 난이도 모두 포함
    final matchingHistory = history.where((h) {
      if (targetDifficulty == '쉬움') {
        return h.recipe.difficulty == '매우 쉬움' || h.recipe.difficulty == '쉬움';
      } else if (targetDifficulty == '어려움') {
        return h.recipe.difficulty == '어려움' || h.recipe.difficulty == '매우 어려움';
      }
      return h.recipe.difficulty == targetDifficulty;
    }).toList();
    final count = matchingHistory.length;

    print('⭐ Difficulty ($targetDifficulty) Count: $count');

    // 디버깅: 매칭된 레시피들 출력 (최대 3개)
    if (matchingHistory.isNotEmpty && count <= 5) {
      print('  📋 Recent matching recipes:');
      for (final h in matchingHistory.take(3)) {
        print('    - ${h.recipe.title} (${h.dateTime})');
      }
    }

    return count;
  }

  /// 레시피 타입별 요리 완료 횟수 체크
  static int _checkRecipeTypeCooking(Badge badge, List<CookingHistory> history) {
    final targetType = badge.condition.recipeType;
    if (targetType == null) return 0;

    final matchingHistory = history.where((h) => h.recipe.recipe_type == targetType).toList();
    final count = matchingHistory.length;

    print('🍱 Recipe Type ($targetType) Count: $count');

    // 디버깅: 매칭된 레시피들 출력 (최대 3개)
    if (matchingHistory.isNotEmpty && count <= 5) {
      print('  📋 Recent matching recipes:');
      for (final h in matchingHistory.take(3)) {
        print('    - ${h.recipe.title} (${h.dateTime})');
      }
    }

    return count;
  }

  /// 시간대별 요리 완료 횟수 체크
  static int _checkTimeBasedCooking(Badge badge, List<CookingHistory> history) {
    final startHour = badge.condition.timeRangeStart;
    final endHour = badge.condition.timeRangeEnd;

    if (startHour == null || endHour == null) return 0;

    int count = 0;
    for (final h in history) {
      final hour = h.dateTime.hour;

      // 시간 범위 체크 (자정을 넘어가는 경우도 고려)
      bool isInRange;
      if (startHour <= endHour) {
        // 일반적인 경우 (예: 11시~14시)
        isInRange = hour >= startHour && hour <= endHour;
      } else {
        // 자정을 넘어가는 경우 (예: 22시~02시)
        isInRange = hour >= startHour || hour <= endHour;
      }

      if (isInRange) {
        count++;
      }
    }

    print('⏰ Time-based Cooking (${startHour}h-${endHour}h) Count: $count');

    return count;
  }

  /// 위시리스트 수집 개수 체크
  static int _checkWishlistCollection(Badge badge, RecipeStatus recipeStatus) {
    final count = recipeStatus.favoriteRecipes.length;
    print('❤️ Wishlist Collection Count: $count');
    return count;
  }

  /// 레시피 재도전 횟수 체크
  static int _checkRecipeRetry(Badge badge, List<CookingHistory> history) {
    // 실시간으로 재시도 횟수 계산
    final Map<String, int> recipeRetryCount = {};
    for (final historyItem in history) {
      final recipeId = historyItem.recipe.id;
      recipeRetryCount[recipeId] = (recipeRetryCount[recipeId] ?? 0) + 1;
    }
    
    final maxRetryCount = recipeRetryCount.values.isEmpty ? 0 : recipeRetryCount.values.reduce((a, b) => a > b ? a : b);

    print('🔄 Recipe Retry Max Count: $maxRetryCount');

    // 디버깅: 상위 3개 재시도 레시피 출력
    final sortedEntries = recipeRetryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedEntries.isNotEmpty) {
      print('  📋 Top retry recipes:');
      for (final entry in sortedEntries.take(3)) {
        // 레시피 이름 찾기 (히스토리에서)
        final recipeName = history
            .where((h) => h.recipe.id == entry.key)
            .firstOrNull?.recipe.title ?? 'Unknown Recipe';
        print('    - $recipeName: ${entry.value}회');
      }
    }

    return maxRetryCount;
  }

  /// 뱃지의 목표 수치 반환
  static int _getTargetCount(Badge badge) {
    switch (badge.condition.type) {
      case BadgeType.totalCookingCount:
        return badge.condition.targetCookingCount ?? 1;
      case BadgeType.consecutiveCooking:
        return badge.condition.consecutiveDays ?? 1;
      case BadgeType.difficultyBasedCooking:
        return badge.condition.difficultyCount ?? 1;
      case BadgeType.recipeTypeCooking:
        return badge.condition.recipeTypeCount ?? 1;
      case BadgeType.timeBasedCooking:
        return badge.condition.timeBasedCount ?? 1;
      case BadgeType.wishlistCollection:
        return badge.condition.wishlistCount ?? 1;
      case BadgeType.recipeRetry:
        return badge.condition.sameRecipeRetryCount ?? 1;
    }
  }

  /// 캐시 초기화 (메모리 절약용)
  static void clearCache() {
    _cachedHistoryData = null;
    _lastCacheTime = null;
    print('🗑️ Badge checker cache cleared');
  }

  /// 특정 뱃지의 완료 여부 체크 (빠른 체크용)
  static bool isBadgeCompleted(
      Badge badge,
      UserStatus userStatus,
      FoodStatus foodStatus,
      RecipeStatus recipeStatus,
      List<UserBadgeProgress> userBadgeProgressList,
      ) {
    final progress = calculateBadgeProgress(
      badge,
      userStatus,
      foodStatus,
      recipeStatus,
      userBadgeProgressList,
    );
    final targetCount = _getTargetCount(badge);
    return progress >= targetCount;
  }

  /// 배치로 여러 뱃지 체크 (성능 최적화)
  static Map<String, int> calculateMultipleBadgeProgress(
      List<Badge> badges,
      UserStatus userStatus,
      FoodStatus foodStatus,
      RecipeStatus recipeStatus,
      List<UserBadgeProgress> userBadgeProgressList,
      ) {
    final results = <String, int>{};

    // 캐시 클리어하여 최신 데이터 보장
    clearCache();

    for (final badge in badges) {
      results[badge.id] = calculateBadgeProgress(
        badge,
        userStatus,
        foodStatus,
        recipeStatus,
        userBadgeProgressList,
      );
    }

    return results;
  }

  /// 테스트용 메서드 - 뱃지 체커 동작 확인
  static void testBadgeChecker({
    required Badge testBadge,
    required UserStatus userStatus,
    required FoodStatus foodStatus,
    required RecipeStatus recipeStatus,
    required List<UserBadgeProgress> userBadgeProgressList,
  }) {
    print('=== BadgeChecker Test ===');
    print('Badge Name: ${testBadge.name}');
    print('Badge Type: ${testBadge.condition.type}');
    print('Badge Category: ${testBadge.category}');
    print('Badge Difficulty: ${testBadge.difficulty}');

    final targetCount = _getTargetCount(testBadge);
    print('Target Count: $targetCount');

    final progress = calculateBadgeProgress(
      testBadge,
      userStatus,
      foodStatus,
      recipeStatus,
      userBadgeProgressList,
    );

    final percentage = targetCount > 0
        ? (progress / targetCount * 100).round()
        : 0;

    print('Final Progress: $progress / $targetCount ($percentage%)');
    print('Is Completed: ${progress >= targetCount}');
    print('========================\n');
  }

  /// 디버깅용 정보 출력
  static void printBadgeCheckerStatus(
      UserStatus userStatus,
      RecipeStatus recipeStatus,
      ) {
    print('=== BadgeChecker Status ===');

    final historyData = _getCachedHistoryData(userStatus, recipeStatus);
    final cookingHistory = historyData['cookingHistory'] as List<CookingHistory>;
    final recipeRetryCount = historyData['recipeRetryCount'] as Map<String, int>;
    final hourlyCount = historyData['hourlyCount'] as Map<int, int>;

    print('📊 Total Cooking History: ${cookingHistory.length}');
    print('🔄 Unique Recipes Cooked: ${recipeRetryCount.length}');
    print('❤️ Favorite Recipes: ${recipeStatus.favoriteRecipes.length}');
    print('🔥 Consecutive Days: ${userStatus.getConsecutiveCookingDays()}');

    // 시간대별 분포
    print('⏰ Cooking by Hour:');
    final sortedHours = hourlyCount.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final entry in sortedHours) {
      print('  ${entry.key}시: ${entry.value}회');
    }

    // 난이도별 분포
    final difficultyCount = <String, int>{};
    for (final history in cookingHistory) {
      final difficulty = history.recipe.difficulty;
      difficultyCount[difficulty] = (difficultyCount[difficulty] ?? 0) + 1;
    }
    print('⭐ Cooking by Difficulty:');
    difficultyCount.forEach((difficulty, count) {
      print('  $difficulty: ${count}회');
    });

    // 타입별 분포
    final typeCount = <String, int>{};
    for (final history in cookingHistory) {
      final type = history.recipe.recipe_type;
      typeCount[type] = (typeCount[type] ?? 0) + 1;
    }
    print('🍱 Cooking by Type:');
    typeCount.forEach((type, count) {
      print('  $type: ${count}회');
    });

    print('🕐 Cache Age: ${_lastCacheTime != null ? DateTime.now().difference(_lastCacheTime!).inMinutes : 0} minutes');
    print('========================');
  }
}