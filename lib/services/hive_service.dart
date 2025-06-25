import 'package:hive_flutter/hive_flutter.dart';
import '../models/_models.dart';
import '../data/badgeData.dart';

class HiveService {
  static const String RECIPE_BOX = 'recipes';
  static const String FOOD_BOX = 'foods';
  static const String COOKING_HISTORY_BOX = 'cooking_history';
  static const String ONGOING_COOKING_BOX = 'ongoing_cooking';
  static const String USER_PROFILE_BOX = 'user_profile';
  static const String FAVORITE_RECIPES_BOX = 'favorite_recipes';
  static const String APP_SETTINGS_BOX = 'app_settings';
  static const String QUEST_BOX = 'quests';
  static const String USER_BADGE_PROGRESS_BOX = 'user_badge_progress';
  static const String BADGE_STATS_BOX = 'badge_stats';
  static const String CUSTOM_RECIPES_BOX = 'custom_recipes';
  static const String CUSTOM_RECIPE_DRAFT_BOX = 'custom_recipe_draft';
  static const String YOUTUBE_CONVERSION_BOX = 'youtube_conversion';
  
  // 초기화 상태 추적
  static bool _isInitialized = false;

  static late Box<Recipe> _recipeBox;
  static late Box<Food> _foodBox;
  static late Box<CookingHistory> _cookingHistoryBox;
  static late Box<OngoingCooking> _ongoingCookingBox;
  static late Box<UserProfile> _userProfileBox;
  static late Box<String> _favoriteRecipesBox;
  static late Box _appSettingsBox;
  static late Box<Quest> _questBox;
  static late Box<UserBadgeProgress> _userBadgeProgressBox;
  static late Box<BadgeStats> _badgeStatsBox;
  static late Box<Recipe> _customRecipesBox;
  static late Box<CustomRecipeDraft> _customRecipeDraftBox;
  static late Box _youtubeConversionBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Type Adapter 등록
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RecipeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(IngredientAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(FoodAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(CookingHistoryAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(OngoingCookingAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(LoginProviderAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(QuestAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(QuestConditionAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(QuestTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(BadgeAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(BadgeConditionAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(BadgeCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(BadgeDifficultyAdapter());
    }
    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(BadgeTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(15)) {
      Hive.registerAdapter(UserBadgeProgressAdapter());
    }
    if (!Hive.isAdapterRegistered(16)) {
      Hive.registerAdapter(BadgeStatsAdapter());
    }
    if (!Hive.isAdapterRegistered(17)) {
      Hive.registerAdapter(CustomRecipeDraftAdapter());
    }

    // Box 열기 - Recipe 박스는 스키마 변경으로 인한 오류 처리
    try {
      _recipeBox = await Hive.openBox<Recipe>(RECIPE_BOX);
    } catch (e) {
      print('Recipe 박스 열기 실패, 삭제 후 재생성: $e');
      try {
        await Hive.deleteBoxFromDisk(RECIPE_BOX);
      } catch (deleteError) {
        print('Recipe 박스 삭제 실패: $deleteError');
      }
      _recipeBox = await Hive.openBox<Recipe>(RECIPE_BOX);
    }
    _foodBox = await Hive.openBox<Food>(FOOD_BOX);
    
    // CookingHistory 박스 처리 - Recipe 참조로 인한 오류 처리
    try {
      _cookingHistoryBox = await Hive.openBox<CookingHistory>(COOKING_HISTORY_BOX);
    } catch (e) {
      print('CookingHistory 박스 열기 실패, 삭제 후 재생성: $e');
      try {
        await Hive.deleteBoxFromDisk(COOKING_HISTORY_BOX);
      } catch (deleteError) {
        print('CookingHistory 박스 삭제 실패: $deleteError');
      }
      _cookingHistoryBox = await Hive.openBox<CookingHistory>(COOKING_HISTORY_BOX);
    }
    
    // OngoingCooking 박스 처리 - Recipe 참조로 인한 오류 처리
    try {
      _ongoingCookingBox = await Hive.openBox<OngoingCooking>(ONGOING_COOKING_BOX);
    } catch (e) {
      print('OngoingCooking 박스 열기 실패, 삭제 후 재생성: $e');
      try {
        await Hive.deleteBoxFromDisk(ONGOING_COOKING_BOX);
      } catch (deleteError) {
        print('OngoingCooking 박스 삭제 실패: $deleteError');
      }
      _ongoingCookingBox = await Hive.openBox<OngoingCooking>(ONGOING_COOKING_BOX);
    }
    
    // UserProfile 박스 처리 - 스키마 변경으로 인한 오류 처리
    try {
      _userProfileBox = await Hive.openBox<UserProfile>(USER_PROFILE_BOX);
    } catch (e) {
      print('UserProfile 박스 열기 실패, 삭제 후 재생성: $e');
      try {
        await Hive.deleteBoxFromDisk(USER_PROFILE_BOX);
      } catch (deleteError) {
        print('박스 삭제 실패: $deleteError');
      }
      _userProfileBox = await Hive.openBox<UserProfile>(USER_PROFILE_BOX);
    }
    
    _favoriteRecipesBox = await Hive.openBox<String>(FAVORITE_RECIPES_BOX);
    _appSettingsBox = await Hive.openBox(APP_SETTINGS_BOX);
    
    // Quest 박스 처리 - 안전한 초기화
    try {
      _questBox = await Hive.openBox<Quest>(QUEST_BOX);
    } catch (e) {
      print('Quest 박스 열기 실패, 삭제 후 재생성: $e');
      try {
        await Hive.deleteBoxFromDisk(QUEST_BOX);
      } catch (deleteError) {
        print('Quest 박스 삭제 실패: $deleteError');
      }
      _questBox = await Hive.openBox<Quest>(QUEST_BOX);
    }
    
    // UserBadgeProgress 박스 처리 - 안전한 초기화
    try {
      _userBadgeProgressBox = await Hive.openBox<UserBadgeProgress>(USER_BADGE_PROGRESS_BOX);
    } catch (e) {
      print('UserBadgeProgress 박스 열기 실패, 삭제 후 재생성: $e');
      try {
        await Hive.deleteBoxFromDisk(USER_BADGE_PROGRESS_BOX);
      } catch (deleteError) {
        print('UserBadgeProgress 박스 삭제 실패: $deleteError');
      }
      _userBadgeProgressBox = await Hive.openBox<UserBadgeProgress>(USER_BADGE_PROGRESS_BOX);
    }
    
    // BadgeStats 박스 처리 - 안전한 초기화
    try {
      _badgeStatsBox = await Hive.openBox<BadgeStats>(BADGE_STATS_BOX);
    } catch (e) {
      print('BadgeStats 박스 열기 실패, 삭제 후 재생성: $e');
      try {
        await Hive.deleteBoxFromDisk(BADGE_STATS_BOX);
      } catch (deleteError) {
        print('BadgeStats 박스 삭제 실패: $deleteError');
      }
      _badgeStatsBox = await Hive.openBox<BadgeStats>(BADGE_STATS_BOX);
    }
    // CustomRecipes 박스 처리
    try {
      _customRecipesBox = await Hive.openBox<Recipe>(CUSTOM_RECIPES_BOX);
    } catch (e) {
      print('CustomRecipes 박스 열기 실패, 삭제 후 재생성: $e');
      try {
        await Hive.deleteBoxFromDisk(CUSTOM_RECIPES_BOX);
      } catch (deleteError) {
        print('CustomRecipes 박스 삭제 실패: $deleteError');
      }
      _customRecipesBox = await Hive.openBox<Recipe>(CUSTOM_RECIPES_BOX);
    }
    
    // CustomRecipeDraft 박스 처리
    try {
      _customRecipeDraftBox = await Hive.openBox<CustomRecipeDraft>(CUSTOM_RECIPE_DRAFT_BOX);
    } catch (e) {
      print('CustomRecipeDraft 박스 열기 실패, 삭제 후 재생성: $e');
      try {
        await Hive.deleteBoxFromDisk(CUSTOM_RECIPE_DRAFT_BOX);
      } catch (deleteError) {
        print('CustomRecipeDraft 박스 삭제 실패: $deleteError');
      }
      _customRecipeDraftBox = await Hive.openBox<CustomRecipeDraft>(CUSTOM_RECIPE_DRAFT_BOX);
    }

    // YoutubeConversion 박스 (변환 제한 관리용)
    _youtubeConversionBox = await Hive.openBox(YOUTUBE_CONVERSION_BOX);
    
    // 초기화 완료 표시
    _isInitialized = true;
    print('✅ HiveService 초기화 완료');
  }
  
  // 초기화 상태 확인 메서드
  static bool get isInitialized => _isInitialized;

  // Recipe 관련 메서드
  static Future<void> saveRecipes(List<Recipe> recipes) async {
    await _recipeBox.clear();
    for (int i = 0; i < recipes.length; i++) {
      await _recipeBox.put(recipes[i].id, recipes[i]);
    }
  }

  static List<Recipe> getRecipes() {
    return _recipeBox.values.toList();
  }

  static Recipe? getRecipe(String id) {
    return _recipeBox.get(id);
  }

  static Future<void> clearRecipes() async {
    await _recipeBox.clear();
  }

  // Custom Recipe 관련 메서드
  static Future<void> saveCustomRecipe(Recipe recipe) async {
    await _customRecipesBox.put(recipe.id, recipe);
  }

  static Future<void> updateCustomRecipe(Recipe recipe) async {
    await _customRecipesBox.put(recipe.id, recipe);
  }

  static List<Recipe> getCustomRecipes() {
    return _customRecipesBox.values.toList();
  }

  static Recipe? getCustomRecipe(String id) {
    return _customRecipesBox.get(id);
  }

  static Future<void> deleteCustomRecipe(String id) async {
    await _customRecipesBox.delete(id);
  }

  static Future<void> clearCustomRecipes() async {
    await _customRecipesBox.clear();
  }

  // Custom Recipe Draft 관련 메서드
  static Future<void> saveCustomRecipeDraft(CustomRecipeDraft draft) async {
    if (!_isInitialized) {
      print('⚠️ HiveService가 아직 초기화되지 않았습니다.');
      return;
    }
    
    try {
      final updatedDraft = draft.copyWith(
        lastSavedAt: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      await _customRecipeDraftBox.put('draft', updatedDraft);
    } catch (e) {
      print('CustomRecipeDraft 저장 실패: $e');
      throw e; // 오류를 다시 throw하여 호출하는 곳에서 처리할 수 있도록 함
    }
  }

  static CustomRecipeDraft? getCustomRecipeDraft() {
    if (!_isInitialized) {
      return null;
    }
    
    try {
      return _customRecipeDraftBox.get('draft');
    } catch (e) {
      // 박스가 아직 초기화되지 않았거나 오류가 발생한 경우
      return null;
    }
  }

  static Future<void> clearCustomRecipeDraft() async {
    if (!_isInitialized) {
      print('⚠️ HiveService가 아직 초기화되지 않았습니다.');
      return;
    }
    
    try {
      await _customRecipeDraftBox.clear();
    } catch (e) {
      print('CustomRecipeDraft 삭제 실패: $e');
      throw e;
    }
  }

  static bool hasCustomRecipeDraft() {
    if (!_isInitialized) {
      return false;
    }
    
    try {
      final draft = getCustomRecipeDraft();
      return draft != null && 
             (draft.title.isNotEmpty || 
              draft.ingredients.isNotEmpty || 
              draft.cookingSteps.isNotEmpty);
    } catch (e) {
      // 박스가 아직 초기화되지 않았거나 오류가 발생한 경우
      return false;
    }
  }

  // Food 관련 메서드
  static Future<void> saveFoods(List<Food> foods) async {
    await _foodBox.clear();
    for (int i = 0; i < foods.length; i++) {
      await _foodBox.put(i, foods[i]);
    }
  }

  static List<Food> getFoods() {
    return _foodBox.values.toList();
  }

  static Future<void> addFoods(List<Food> foods) async {
    final existingFoods = getFoods();
    final Set<Food> uniqueFoods = Set.from(existingFoods);
    uniqueFoods.addAll(foods);
    await saveFoods(uniqueFoods.toList());
  }

  static Future<void> removeFoods(List<Food> foods) async {
    final existingFoods = getFoods();
    final Set<Food> foodsToRemove = Set.from(foods);
    final filteredFoods =
        existingFoods.where((food) => !foodsToRemove.contains(food)).toList();
    await saveFoods(filteredFoods);
  }

  static Future<void> clearFoods() async {
    await _foodBox.clear();
  }

  // CookingHistory 관련 메서드
  static Future<void> saveCookingHistory(List<CookingHistory> history) async {
    await _cookingHistoryBox.clear();
    for (int i = 0; i < history.length; i++) {
      await _cookingHistoryBox.put(i, history[i]);
    }
  }

  static List<CookingHistory> getCookingHistory() {
    return _cookingHistoryBox.values.toList();
  }

  static Future<void> addCookingHistory(CookingHistory history) async {
    await _cookingHistoryBox.add(history);
  }

  // OngoingCooking 관련 메서드
  static Future<void> saveOngoingCooking(List<OngoingCooking> ongoing) async {
    await _ongoingCookingBox.clear();
    for (int i = 0; i < ongoing.length; i++) {
      await _ongoingCookingBox.put(i, ongoing[i]);
    }
  }

  static List<OngoingCooking> getOngoingCooking() {
    return _ongoingCookingBox.values.toList();
  }

  static Future<void> clearOngoingCooking() async {
    await _ongoingCookingBox.clear();
  }

  // UserProfile 관련 메서드
  static Future<void> saveUserProfile(UserProfile profile) async {
    await _userProfileBox.put('profile', profile);
  }

  static UserProfile? getUserProfile() {
    return _userProfileBox.get('profile');
  }

  static Future<void> clearUserProfile() async {
    await _userProfileBox.clear();
  }

  // FavoriteRecipes 관련 메서드
  static Future<void> saveFavoriteRecipes(List<String> recipeIds) async {
    await _favoriteRecipesBox.clear();
    for (int i = 0; i < recipeIds.length; i++) {
      await _favoriteRecipesBox.put(i, recipeIds[i]);
    }
  }

  static List<String> getFavoriteRecipes() {
    return _favoriteRecipesBox.values.toList();
  }

  static Future<void> addFavoriteRecipe(String recipeId) async {
    final favorites = getFavoriteRecipes();
    if (!favorites.contains(recipeId)) {
      await _favoriteRecipesBox.add(recipeId);
    }
  }

  static Future<void> removeFavoriteRecipe(String recipeId) async {
    final favorites = getFavoriteRecipes();
    final index = favorites.indexOf(recipeId);
    if (index >= 0) {
      await _favoriteRecipesBox.deleteAt(index);
    }
  }

  static Future<void> clearFavoriteRecipes() async {
    await _favoriteRecipesBox.clear();
  }

  static Future<void> saveQuests(List<Quest> quests) async {
    await _questBox.clear();
    for (int i = 0; i < quests.length; i++) {
      await _questBox.put(quests[i].id, quests[i]);
    }
  }

  static List<Quest> getQuests() {
    return _questBox.values.toList();
  }

  static Quest? getQuest(String questId) {
    return _questBox.get(questId);
  }

  /// 개별 퀘스트 업데이트
  static Future<void> updateQuestProgress(String questId, int progress,
      bool isCompleted, bool isRewardReceived) async {
    final quest = _questBox.get(questId);
    if (quest != null) {
      final updatedQuest = quest.copyWith(
        currentProgress: progress,
        isCompleted: isCompleted,
        isRewardReceived: isRewardReceived,
      );
      await _questBox.put(questId, updatedQuest);
    }
  }

  static Future<void> clearQuests() async {
    await _questBox.clear();
  }

  // 퀘스트 체크 시간 관련 메서드 (기존 설정 메서드 활용)
  static Future<void> setLastQuestCheckTime(int timestamp) async {
    await _appSettingsBox.put('last_quest_check_time', timestamp);
  }

  static int? getLastQuestCheckTime() {
    return _appSettingsBox.get('last_quest_check_time');
  }

  // App Settings 관련 메서드 (기존 SharedPreferences 기타 설정들)
  static Future<void> setString(String key, String value) async {
    await _appSettingsBox.put(key, value);
  }

  static String? getString(String key) {
    return _appSettingsBox.get(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _appSettingsBox.put(key, value);
  }

  static bool? getBool(String key) {
    return _appSettingsBox.get(key);
  }

  static Future<void> setInt(String key, int value) async {
    await _appSettingsBox.put(key, value);
  }

  static int? getInt(String key) {
    return _appSettingsBox.get(key);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await _appSettingsBox.put(key, value);
  }

  static List<String>? getStringList(String key) {
    final value = _appSettingsBox.get(key);
    if (value is List) {
      return value.cast<String>();
    }
    return null;
  }

  static Future<void> remove(String key) async {
    await _appSettingsBox.delete(key);
  }

  // ==================== UserBadgeProgress 관련 메서드 ====================

  /// 사용자 뱃지 진행도 저장
  static Future<void> saveUserBadgeProgress(List<UserBadgeProgress> progressList) async {
    await _userBadgeProgressBox.clear();
    for (final progress in progressList) {
      await _userBadgeProgressBox.put(progress.badgeId, progress);
    }
  }

  /// 사용자 뱃지 진행도 로드
  static List<UserBadgeProgress> getUserBadgeProgress() {
    return _userBadgeProgressBox.values.toList();
  }

  /// 특정 뱃지 진행도 가져오기
  static UserBadgeProgress? getBadgeProgress(String badgeId) {
    return _userBadgeProgressBox.get(badgeId);
  }

  /// 개별 뱃지 진행도 업데이트
  static Future<void> updateBadgeProgress({
    required String badgeId,
    required int currentProgress,
    required bool isUnlocked,
    DateTime? unlockedAt,
    bool? isMainBadge,
    Map<String, dynamic>? metadata,
  }) async {
    final existing = _userBadgeProgressBox.get(badgeId);

    final updated = UserBadgeProgress(
      badgeId: badgeId,
      currentProgress: currentProgress,
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAt ?? existing?.unlockedAt,
      isMainBadge: isMainBadge ?? existing?.isMainBadge ?? false,
      progressUpdatedAt: DateTime.now(),
      metadata: metadata ?? existing?.metadata ?? {},
    );

    await _userBadgeProgressBox.put(badgeId, updated);
  }

  /// 메인 뱃지 설정
  static Future<void> setMainBadge(String badgeId) async {
    // 모든 뱃지의 메인 설정 해제
    final allProgress = getUserBadgeProgress();
    for (final progress in allProgress) {
      if (progress.isMainBadge) {
        await updateBadgeProgress(
          badgeId: progress.badgeId,
          currentProgress: progress.currentProgress,
          isUnlocked: progress.isUnlocked,
          unlockedAt: progress.unlockedAt,
          isMainBadge: false,
          metadata: progress.metadata,
        );
      }
    }

    // 새로운 메인 뱃지 설정
    final targetProgress = getBadgeProgress(badgeId);
    if (targetProgress != null && targetProgress.isUnlocked) {
      await updateBadgeProgress(
        badgeId: badgeId,
        currentProgress: targetProgress.currentProgress,
        isUnlocked: targetProgress.isUnlocked,
        unlockedAt: targetProgress.unlockedAt,
        isMainBadge: true,
        metadata: targetProgress.metadata,
      );
    }
  }

  /// 메인 뱃지 해제
  static Future<void> clearMainBadge() async {
    // 모든 뱃지의 메인 설정 해제
    final allProgress = getUserBadgeProgress();
    for (final progress in allProgress) {
      if (progress.isMainBadge) {
        await updateBadgeProgress(
          badgeId: progress.badgeId,
          currentProgress: progress.currentProgress,
          isUnlocked: progress.isUnlocked,
          unlockedAt: progress.unlockedAt,
          isMainBadge: false,
          metadata: progress.metadata,
        );
      }
    }
  }

  /// 메인 뱃지 가져오기
  static UserBadgeProgress? getMainBadge() {
    final allProgress = getUserBadgeProgress();
    try {
      return allProgress.firstWhere((progress) => progress.isMainBadge);
    } catch (e) {
      return null;
    }
  }

  /// 잠금 해제된 뱃지 목록
  static List<UserBadgeProgress> getUnlockedBadges() {
    return getUserBadgeProgress().where((progress) => progress.isUnlocked).toList();
  }

  /// 진행 중인 뱃지 목록
  static List<UserBadgeProgress> getInProgressBadges() {
    return getUserBadgeProgress().where((progress) =>
    !progress.isUnlocked && progress.currentProgress > 0
    ).toList();
  }

  /// 뱃지 진행도 초기화
  static Future<void> clearBadgeProgress() async {
    await _userBadgeProgressBox.clear();
  }

// ==================== BadgeStats 관련 메서드 ====================

  /// 뱃지 통계 저장
  static Future<void> saveBadgeStats(BadgeStats stats) async {
    await _badgeStatsBox.put('badge_stats', stats);
  }

  /// 뱃지 통계 로드
  static BadgeStats? getBadgeStats() {
    return _badgeStatsBox.get('badge_stats');
  }

  /// 뱃지 통계 업데이트
  static Future<void> updateBadgeStats() async {
    final progressList = getUserBadgeProgress();
    final unlockedList = getUnlockedBadges();

    final weakCount = unlockedList.where((p) {
      final badge = getBadgeById(p.badgeId);
      return badge?.difficulty == BadgeDifficulty.weak;
    }).length;

    final mediumCount = unlockedList.where((p) {
      final badge = getBadgeById(p.badgeId);
      return badge?.difficulty == BadgeDifficulty.medium;
    }).length;

    final strongCount = unlockedList.where((p) {
      final badge = getBadgeById(p.badgeId);
      return badge?.difficulty == BadgeDifficulty.strong;
    }).length;

    final hellCount = unlockedList.where((p) {
      final badge = getBadgeById(p.badgeId);
      return badge?.difficulty == BadgeDifficulty.hell;
    }).length;

    final stats = BadgeStats(
      totalBadges: BADGE_LIST.length,
      unlockedBadges: unlockedList.length,
      weakBadges: weakCount,
      mediumBadges: mediumCount,
      strongBadges: strongCount,
      hellBadges: hellCount,
      lastUpdated: DateTime.now(),
    );

    await saveBadgeStats(stats);
  }

  // 전체 데이터 클리어
  static Future<void> clearAll() async {
    await _recipeBox.clear();
    await _foodBox.clear();
    await _cookingHistoryBox.clear();
    await _ongoingCookingBox.clear();
    await _userProfileBox.clear();
    await _favoriteRecipesBox.clear();
    await _appSettingsBox.clear();
    await _questBox.clear();
    await _userBadgeProgressBox.clear();
    await _badgeStatsBox.clear();
    await _customRecipesBox.clear();
    await _customRecipeDraftBox.clear();
    await _youtubeConversionBox.clear();
  }

  // 마이그레이션용 메서드
  static Future<void> migrateFromSharedPreferences() async {
    // 이 메서드는 기존 SharedPreferences 데이터를 Hive로 마이그레이션할 때 사용
    // 필요시 구현
  }

  /// UserProfile 마이그레이션 메서드
  static Future<void> _migrateUserProfile() async {
    try {
      final existingProfile = _userProfileBox.get('user_profile');
      if (existingProfile != null) {
        // 마이그레이션 로직 제거 - 기존 사용자도 기본값 유지
        print('UserProfile 로드 완료');
      }
    } catch (e) {
      print('UserProfile 마이그레이션 실패: $e');
      // 마이그레이션 실패 시 박스 재생성
      await Hive.deleteBoxFromDisk(USER_PROFILE_BOX);
      _userProfileBox = await Hive.openBox<UserProfile>(USER_PROFILE_BOX);
    }
  }

  // ==================== YouTube 변환 제한 관련 메서드 ====================

  /// 오늘 유튜브 변환 가능 여부 확인
  static Future<bool> canConvertYoutube() async {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    final conversions = _youtubeConversionBox.get(todayKey, defaultValue: 0) as int;
    return conversions < 2; // 하루 최대 2회
  }

  /// 유튜브 변환 횟수 증가
  static Future<void> incrementYoutubeConversion() async {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    final currentCount = _youtubeConversionBox.get(todayKey, defaultValue: 0) as int;
    await _youtubeConversionBox.put(todayKey, currentCount + 1);
  }

  /// 오늘 유튜브 변환 횟수 가져오기
  static int getTodayYoutubeConversions() {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    return _youtubeConversionBox.get(todayKey, defaultValue: 0) as int;
  }

  /// 유튜브 변환 기록 정리 (일주일 이전 데이터 삭제)
  static Future<void> cleanupYoutubeConversions() async {
    final weekAgo = DateTime.now().subtract(Duration(days: 7));
    final keysToDelete = <String>[];
    
    for (final key in _youtubeConversionBox.keys) {
      if (key is String && key.contains('-')) {
        try {
          final parts = key.split('-');
          if (parts.length == 3) {
            final date = DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
            if (date.isBefore(weekAgo)) {
              keysToDelete.add(key);
            }
          }
        } catch (e) {
          // 잘못된 형식의 키는 삭제
          keysToDelete.add(key);
        }
      }
    }
    
    for (final key in keysToDelete) {
      await _youtubeConversionBox.delete(key);
    }
  }
}
