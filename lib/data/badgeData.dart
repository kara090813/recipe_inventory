import '../models/_models.dart';

/// 전체 뱃지 리스트
final List<Badge> BADGE_LIST = [
  // ==================== 🏅 요리 횟수 (5단계) ====================
  Badge(
    id: 'count_01',
    name: '첫 요리의 기억',
    description: '첫 번째 요리 완료',
    imagePath: 'assets/imgs/badge/count/count1.png',
    category: BadgeCategory.count,
    difficulty: BadgeDifficulty.weak,
    condition: BadgeCondition(
      type: BadgeType.totalCookingCount,
      targetCookingCount: 1,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 1,
  ),
  Badge(
    id: 'count_02',
    name: '요리의 길 입문',
    description: '10개 레시피 완료',
    imagePath: 'assets/imgs/badge/count/count2.png',
    category: BadgeCategory.count,
    difficulty: BadgeDifficulty.weak,
    condition: BadgeCondition(
      type: BadgeType.totalCookingCount,
      targetCookingCount: 10,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 2,
  ),
  Badge(
    id: 'count_03',
    name: '요리의 달인',
    description: '30개 레시피 완료',
    imagePath: 'assets/imgs/badge/count/count3.png',
    category: BadgeCategory.count,
    difficulty: BadgeDifficulty.medium,
    condition: BadgeCondition(
      type: BadgeType.totalCookingCount,
      targetCookingCount: 30,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 3,
  ),
  Badge(
    id: 'count_04',
    name: '주방의 지휘자',
    description: '50개 레시피 완료',
    imagePath: 'assets/imgs/badge/count/count4.png',
    category: BadgeCategory.count,
    difficulty: BadgeDifficulty.strong,
    condition: BadgeCondition(
      type: BadgeType.totalCookingCount,
      targetCookingCount: 50,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 4,
  ),
  Badge(
    id: 'count_05',
    name: '궁극의 요리사',
    description: '100개 레시피 완료',
    imagePath: 'assets/imgs/badge/count/count5.png',
    category: BadgeCategory.count,
    difficulty: BadgeDifficulty.hell,
    condition: BadgeCondition(
      type: BadgeType.totalCookingCount,
      targetCookingCount: 100,
    ),
    sortOrder: 5,
  ),

  // ==================== 🔁 연속 요리 도전 (3단계) ====================
  Badge(
    id: 'continuous_01',
    name: '3일의 열정',
    description: '3일 연속 요리',
    imagePath: 'assets/imgs/badge/continuous/continuous1.png',
    category: BadgeCategory.continuous,
    difficulty: BadgeDifficulty.weak,
    condition: BadgeCondition(
      type: BadgeType.consecutiveCooking,
      consecutiveDays: 3,
    ),
    sortOrder: 10,
  ),
  Badge(
    id: 'continuous_02',
    name: '일주일의 습관',
    description: '7일 연속 요리',
    imagePath: 'assets/imgs/badge/continuous/continuous2.png',
    category: BadgeCategory.continuous,
    difficulty: BadgeDifficulty.medium,
    condition: BadgeCondition(
      type: BadgeType.consecutiveCooking,
      consecutiveDays: 7,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 11,
  ),
  Badge(
    id: 'continuous_03',
    name: '지속의 마법사',
    description: '30일 연속 요리',
    imagePath: 'assets/imgs/badge/continuous/continuous3.png',
    category: BadgeCategory.continuous,
    difficulty: BadgeDifficulty.strong,
    condition: BadgeCondition(
      type: BadgeType.consecutiveCooking,
      consecutiveDays: 30,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 12,
  ),

  // ==================== 🎯 난이도별 도전 - 쉬움 ====================
  Badge(
    id: 'difficulty_easy_01',
    name: '쉬운 맛 탐색자',
    description: '쉬움 5개 완료',
    imagePath: 'assets/imgs/badge/difficulty/easy1.png',
    category: BadgeCategory.difficulty,
    difficulty: BadgeDifficulty.weak,
    condition: BadgeCondition(
      type: BadgeType.difficultyBasedCooking,
      difficulty: '쉬움',
      difficultyCount: 5,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 20,
  ),
  Badge(
    id: 'difficulty_easy_02',
    name: '간편 요리꾼',
    description: '쉬움 15개 완료',
    imagePath: 'assets/imgs/badge/difficulty/easy2.png',
    category: BadgeCategory.difficulty,
    difficulty: BadgeDifficulty.medium,
    condition: BadgeCondition(
      type: BadgeType.difficultyBasedCooking,
      difficulty: '쉬움',
      difficultyCount: 15,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 21,
  ),
  Badge(
    id: 'difficulty_easy_03',
    name: '쉬운 레시피 달인',
    description: '쉬움 30개 완료',
    imagePath: 'assets/imgs/badge/difficulty/easy3.png',
    category: BadgeCategory.difficulty,
    difficulty: BadgeDifficulty.strong,
    condition: BadgeCondition(
      type: BadgeType.difficultyBasedCooking,
      difficulty: '쉬움',
      difficultyCount: 30,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 22,
  ),

  // ==================== 🎯 난이도별 도전 - 보통 ====================
  Badge(
    id: 'difficulty_normal_01',
    name: '보통의 도전자',
    description: '보통 3개 완료',
    imagePath: 'assets/imgs/badge/difficulty/normal1.png',
    category: BadgeCategory.difficulty,
    difficulty: BadgeDifficulty.weak,
    condition: BadgeCondition(
      type: BadgeType.difficultyBasedCooking,
      difficulty: '보통',
      difficultyCount: 3,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 25,
  ),
  Badge(
    id: 'difficulty_normal_02',
    name: '중간맛 정복자',
    description: '보통 12개 완료',
    imagePath: 'assets/imgs/badge/difficulty/normal2.png',
    category: BadgeCategory.difficulty,
    difficulty: BadgeDifficulty.medium,
    condition: BadgeCondition(
      type: BadgeType.difficultyBasedCooking,
      difficulty: '보통',
      difficultyCount: 12,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 26,
  ),
  Badge(
    id: 'difficulty_normal_03',
    name: '보통 난이도 장인',
    description: '보통 25개 완료',
    imagePath: 'assets/imgs/badge/difficulty/normal3.png',
    category: BadgeCategory.difficulty,
    difficulty: BadgeDifficulty.strong,
    condition: BadgeCondition(
      type: BadgeType.difficultyBasedCooking,
      difficulty: '보통',
      difficultyCount: 25,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 27,
  ),

  // ==================== 🎯 난이도별 도전 - 어려움 ====================
  Badge(
    id: 'difficulty_hard_01',
    name: '첫 도전의 용기',
    description: '어려움 1개 완료',
    imagePath: 'assets/imgs/badge/difficulty/hard1.png',
    category: BadgeCategory.difficulty,
    difficulty: BadgeDifficulty.weak,
    condition: BadgeCondition(
      type: BadgeType.difficultyBasedCooking,
      difficulty: '어려움',
      difficultyCount: 1,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 30,
  ),
  Badge(
    id: 'difficulty_hard_02',
    name: '고수의 길',
    description: '어려움 5개 완료',
    imagePath: 'assets/imgs/badge/difficulty/hard2.png',
    category: BadgeCategory.difficulty,
    difficulty: BadgeDifficulty.medium,
    condition: BadgeCondition(
      type: BadgeType.difficultyBasedCooking,
      difficulty: '어려움',
      difficultyCount: 5,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 31,
  ),
  Badge(
    id: 'difficulty_hard_03',
    name: '극한 마스터',
    description: '어려움 15개 완료',
    imagePath: 'assets/imgs/badge/difficulty/hard3.png',
    category: BadgeCategory.difficulty,
    difficulty: BadgeDifficulty.strong,
    condition: BadgeCondition(
      type: BadgeType.difficultyBasedCooking,
      difficulty: '어려움',
      difficultyCount: 15,
    ),
    sortOrder: 32,
  ),

  // ==================== 🍱 음식 종류별 - 한식 ====================
  Badge(
    id: 'type_korean_01',
    name: '한식 요리 입문자',
    description: '한식 5개 완료',
    imagePath: 'assets/imgs/badge/type/korean1.png',
    category: BadgeCategory.type,
    difficulty: BadgeDifficulty.medium,
    condition: BadgeCondition(
      type: BadgeType.recipeTypeCooking,
      recipeType: '한식',
      recipeTypeCount: 5,
    ),
    sortOrder: 40,
  ),
  Badge(
    id: 'type_korean_02',
    name: '한식 요리 애호가',
    description: '한식 15개 완료',
    imagePath: 'assets/imgs/badge/type/korean2.png',
    category: BadgeCategory.type,
    difficulty: BadgeDifficulty.strong,
    condition: BadgeCondition(
      type: BadgeType.recipeTypeCooking,
      recipeType: '한식',
      recipeTypeCount: 15,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 41,
  ),
  Badge(
    id: 'type_korean_03',
    name: '한식 요리 마스터',
    description: '한식 35개 완료',
    imagePath: 'assets/imgs/badge/type/korean3.png',
    category: BadgeCategory.type,
    difficulty: BadgeDifficulty.hell,
    condition: BadgeCondition(
      type: BadgeType.recipeTypeCooking,
      recipeType: '한식',
      recipeTypeCount: 35,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 42,
  ),

  // ==================== 🍱 음식 종류별 - 양식 ====================
  Badge(
    id: 'type_western_01',
    name: '양식 요리 입문자',
    description: '양식 5개 완료',
    imagePath: 'assets/imgs/badge/type/western1.png',
    category: BadgeCategory.type,
    difficulty: BadgeDifficulty.medium,
    condition: BadgeCondition(
      type: BadgeType.recipeTypeCooking,
      recipeType: '양식',
      recipeTypeCount: 5,
    ),
    sortOrder: 45,
  ),
  Badge(
    id: 'type_western_02',
    name: '양식 요리 애호가',
    description: '양식 12개 완료',
    imagePath: 'assets/imgs/badge/type/western2.png',
    category: BadgeCategory.type,
    difficulty: BadgeDifficulty.strong,
    condition: BadgeCondition(
      type: BadgeType.recipeTypeCooking,
      recipeType: '양식',
      recipeTypeCount: 12,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 46,
  ),
  Badge(
    id: 'type_western_03',
    name: '양식 요리 마스터',
    description: '양식 25개 완료',
    imagePath: 'assets/imgs/badge/type/western3.png',
    category: BadgeCategory.type,
    difficulty: BadgeDifficulty.hell,
    condition: BadgeCondition(
      type: BadgeType.recipeTypeCooking,
      recipeType: '양식',
      recipeTypeCount: 25,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 47,
  ),

  // ==================== 🍱 음식 종류별 - 중식 ====================
  Badge(
    id: 'type_chinese_01',
    name: '중식 요리 입문자',
    description: '중식 3개 완료',
    imagePath: 'assets/imgs/badge/type/chinese1.png',
    category: BadgeCategory.type,
    difficulty: BadgeDifficulty.medium,
    condition: BadgeCondition(
      type: BadgeType.recipeTypeCooking,
      recipeType: '중식',
      recipeTypeCount: 3,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 50,
  ),
  Badge(
    id: 'type_chinese_02',
    name: '중식 요리 애호가',
    description: '중식 8개 완료',
    imagePath: 'assets/imgs/badge/type/chinese2.png',
    category: BadgeCategory.type,
    difficulty: BadgeDifficulty.strong,
    condition: BadgeCondition(
      type: BadgeType.recipeTypeCooking,
      recipeType: '중식',
      recipeTypeCount: 8,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 51,
  ),
  Badge(
    id: 'type_chinese_03',
    name: '중식 요리 마스터',
    description: '중식 18개 완료',
    imagePath: 'assets/imgs/badge/type/chinese3.png',
    category: BadgeCategory.type,
    difficulty: BadgeDifficulty.hell,
    condition: BadgeCondition(
      type: BadgeType.recipeTypeCooking,
      recipeType: '중식',
      recipeTypeCount: 18,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 52,
  ),

  // ==================== 🍱 음식 종류별 - 일식 ====================
  Badge(
    id: 'type_japanese_01',
    name: '일식 요리 입문자',
    description: '일식 3개 완료',
    imagePath: 'assets/imgs/badge/type/japanese1.png',
    category: BadgeCategory.type,
    difficulty: BadgeDifficulty.medium,
    condition: BadgeCondition(
      type: BadgeType.recipeTypeCooking,
      recipeType: '일식',
      recipeTypeCount: 3,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 55,
  ),
  Badge(
    id: 'type_japanese_02',
    name: '일식 요리 애호가',
    description: '일식 10개 완료',
    imagePath: 'assets/imgs/badge/type/japanese2.png',
    category: BadgeCategory.type,
    difficulty: BadgeDifficulty.strong,
    condition: BadgeCondition(
      type: BadgeType.recipeTypeCooking,
      recipeType: '일식',
      recipeTypeCount: 10,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 56,
  ),
  Badge(
    id: 'type_japanese_03',
    name: '일식 요리 마스터',
    description: '일식 20개 완료',
    imagePath: 'assets/imgs/badge/type/japanese3.png',
    category: BadgeCategory.type,
    difficulty: BadgeDifficulty.hell,
    condition: BadgeCondition(
      type: BadgeType.recipeTypeCooking,
      recipeType: '일식',
      recipeTypeCount: 20,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 57,
  ),

  // ==================== ⏰ 시간대별 요리사 ====================
  Badge(
    id: 'time_morning',
    name: '모닝 셰프',
    description: '오전 7시 이전 15회',
    imagePath: 'assets/imgs/badge/time/morning.png',
    category: BadgeCategory.time,
    difficulty: BadgeDifficulty.medium,
    condition: BadgeCondition(
      type: BadgeType.timeBasedCooking,
      timeRangeStart: 0, // 0시
      timeRangeEnd: 7,   // 7시
      timeBasedCount: 15,
    ),
    sortOrder: 60,
  ),
  Badge(
    id: 'time_day',
    name: '점메추 전문가',
    description: '점심시간 25회',
    imagePath: 'assets/imgs/badge/time/day.png',
    category: BadgeCategory.time,
    difficulty: BadgeDifficulty.medium,
    condition: BadgeCondition(
      type: BadgeType.timeBasedCooking,
      timeRangeStart: 11, // 11시
      timeRangeEnd: 14,   // 14시
      timeBasedCount: 25,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 61,
  ),
  Badge(
    id: 'time_night',
    name: '야식 요정',
    description: '밤 10시 이후 20회',
    imagePath: 'assets/imgs/badge/time/night.png',
    category: BadgeCategory.time,
    difficulty: BadgeDifficulty.medium,
    condition: BadgeCondition(
      type: BadgeType.timeBasedCooking,
      timeRangeStart: 22, // 22시
      timeRangeEnd: 23,   // 23시 (24시간제에서는 23까지)
      timeBasedCount: 20,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 62,
  ),

  // ==================== 🌟 특별 도전 ====================
  Badge(
    id: 'special_collector',
    name: '레시피 수집가',
    description: '위시리스트 30개 저장',
    imagePath: 'assets/imgs/badge/spec/collector.png',
    category: BadgeCategory.special,
    difficulty: BadgeDifficulty.medium,
    condition: BadgeCondition(
      type: BadgeType.wishlistCollection,
      wishlistCount: 30,
    ),
    sortOrder: 70,
  ),
  Badge(
    id: 'special_retry',
    name: '재도전 장인',
    description: '같은 레시피 5번 요리 완료',
    imagePath: 'assets/imgs/badge/spec/retry.png',
    category: BadgeCategory.special,
    difficulty: BadgeDifficulty.medium,
    condition: BadgeCondition(
      type: BadgeType.recipeRetry,
      sameRecipeRetryCount: 5,
    ),
    isDesignComplete: false, // 파일명 공백
    sortOrder: 71,
  ),
];

/// 카테고리별 뱃지 필터링
List<Badge> getBadgesByCategory(BadgeCategory category) {
  return BADGE_LIST.where((badge) => badge.category == category).toList();
}

/// 난이도별 뱃지 필터링
List<Badge> getBadgesByDifficulty(BadgeDifficulty difficulty) {
  return BADGE_LIST.where((badge) => badge.difficulty == difficulty).toList();
}

/// 디자인 완료된 뱃지만 필터링
List<Badge> getCompletedDesignBadges() {
  return BADGE_LIST.where((badge) => badge.isDesignComplete).toList();
}

/// 특정 뱃지 찾기
Badge? getBadgeById(String badgeId) {
  try {
    return BADGE_LIST.firstWhere((badge) => badge.id == badgeId);
  } catch (e) {
    return null;
  }
}

/// 뱃지 통계
Map<String, int> getBadgeStatistics() {
  final stats = <String, int>{};

  stats['total'] = BADGE_LIST.length;
  stats['designComplete'] = BADGE_LIST.where((b) => b.isDesignComplete).length;
  stats['designIncomplete'] = BADGE_LIST.where((b) => !b.isDesignComplete).length;

  for (final category in BadgeCategory.values) {
    stats['category_${category.name}'] = getBadgesByCategory(category).length;
  }

  for (final difficulty in BadgeDifficulty.values) {
    stats['difficulty_${difficulty.name}'] = getBadgesByDifficulty(difficulty).length;
  }

  return stats;
}